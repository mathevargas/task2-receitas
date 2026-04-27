package com.example.task2_receitas.model;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class UsuarioTest {

    @Test
    void deveCriarUsuario() {
        Usuario u = new Usuario();
        u.setLogin("admin");
        u.setSenha("123");

        assertEquals("admin", u.getLogin());
        assertEquals("123", u.getSenha());
    }

    @Test
    void naoDeveAceitarLoginVazio() {
        Usuario u = new Usuario();
        u.setLogin("");

        assertTrue(u.getLogin().isEmpty());
    }
}