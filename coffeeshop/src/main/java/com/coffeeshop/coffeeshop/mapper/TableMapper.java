package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.Table;
import com.coffeeshop.coffeeshop.model.dto.request.TableCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.TableUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.TableResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.TableSummaryDto;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

@Service
public class TableMapper {

    private final ReservationMapper reservationMapper;

    public TableMapper(@Lazy final ReservationMapper reservationMapper) {
        this.reservationMapper = reservationMapper;
    }

    public TableSummaryDto toTableSummary(final Table table) {
        if (table == null) {
            return null;
        }
        final TableSummaryDto dto = new TableSummaryDto();
        dto.setId(table.getId());
        dto.setNumber(table.getNumber());
        dto.setCapacity(table.getCapacity());
        dto.setShopId(table.getShop() != null ? table.getShop().getId() : null);
        return dto;
    }

    public TableResponseDto toTableResponse(final Table table) {
        if (table == null) {
            return null;
        }
        final TableResponseDto dto = new TableResponseDto();
        dto.setId(table.getId());
        dto.setNumber(table.getNumber());
        dto.setCapacity(table.getCapacity());
        dto.setShopId(table.getShop() != null ? table.getShop().getId() : null);
        dto.setReservations(MappingUtils.mapList(table.getReservations(), reservationMapper::toReservationResponse));
        return dto;
    }

    public Table toTable(final TableCreateRequest request) {
        final Table table = new Table();
        table.setNumber(request.getNumber());
        table.setCapacity(request.getCapacity());
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            table.setShop(shop);
        }
        return table;
    }

    public Table toTable(final TableUpdateRequest request, final Table existing) {
        final Table table = new Table();
        table.setNumber(request.getNumber() != null ? request.getNumber() : existing.getNumber());
        table.setCapacity(request.getCapacity() != null ? request.getCapacity() : existing.getCapacity());
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            table.setShop(shop);
        }
        return table;
    }
}
