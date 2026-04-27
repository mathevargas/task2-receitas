package com.example.task2_receitas.service;

import com.example.task2_receitas.model.Receita;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class PdfService {

    public byte[] gerar(List<Receita> lista) {

        ByteArrayOutputStream out = new ByteArrayOutputStream();

        PdfWriter writer = new PdfWriter(out);
        PdfDocument pdf = new PdfDocument(writer);
        Document document = new Document(pdf);

        document.add(new Paragraph("Lista de Receitas"));


        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        float[] colunas = {150, 200, 100, 100, 100};
        Table table = new Table(colunas);

        table.addCell("Nome");
        table.addCell("Descrição");
        table.addCell("Data");
        table.addCell("Custo");
        table.addCell("Tipo");

        for (Receita r : lista) {

            String dataFormatada = r.getDataRegistro().format(formatter);

            table.addCell(r.getNome());
            table.addCell(r.getDescricao());
            table.addCell(dataFormatada); // 🔥 AQUI FOI CORRIGIDO
            table.addCell("R$ " + String.format("%.2f", r.getCusto()));
            table.addCell(r.getTipoReceita());
        }

        document.add(table);
        document.close();

        return out.toByteArray();
    }
}