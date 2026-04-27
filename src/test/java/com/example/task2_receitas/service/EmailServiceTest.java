package com.example.task2_receitas.service;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class EmailServiceTest {

    @Test
    void deveEnviarEmail() {
        JavaMailSender sender = mock(JavaMailSender.class);
        EmailService service = new EmailService();

        try {
            var f = EmailService.class.getDeclaredField("mailSender");
            f.setAccessible(true);
            f.set(service, sender);
        } catch (Exception e) {
            fail();
        }

        service.enviar("Teste");

        verify(sender).send(any(SimpleMailMessage.class));
    }

    @Test
    void deveEnviarEmailComMensagemCorreta() {
        JavaMailSender sender = mock(JavaMailSender.class);
        EmailService service = new EmailService();

        try {
            var f = EmailService.class.getDeclaredField("mailSender");
            f.setAccessible(true);
            f.set(service, sender);
        } catch (Exception e) {
            fail();
        }

        service.enviar("Mensagem importante");

        ArgumentCaptor<SimpleMailMessage> captor =
                ArgumentCaptor.forClass(SimpleMailMessage.class);

        verify(sender).send(captor.capture());

        SimpleMailMessage mensagem = captor.getValue();

        assertNotNull(mensagem);
        assertTrue(mensagem.getText().contains("Mensagem importante"));
    }
}