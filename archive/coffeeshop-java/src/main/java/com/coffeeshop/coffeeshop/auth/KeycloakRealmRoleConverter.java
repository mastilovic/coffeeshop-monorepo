package com.coffeeshop.coffeeshop.auth;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@Component
public class KeycloakRealmRoleConverter implements Converter<Jwt, Collection<GrantedAuthority>> {

    @Override
    @SuppressWarnings("unchecked")
    public Collection<GrantedAuthority> convert(final Jwt jwt) {
        final Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");
        if (realmAccess == null) {
            return List.of();
        }
        final Object rolesObj = realmAccess.get("roles");
        if (!(rolesObj instanceof final Collection<?> roles)) {
            return List.of();
        }
        final List<GrantedAuthority> result = new ArrayList<>();
        for (final Object r : roles) {
            if (r != null) {
                final String role = r.toString().toUpperCase().replace('-', '_');
                result.add(new SimpleGrantedAuthority("ROLE_" + role));
            }
        }
        return result;
    }
}
