CREATE TABLE categoria (
                           id BIGSERIAL PRIMARY KEY,
                           nome VARCHAR(100) NOT NULL,
                           descricao TEXT,
                           criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);