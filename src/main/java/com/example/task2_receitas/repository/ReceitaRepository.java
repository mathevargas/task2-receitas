package com.example.task2_receitas.repository;

import com.example.task2_receitas.model.Receita;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReceitaRepository extends JpaRepository<Receita, Long> {
}