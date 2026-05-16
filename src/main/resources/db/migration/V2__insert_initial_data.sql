INSERT INTO usuario (nome, login, senha, situacao)
VALUES ('Admin', 'admin', 'admin@123', 'ATIVO');

INSERT INTO receita (nome, descricao, data_registro, custo, tipo_receita) VALUES
                                                                              ('Coxinha', 'Coxinha de frango', CURRENT_DATE, 5.50, 'salgada'),
                                                                              ('Brigadeiro', 'Doce de chocolate', CURRENT_DATE, 3.00, 'doce'),
                                                                              ('Pastel', 'Pastel de carne', CURRENT_DATE, 6.00, 'salgada'),
                                                                              ('Beijinho', 'Doce de coco', CURRENT_DATE, 3.50, 'doce'),
                                                                              ('Esfirra', 'Esfirra de carne', CURRENT_DATE, 4.50, 'salgada'),
                                                                              ('Quindim', 'Doce de gema', CURRENT_DATE, 4.00, 'doce'),
                                                                              ('Empada', 'Empada de frango', CURRENT_DATE, 5.00, 'salgada'),
                                                                              ('Pudim', 'Pudim de leite', CURRENT_DATE, 6.50, 'doce'),
                                                                              ('Kibe', 'Kibe frito', CURRENT_DATE, 4.50, 'salgada'),
                                                                              ('Bolo', 'Bolo de chocolate', CURRENT_DATE, 7.00, 'doce');