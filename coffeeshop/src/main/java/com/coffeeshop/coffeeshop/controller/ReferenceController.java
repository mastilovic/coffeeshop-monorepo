package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.reference.SerbiaCityCatalog;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/reference")
public class ReferenceController {

    private final SerbiaCityCatalog serbiaCityCatalog;

    public ReferenceController(final SerbiaCityCatalog serbiaCityCatalog) {
        this.serbiaCityCatalog = serbiaCityCatalog;
    }

    @GetMapping("/serbia-cities")
    public ResponseEntity<List<String>> getSerbiaCities(
            @RequestParam(required = false) final String q) {
        final List<String> result = q == null || q.isBlank()
                ? serbiaCityCatalog.getAll()
                : serbiaCityCatalog.search(q);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }
}
