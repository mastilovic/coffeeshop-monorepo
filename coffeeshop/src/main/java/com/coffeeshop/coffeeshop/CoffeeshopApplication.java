package com.coffeeshop.coffeeshop;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class CoffeeshopApplication {

	public static void main(String[] args) {
		SpringApplication.run(CoffeeshopApplication.class, args);
	}

}
