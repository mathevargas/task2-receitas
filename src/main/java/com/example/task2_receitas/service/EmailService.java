package com.example.task2_receitas.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Async
    public void enviar(String mensagem) {
        try {
            SimpleMailMessage mail = new SimpleMailMessage();
            mail.setTo("matheus.vargas@universo.univates.br");
            mail.setSubject("Sistema de Receitas");
            mail.setText(mensagem);

            mailSender.send(mail);
        } catch (Exception e) {
            System.out.println("Erro ao enviar email");
        }
    }
}