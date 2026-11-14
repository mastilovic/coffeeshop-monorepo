#!/usr/bin/env python3
"""Check a square PNG for the coffee-cup magnifier mark.

Stdlib only. Exits 0 when the canvas is the expected size, a corner pixel is
dark charcoal, and some pixel is brown (red greater than green and blue).
Exits 1 otherwise. Pass --report to print size, corner, and content bounds.
"""

from __future__ import annotations

import argparse
import struct
import sys
import zlib


def read_png(path: str) -> tuple[int, int, int, list[bytearray]]:
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"{path}: not a PNG")
    pos = 8
    width = height = bit_depth = color_type = interlace = None
    idat = bytearray()
    while pos + 8 <= len(data):
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        ctype = data[pos + 4 : pos + 8]
        chunk = data[pos + 8 : pos + 8 + length]
        pos += 12 + length
        if ctype == b"IHDR":
            width, height, bit_depth, color_type, _comp, _filt, interlace = struct.unpack(
                ">IIBBBBB", chunk
            )
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"IEND":
            break
    if width is None or not idat:
        raise SystemExit(f"{path}: missing IHDR or IDAT")
    if interlace != 0 or bit_depth != 8 or color_type not in (2, 6):
        raise SystemExit(
            f"{path}: unsupported PNG bit_depth={bit_depth} color_type={color_type} interlace={interlace}"
        )
    channels = 3 if color_type == 2 else 4
    stride = width * channels
    raw = zlib.decompress(bytes(idat))
    rows: list[bytearray] = []
    index = 0
    prev = bytearray(stride)
    for _y in range(height):
        filter_type = raw[index]
        index += 1
        row = bytearray(raw[index : index + stride])
        index += stride
        unfilter(row, prev, filter_type, channels)
        prev = row
        rows.append(row)
    return width, height, channels, rows


def unfilter(row: bytearray, prev: bytearray, filter_type: int, channels: int) -> None:
    if filter_type == 0:
        return
    if filter_type == 1:
        for x in range(len(row)):
            left = row[x - channels] if x >= channels else 0
            row[x] = (row[x] + left) & 255
        return
    if filter_type == 2:
        for x in range(len(row)):
            row[x] = (row[x] + prev[x]) & 255
        return
    if filter_type == 3:
        for x in range(len(row)):
            left = row[x - channels] if x >= channels else 0
            row[x] = (row[x] + ((left + prev[x]) // 2)) & 255
        return
    if filter_type == 4:
        for x in range(len(row)):
            a = row[x - channels] if x >= channels else 0
            b = prev[x]
            c = prev[x - channels] if x >= channels else 0
            p = a + b - c
            pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
            predictor = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
            row[x] = (row[x] + predictor) & 255
        return
    raise SystemExit(f"unsupported PNG filter {filter_type}")


def pixel(rows: list[bytearray], channels: int, x: int, y: int) -> tuple[int, int, int]:
    i = x * channels
    row = rows[y]
    return row[i], row[i + 1], row[i + 2]


def is_charcoal(rgb: tuple[int, int, int]) -> bool:
    r, g, b = rgb
    return max(r, g, b) < 48 and max(r, g, b) - min(r, g, b) < 36


def is_brown(rgb: tuple[int, int, int]) -> bool:
    r, g, b = rgb
    return r > g and r > b and r >= 80


def content_bounds(
    rows: list[bytearray], channels: int, width: int, height: int, corner: tuple[int, int, int]
) -> tuple[int, int, int, int] | None:
    def ink(rgb: tuple[int, int, int]) -> bool:
        return sum(abs(a - b) for a, b in zip(rgb, corner)) > 36

    min_x, min_y, max_x, max_y = width, height, -1, -1
    for y in range(height):
        for x in range(width):
            if ink(pixel(rows, channels, x, y)):
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x < 0:
        return None
    return min_x, min_y, max_x, max_y


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("png")
    parser.add_argument("--size", type=int, required=True, help="expected square edge in pixels")
    parser.add_argument("--report", action="store_true", help="print size, corner, and content bounds")
    args = parser.parse_args()

    width, height, channels, rows = read_png(args.png)
    corner = pixel(rows, channels, 0, 0)
    brown = 0
    for y in range(height):
        for x in range(width):
            if is_brown(pixel(rows, channels, x, y)):
                brown += 1
    bounds = content_bounds(rows, channels, width, height, corner)
    failures: list[str] = []
    if width != args.size or height != args.size:
        failures.append(f"size {width}x{height}, expected {args.size}x{args.size}")
    if not is_charcoal(corner):
        failures.append(f"corner {corner} is not dark charcoal")
    if brown == 0:
        failures.append("no brown cup pixel (red greater than green and blue)")

    if args.report or failures:
        center = ""
        if bounds:
            min_x, min_y, max_x, max_y = bounds
            cx = (min_x + max_x) / 2
            cy = (min_y + max_y) / 2
            center = (
                f" bounds=({min_x},{min_y})-({max_x},{max_y})"
                f" content_center=({cx:.1f},{cy:.1f}) image_center=({(width - 1) / 2:.1f},{(height - 1) / 2:.1f})"
            )
        print(
            f"{args.png}: {width}x{height} corner={corner} brown_pixels={brown}{center}",
            file=sys.stderr if failures else sys.stdout,
        )
    if failures:
        print(f"FAIL {args.png}: " + "; ".join(failures), file=sys.stderr)
        return 1
    print(f"PASS {args.png}: {width}x{width} charcoal corner, brown cup pixel present")
    return 0


if __name__ == "__main__":
    sys.exit(main())
