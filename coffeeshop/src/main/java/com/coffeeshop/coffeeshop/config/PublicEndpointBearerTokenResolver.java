package com.coffeeshop.coffeeshop.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpMethod;
import org.springframework.security.oauth2.server.resource.web.BearerTokenResolver;
import org.springframework.security.oauth2.server.resource.web.DefaultBearerTokenResolver;
import org.springframework.stereotype.Component;

@Component
public class PublicEndpointBearerTokenResolver implements BearerTokenResolver {

    private final BearerTokenResolver delegate = new DefaultBearerTokenResolver();

    /**
     * Skip JWT parsing only for endpoints that are {@code permitAll} in {@link SecurityConfiguration}.
     * Do not skip for authenticated GET routes such as {@code /api/v1/profile}.
     */
    private static boolean isPublicEndpoint(final HttpServletRequest request) {
        final String path = extractPath(request);
        final String method = request.getMethod();

        if (path.startsWith("/swagger")
                || path.startsWith("/swagger-ui")
                || path.startsWith("/v3/api-docs")
                || path.startsWith("/actuator")) {
            return true;
        }

        if (HttpMethod.GET.matches(method) && path.equals("/api/v1/shop")) {
            final String page = request.getParameter("page");
            return page == null || page.isBlank();
        }

        if (HttpMethod.GET.matches(method) && path.startsWith("/api/v1/")) {
            return !path.equals("/api/v1/profile")
                    && !path.equals("/api/v1/reservation-request")
                    && !path.startsWith("/api/v1/reservation-request/")
                    && !path.equals("/api/v1/shop/mine")
                    && !path.equals("/api/v1/shop");
        }

        if (HttpMethod.POST.matches(method)) {
            return switch (path) {
                case "/api/v1/auth/login", "/api/v1/auth/register",
                     "/api/v1/auth/refresh", "/api/v1/auth/logout" -> true;
                default -> false;
            };
        }

        return false;
    }

    private static String extractPath(final HttpServletRequest request) {
        final String uri = request.getRequestURI();
        final String contextPath = request.getContextPath();
        final String path = (contextPath != null && !contextPath.isEmpty())
                ? uri.substring(contextPath.length())
                : uri;
        if (path == null || path.isEmpty()) {
            return "/";
        }
        if (path.length() > 1 && path.endsWith("/")) {
            return path.substring(0, path.length() - 1);
        }
        return path;
    }

    @Override
    public String resolve(final HttpServletRequest request) {
        if (isPublicEndpoint(request)) {
            return null;
        }
        return delegate.resolve(request);
    }
}
