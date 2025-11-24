-- 1) Criar schema
CREATE SCHEMA IF NOT EXISTS empresa;

-- 2) Tabela USUARIO
CREATE TABLE empresa.usuario (
    id_usuario        SERIAL PRIMARY KEY,
    nome              VARCHAR(100) NOT NULL,
    email             VARCHAR(150) UNIQUE NOT NULL,
    cpf               CHAR(11) UNIQUE NOT NULL,
    senha_hash        VARCHAR(255) NOT NULL,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3) Tabela SMARTFONE
CREATE TABLE empresa.smartfone (
    imei              CHAR(15) PRIMARY KEY,
    marca             VARCHAR(50) NOT NULL,
    modelo            VARCHAR(50) NOT NULL,
    id_usuario        INT,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_smartfone_usuario FOREIGN KEY (id_usuario)
        REFERENCES empresa.usuario (id_usuario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- 4) Tabela GERENTE
CREATE TABLE empresa.gerente (
    cpf               CHAR(11) PRIMARY KEY,
    nome              VARCHAR(100) NOT NULL,
    telefone          VARCHAR(20),
    senha_hash        VARCHAR(255) NOT NULL,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5) Tabela POLICIA
CREATE TABLE empresa.policia (
    id_policia        SERIAL PRIMARY KEY,
    nome              VARCHAR(100) NOT NULL,
    departamento      VARCHAR(80),
    telefone          VARCHAR(20),
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6) Tabela OPERADORA
CREATE TABLE empresa.operadora (
    cnpj              CHAR(14) PRIMARY KEY,
    nome_operadora    VARCHAR(120) NOT NULL,
    telefone          VARCHAR(20),
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7) Tabela CHAMADO (usuario abre chamado para gerente)
CREATE TABLE empresa.chamado (
    id_chamado        SERIAL PRIMARY KEY,
    id_usuario        INT NOT NULL,
    cpf_gerente       CHAR(11) NOT NULL,
    data_chamado      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    tipo_chamada      VARCHAR(10) NOT NULL CHECK (tipo_chamada IN ('web','ewb')),
    observacao        TEXT,
    CONSTRAINT fk_chamado_usuario FOREIGN KEY (id_usuario)
        REFERENCES empresa.usuario (id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_chamado_gerente FOREIGN KEY (cpf_gerente)
        REFERENCES empresa.gerente (cpf)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 8) Tabela RETOMADA (gerente aciona polícia / ocorrência)
CREATE TABLE empresa.retomada (
    numero_ocorrencia SERIAL PRIMARY KEY,
    cpf_gerente       CHAR(11) NOT NULL,
    id_policia        INT NOT NULL,
    data_ocorrencia   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    descricao         TEXT,
    CONSTRAINT fk_retomada_gerente FOREIGN KEY (cpf_gerente)
        REFERENCES empresa.gerente (cpf)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_retomada_policia FOREIGN KEY (id_policia)
        REFERENCES empresa.policia (id_policia)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 9) Tabela LOCALIZACAO (operadora localiza smartfone)
CREATE TABLE empresa.localizacao (
    id_localizacao    SERIAL PRIMARY KEY,
    imei              CHAR(15) NOT NULL,
    cnpj_operadora    CHAR(14) NOT NULL,
    satelite_torre    VARCHAR(150),
    latitude          NUMERIC(10,7),   -- opcional: lat/lon mais precisos
    longitude         NUMERIC(10,7),
    data_localizacao  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loc_imei FOREIGN KEY (imei)
        REFERENCES empresa.smartfone (imei)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_loc_operadora FOREIGN KEY (cnpj_operadora)
        REFERENCES empresa.operadora (cnpj)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 10) Índices úteis (opcionais)
CREATE INDEX IF NOT EXISTS idx_usuario_cpf ON empresa.usuario (cpf);
CREATE INDEX IF NOT EXISTS idx_smartfone_usuario ON empresa.smartfone (id_usuario);
CREATE INDEX IF NOT EXISTS idx_localizacao_imei ON empresa.localizacao (imei);
CREATE INDEX IF NOT EXISTS idx_chamado_usuario ON empresa.chamado (id_usuario);

--------------------------------------------------------------------------------
-- Exemplos de INSERTs (dados de demonstração)
--------------------------------------------------------------------------------
-- inserir usuarios
INSERT INTO empresa.usuario (nome, email, cpf, senha_hash)
VALUES ('Maria Silva', 'maria@example.com', '12345678901', 'hash_exemplo_1'),
       ('João Souza', 'joao@example.com', '98765432100', 'hash_exemplo_2');

-- inserir operadora
INSERT INTO empresa.operadora (cnpj, nome_operadora, telefone)
VALUES ('11122233344455', 'OperadoraX', '+55 61 9999-0000');

-- inserir gerente
INSERT INTO empresa.gerente (cpf, nome, telefone, senha_hash)
VALUES ('55566677788', 'Carlos Gerente', '+55 61 98888-1111', 'hash_gerente');

-- inserir policia
INSERT INTO empresa.policia (nome, departamento, telefone)
VALUES ('Policial A', 'DETRAN', '+55 61 3333-4444');

-- inserir smartfones
INSERT INTO empresa.smartfone (imei, marca, modelo, id_usuario)
VALUES ('111111111111111', 'MarcaA', 'Modelo1', 1),
       ('222222222222222', 'MarcaB', 'ModeloX', 2);

-- inserir localizacao
INSERT INTO empresa.localizacao (imei, cnpj_operadora, satelite_torre, latitude, longitude)
VALUES ('111111111111111', '11122233344455', 'Torre A', -15.793889, -47.882778);

-- inserir chamado (usuario abre chamado para gerente)
INSERT INTO empresa.chamado (id_usuario, cpf_gerente, tipo_chamada, observacao)
VALUES (1, '55566677788', 'web', 'Smartfone roubado, pede localização');

-- inserir retomada (gerente aciona policia)
INSERT INTO empresa.retomada (cpf_gerente, id_policia, descricao)
VALUES ('55566677788', 1, 'Encaminhar ocorrência para investigação');

--------------------------------------------------------------------------------
-- Consultas de teste
--------------------------------------------------------------------------------
-- ver usuários
SELECT * FROM empresa.usuario;

-- ver smartfones com dono
SELECT s.*, u.nome AS proprietario
FROM empresa.smartfone s
LEFT JOIN empresa.usuario u ON s.id_usuario = u.id_usuario;

-- ver localizações recentes
SELECT * FROM empresa.localizacao ORDER BY data_localizacao DESC LIMIT 10;
