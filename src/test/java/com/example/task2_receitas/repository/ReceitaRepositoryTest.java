package com.example.task2_receitas.repository;

import com.example.task2_receitas.model.Receita;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
class ReceitaRepositoryTest {

    @Autowired
    private ReceitaRepository repository;

    @Test
    void deveSalvarReceita() {
        Receita r = new Receita(null, "Bolo", "Teste", LocalDate.now(), 10.0, "DOCE");

        Receita salvo = repository.save(r);

        assertNotNull(salvo.getId());
    }

    @Test
    void deveBuscarTodas() {
        repository.save(new Receita(null, "A", "Teste", LocalDate.now(), 1.0, "DOCE"));

        List<Receita> lista = repository.findAll();

        assertFalse(lista.isEmpty());
    }

    @Test
    void deveDeletar() {
        Receita r = repository.save(new Receita(null, "X", "Teste", LocalDate.now(), 5.0, "DOCE"));

        repository.deleteById(r.getId());

        assertFalse(repository.findById(r.getId()).isPresent());
    }

    @Test
    void deveSalvarTipoCorreto() {
        Receita r = new Receita(null, "Pastel", "Teste", LocalDate.now(), 8.0, "SALGADA");

        Receita salvo = repository.save(r);

        assertEquals("SALGADA", salvo.getTipoReceita());
    }

    @Test
    void deveBuscarPorNomeParcial() {
        repository.save(new Receita(null, "Bolo Chocolate", "Teste", LocalDate.now(), 10.0, "DOCE"));

        boolean encontrou = repository.findAll()
                .stream()
                .anyMatch(r -> r.getNome().contains("Bolo"));

        assertTrue(encontrou);
    }
}