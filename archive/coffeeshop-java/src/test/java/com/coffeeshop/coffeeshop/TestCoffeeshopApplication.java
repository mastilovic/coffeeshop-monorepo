package com.coffeeshop.coffeeshop;

import org.springframework.boot.SpringApplication;

public class TestCoffeeshopApplication {

	public static void main(String[] args) {
		SpringApplication.from(CoffeeshopApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
