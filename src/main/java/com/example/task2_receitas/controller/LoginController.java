package com.example.task2_receitas.controller;

import com.example.task2_receitas.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class LoginController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @GetMapping("/")
    public String login() {
        return "login";
    }

    @PostMapping("/login")
    public String validarLogin(@RequestParam String login,
                               @RequestParam String senha,
                               Model model) {

        var usuario = usuarioRepository.findByLoginAndSenha(login, senha);

        if (usuario.isPresent()) {
            return "redirect:/receitas";
        }

        model.addAttribute("erro", "Login inválido");
        return "login";
    }
}