package com.coffeeshop.coffeeshop.mapper;

import java.util.Collection;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;

public final class MappingUtils {

    private MappingUtils() {
        throw new UnsupportedOperationException("This class should never be instantiated");
    }

    public static <T, R> List<R> mapList(final Collection<T> source, final Function<T, R> mapper) {
        if (source == null || source.isEmpty()) {
            return List.of();
        }
        return source.stream().map(mapper).collect(Collectors.toList());
    }
}
