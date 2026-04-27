package com.example.task2_receitas.model;

import org.junit.jupiter.api.Test;
import java.time.LocalDate;
import static org.junit.jupiter.api.Assertions.*;

class ReceitaTest {

    @Test
    void deveCriarReceitaComTodosOsCampos() {
        Receita receita = new Receita(
                1L, "Bolo", "Chocolate",
                LocalDate.of(2026, 3, 10),
                7.0, "DOCE"
        );

        assertEquals(1L, receita.getId());
        assertEquals("Bolo", receita.getNome());
        assertEquals("DOCE", receita.getTipoReceita());
    }

    @Test
    void deveDetectarCadastroOuEdicao() {
        Receita r = new Receita();

        assertNull(r.getId());

        r.setId(10L);

        assertNotNull(r.getId());
    }
}