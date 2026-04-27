package com.example.task2_receitas.controller;

import com.example.task2_receitas.model.Receita;
import com.example.task2_receitas.repository.ReceitaRepository;
import com.example.task2_receitas.service.EmailService;
import com.example.task2_receitas.service.PdfService;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Sort;
import org.springframework.ui.Model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ReceitaControllerTest {

    @Test
    void deveListarReceitas() {
        ReceitaRepository repo = mock(ReceitaRepository.class);
        EmailService email = mock(EmailService.class);
        PdfService pdf = mock(PdfService.class);

        when(repo.findAll(any(Sort.class))).thenReturn(new ArrayList<>());

        ReceitaController controller = new ReceitaController();

        try {
            var f1 = ReceitaController.class.getDeclaredField("receitaRepository");
            f1.setAccessible(true);
            f1.set(controller, repo);

            var f2 = ReceitaController.class.getDeclaredField("emailService");
            f2.setAccessible(true);
            f2.set(controller, email);

            var f3 = ReceitaController.class.getDeclaredField("pdfService");
            f3.setAccessible(true);
            f3.set(controller, pdf);
        } catch (Exception e) {
            fail();
        }

        Model model = mock(Model.class);

        String view = controller.listar(null, null, null, null, model);

        assertEquals("receitas", view);
    }

    @Test
    void deveSalvarReceita() {
        ReceitaRepository repo = mock(ReceitaRepository.class);
        EmailService email = mock(EmailService.class);
        PdfService pdf = mock(PdfService.class);

        ReceitaController controller = new ReceitaController();

        try {
            var f1 = ReceitaController.class.getDeclaredField("receitaRepository");
            f1.setAccessible(true);
            f1.set(controller, repo);

            var f2 = ReceitaController.class.getDeclaredField("emailService");
            f2.setAccessible(true);
            f2.set(controller, email);

            var f3 = ReceitaController.class.getDeclaredField("pdfService");
            f3.setAccessible(true);
            f3.set(controller, pdf);
        } catch (Exception e) {
            fail();
        }

        Receita r = new Receita();
        r.setNome("Bolo");
        r.setDataRegistro(LocalDate.now());

        controller.salvar(r);

        verify(repo).save(any());
    }

    @Test
    void deveExcluirReceita() {
        ReceitaRepository repo = mock(ReceitaRepository.class);
        EmailService email = mock(EmailService.class);
        PdfService pdf = mock(PdfService.class);

        ReceitaController controller = new ReceitaController();

        try {
            var f1 = ReceitaController.class.getDeclaredField("receitaRepository");
            f1.setAccessible(true);
            f1.set(controller, repo);

            var f2 = ReceitaController.class.getDeclaredField("emailService");
            f2.setAccessible(true);
            f2.set(controller, email);

            var f3 = ReceitaController.class.getDeclaredField("pdfService");
            f3.setAccessible(true);
            f3.set(controller, pdf);
        } catch (Exception e) {
            fail();
        }

        controller.excluir(1L);

        verify(repo).deleteById(1L);
    }

    @Test
    void deveFiltrarPorNome() {
        ReceitaRepository repo = mock(ReceitaRepository.class);
        EmailService email = mock(EmailService.class);
        PdfService pdf = mock(PdfService.class);

        Receita r = new Receita();
        r.setNome("Bolo");

        when(repo.findAll(any(Sort.class))).thenReturn(List.of(r));

        ReceitaController controller = new ReceitaController();

        try {
            var f1 = ReceitaController.class.getDeclaredField("receitaRepository");
            f1.setAccessible(true);
            f1.set(controller, repo);

            var f2 = ReceitaController.class.getDeclaredField("emailService");
            f2.setAccessible(true);
            f2.set(controller, email);

            var f3 = ReceitaController.class.getDeclaredField("pdfService");
            f3.setAccessible(true);
            f3.set(controller, pdf);
        } catch (Exception e) {
            fail();
        }

        Model model = mock(Model.class);

        controller.listar(null, "Bolo", null, null, model);

        verify(repo).findAll(any(Sort.class));
    }


    @Test
    void naoDeveSalvarReceitaSemNome() {
        ReceitaRepository repo = mock(ReceitaRepository.class);
        EmailService email = mock(EmailService.class);
        PdfService pdf = mock(PdfService.class);

        ReceitaController controller = new ReceitaController();

        try {
            var f1 = ReceitaController.class.getDeclaredField("receitaRepository");
            f1.setAccessible(true);
            f1.set(controller, repo);

            var f2 = ReceitaController.class.getDeclaredField("emailService");
            f2.setAccessible(true);
            f2.set(controller, email);

            var f3 = ReceitaController.class.getDeclaredField("pdfService");
            f3.setAccessible(true);
            f3.set(controller, pdf);
        } catch (Exception e) {
            fail();
        }

        Receita r = new Receita();
        r.setDataRegistro(LocalDate.now());
        r.setNome("");

        controller.salvar(r);

        verify(repo, never()).save(any());
    }

    @Test
    void deveSalvarReceitaComDataValida() {
        ReceitaRepository repo = mock(ReceitaRepository.class);
        EmailService email = mock(EmailService.class);
        PdfService pdf = mock(PdfService.class);

        ReceitaController controller = new ReceitaController();

        try {
            var f1 = ReceitaController.class.getDeclaredField("receitaRepository");
            f1.setAccessible(true);
            f1.set(controller, repo);

            var f2 = ReceitaController.class.getDeclaredField("emailService");
            f2.setAccessible(true);
            f2.set(controller, email);

            var f3 = ReceitaController.class.getDeclaredField("pdfService");
            f3.setAccessible(true);
            f3.set(controller, pdf);
        } catch (Exception e) {
            fail();
        }

        Receita r = new Receita();
        r.setNome("Teste");
        r.setDataRegistro(LocalDate.now());

        controller.salvar(r);

        verify(repo).save(any());
    }
}