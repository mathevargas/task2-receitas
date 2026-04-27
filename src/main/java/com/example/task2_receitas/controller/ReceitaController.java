package com.example.task2_receitas.controller;

import com.example.task2_receitas.model.Receita;
import com.example.task2_receitas.repository.ReceitaRepository;
import com.example.task2_receitas.service.EmailService;
import com.example.task2_receitas.service.PdfService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
public class ReceitaController {

    @Autowired
    private ReceitaRepository receitaRepository;

    @Autowired
    private EmailService emailService;

    @Autowired
    private PdfService pdfService;

    private List<Receita> buscarOrdenado() {
        return receitaRepository.findAll(
                org.springframework.data.domain.Sort.by("id").ascending()
        );
    }

    @GetMapping("/receitas")
    public String listar(
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) String nome,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim,
            Model model) {

        List<Receita> lista = buscarOrdenado();

        if (tipo != null && !tipo.isEmpty()) {
            lista = lista.stream()
                    .filter(r -> r.getTipoReceita().equalsIgnoreCase(tipo))
                    .toList();
        }

        if (nome != null && !nome.isEmpty()) {
            lista = lista.stream()
                    .filter(r -> r.getNome().toLowerCase().contains(nome.toLowerCase()))
                    .toList();
        }

        if (dataInicio != null && !dataInicio.isEmpty()) {
            LocalDate inicio = LocalDate.parse(dataInicio);
            lista = lista.stream()
                    .filter(r -> !r.getDataRegistro().isBefore(inicio))
                    .toList();
        }

        if (dataFim != null && !dataFim.isEmpty()) {
            LocalDate fim = LocalDate.parse(dataFim);
            lista = lista.stream()
                    .filter(r -> !r.getDataRegistro().isAfter(fim))
                    .toList();
        }

        model.addAttribute("lista", lista);
        model.addAttribute("receita", new Receita());
        model.addAttribute("tipo", tipo);
        model.addAttribute("nome", nome);
        model.addAttribute("dataInicio", dataInicio);
        model.addAttribute("dataFim", dataFim);

        return "receitas";
    }

    @GetMapping("/receitas/pdf")
    public ResponseEntity<ByteArrayResource> gerarPdf(
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) String nome,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim) {

        List<Receita> lista = buscarOrdenado();

        if (tipo != null && !tipo.isEmpty()) {
            lista = lista.stream()
                    .filter(r -> r.getTipoReceita().equalsIgnoreCase(tipo))
                    .toList();
        }

        if (nome != null && !nome.isEmpty()) {
            lista = lista.stream()
                    .filter(r -> r.getNome().toLowerCase().contains(nome.toLowerCase()))
                    .toList();
        }

        if (dataInicio != null && !dataInicio.isEmpty()) {
            LocalDate inicio = LocalDate.parse(dataInicio);
            lista = lista.stream()
                    .filter(r -> !r.getDataRegistro().isBefore(inicio))
                    .toList();
        }

        if (dataFim != null && !dataFim.isEmpty()) {
            LocalDate fim = LocalDate.parse(dataFim);
            lista = lista.stream()
                    .filter(r -> !r.getDataRegistro().isAfter(fim))
                    .toList();
        }

        byte[] pdf = pdfService.gerar(lista);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=receitas.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(new ByteArrayResource(pdf));
    }

    @PostMapping("/receitas/salvar")
    public String salvar(@ModelAttribute Receita receita) {


        if (receita.getNome() == null || receita.getNome().trim().isEmpty()) {
            return "redirect:/receitas";
        }

        boolean isNovo = (receita.getId() == null);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        String mensagem;

        if (isNovo) {

            receitaRepository.save(receita);

            mensagem = "Receita cadastrada:\n" +
                    "Nome: " + receita.getNome() + "\n" +
                    "Descrição: " + receita.getDescricao() + "\n" +
                    "Data: " + receita.getDataRegistro().format(formatter) + "\n" +
                    "Custo: R$ " + String.format("%.2f", receita.getCusto()) + "\n" +
                    "Tipo: " + receita.getTipoReceita();

        } else {

            Receita antiga = receitaRepository.findById(receita.getId()).get();

            StringBuilder alteracoes = new StringBuilder();

            if (!antiga.getNome().equals(receita.getNome())) {
                alteracoes.append("Nome: ").append(antiga.getNome())
                        .append(" → ").append(receita.getNome()).append("\n");
            }

            if (!antiga.getDescricao().equals(receita.getDescricao())) {
                alteracoes.append("Descrição: ").append(antiga.getDescricao())
                        .append(" → ").append(receita.getDescricao()).append("\n");
            }

            if (!antiga.getDataRegistro().equals(receita.getDataRegistro())) {
                alteracoes.append("Data: ")
                        .append(antiga.getDataRegistro().format(formatter))
                        .append(" → ")
                        .append(receita.getDataRegistro().format(formatter))
                        .append("\n");
            }

            if (!antiga.getCusto().equals(receita.getCusto())) {
                alteracoes.append("Custo: R$ ")
                        .append(String.format("%.2f", antiga.getCusto()))
                        .append(" → R$ ")
                        .append(String.format("%.2f", receita.getCusto()))
                        .append("\n");
            }

            if (!antiga.getTipoReceita().equals(receita.getTipoReceita())) {
                alteracoes.append("Tipo: ").append(antiga.getTipoReceita())
                        .append(" → ").append(receita.getTipoReceita()).append("\n");
            }

            receitaRepository.save(receita);

            mensagem = "Receita editada: " + receita.getNome() + "\n\nAlterações:\n" +
                    (alteracoes.length() > 0 ? alteracoes.toString() : "Nenhuma alteração detectada");
        }

        emailService.enviar(mensagem);

        return "redirect:/receitas";
    }

    @GetMapping("/receitas/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        model.addAttribute("lista", buscarOrdenado());
        model.addAttribute("receita", receitaRepository.findById(id).get());
        return "receitas";
    }

    @GetMapping("/receitas/excluir/{id}")
    public String excluir(@PathVariable Long id) {
        receitaRepository.deleteById(id);
        return "redirect:/receitas";
    }
}