import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.color,
    this.onRatingChanged,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final ValueChanged<int>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final filled = rating >= starValue;
        final halfFilled = !filled && rating >= starValue - 0.5;

        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(starValue) : null,
          child: Icon(
            filled
                ? Icons.star
                : halfFilled
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: starColor,
          ),
        );
      }),
    );
  }
}
