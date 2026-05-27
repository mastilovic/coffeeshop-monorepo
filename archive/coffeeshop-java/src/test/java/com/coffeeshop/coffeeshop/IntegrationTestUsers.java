package com.coffeeshop.coffeeshop;

public final class IntegrationTestUsers {

    private IntegrationTestUsers() {
    }

    public static String usernameFromEmail(final String email) {
        final int at = email.indexOf('@');
        String local = at > 0 ? email.substring(0, at) : email;
        local = local.replace('.', '_').replace('-', '_');
        if (local.length() < 3) {
            local = local + "_usr";
        }
        if (local.length() > 30) {
            local = local.substring(0, 30);
        }
        return local;
    }
}
