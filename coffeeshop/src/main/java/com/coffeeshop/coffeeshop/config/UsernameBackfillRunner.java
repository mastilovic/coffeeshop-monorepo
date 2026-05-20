package com.coffeeshop.coffeeshop.config;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Component
public class UsernameBackfillRunner implements ApplicationRunner {

    private final UserRepository userRepository;

    public UsernameBackfillRunner(final UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public void run(final ApplicationArguments args) {
        final List<User> users = userRepository.findAll();
        final Set<String> taken = new HashSet<>();
        for (final User user : users) {
            if (user.getUsername() != null && !user.getUsername().isBlank()) {
                taken.add(user.getUsername().toLowerCase());
            }
        }

        boolean changed = false;
        for (final User user : users) {
            if (user.getUsername() != null && !user.getUsername().isBlank()) {
                continue;
            }
            final String base = deriveBase(user.getEmail());
            String candidate = base;
            int suffix = 1;
            while (taken.contains(candidate.toLowerCase())) {
                candidate = base + suffix;
                suffix++;
            }
            user.setUsername(candidate);
            taken.add(candidate.toLowerCase());
            changed = true;
        }
        if (changed) {
            userRepository.saveAll(users);
        }
    }

    private static String deriveBase(final String email) {
        if (email == null || email.isBlank()) {
            return "user";
        }
        final int at = email.indexOf('@');
        String local = at > 0 ? email.substring(0, at) : email;
        local = local.replaceAll("[^a-zA-Z0-9_]", "_");
        if (local.length() < 3) {
            local = local + "_user";
        }
        if (local.length() > 30) {
            local = local.substring(0, 30);
        }
        return local;
    }
}
