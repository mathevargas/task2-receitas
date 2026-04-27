package com.example.task2_receitas;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class Task2ReceitasApplication {

	public static void main(String[] args) {
		SpringApplication.run(Task2ReceitasApplication.class, args);
	}

}