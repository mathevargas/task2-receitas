package com.example.task2_receitas.service;

import com.example.task2_receitas.model.Receita;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class PdfServiceTest {

    @Test
    void deveGerarPdf() {
        PdfService service = new PdfService();

        byte[] pdf = service.gerar(List.of(
                new Receita(1L, "Bolo", "Teste", LocalDate.now(), 10.0, "DOCE")
        ));

        assertTrue(pdf.length > 0);
    }

    @Test
    void deveGerarPdfComListaVazia() {
        PdfService service = new PdfService();

        byte[] pdf = service.gerar(List.of());

        assertNotNull(pdf);
    }

    @Test
    void deveGerarPdfComMultiplosDados() {
        PdfService service = new PdfService();

        byte[] pdf = service.gerar(List.of(
                new Receita(1L, "A", "x", LocalDate.now(), 1.0, "DOCE"),
                new Receita(2L, "B", "y", LocalDate.now(), 2.0, "SALGADA")
        ));

        assertTrue(pdf.length > 0);
    }
}