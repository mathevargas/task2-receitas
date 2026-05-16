CREATE TABLE IF NOT EXISTS usuario (
                                       id BIGSERIAL PRIMARY KEY,
                                       nome VARCHAR(100),
    login VARCHAR(50),
    senha VARCHAR(100),
    situacao VARCHAR(20)
    );

CREATE TABLE IF NOT EXISTS receita (
                                       id BIGSERIAL PRIMARY KEY,
                                       nome VARCHAR(100),
    descricao TEXT,
    data_registro DATE,
    custo DOUBLE PRECISION,
    tipo_receita VARCHAR(20)
    );