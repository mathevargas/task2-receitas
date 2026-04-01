package com.example.task2_receitas.repository;

import com.example.task2_receitas.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByLoginAndSenha(String login, String senha);
}