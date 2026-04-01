package com.example.task2_receitas.controller;

import com.example.task2_receitas.model.Receita;
import com.example.task2_receitas.repository.ReceitaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class ReceitaController {

    @Autowired
    private ReceitaRepository receitaRepository;

    @GetMapping("/receitas")
    public String listar(Model model) {
        model.addAttribute("lista", receitaRepository.findAll());
        model.addAttribute("receita", new Receita());
        return "receitas";
    }

    @PostMapping("/receitas/salvar")
    public String salvar(@ModelAttribute Receita receita) {
        receitaRepository.save(receita);
        return "redirect:/receitas";
    }

    @GetMapping("/receitas/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        model.addAttribute("lista", receitaRepository.findAll());
        model.addAttribute("receita", receitaRepository.findById(id).get());
        return "receitas";
    }

    @GetMapping("/receitas/excluir/{id}")
    public String excluir(@PathVariable Long id) {
        receitaRepository.deleteById(id);
        return "redirect:/receitas";
    }
}