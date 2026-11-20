-- ============================================================
-- CitizenTech - Global Solution 2026/2 - FIAP
-- Modelo relacional (Oracle) - Zeladoria colaborativa
-- Importar em: Oracle SQL Developer Data Modeler
--   File > Import > DDL File (dialeto Oracle Database)
-- ============================================================

-- ------------------------------------------------------------
-- ENDERECOS
-- ------------------------------------------------------------
CREATE TABLE enderecos (
    endereco_id          INTEGER        NOT NULL,
    endereco_logradouro  VARCHAR2(100)  NOT NULL,
    endereco_numero      VARCHAR2(10),
    endereco_complemento VARCHAR2(50),
    endereco_bairro      VARCHAR2(50)   NOT NULL,
    endereco_cidade      VARCHAR2(50)   NOT NULL,
    endereco_estado      CHAR(2)        NOT NULL,
    endereco_cep         CHAR(8)        NOT NULL,
    endereco_latitude    NUMBER(9,6),
    endereco_longitude   NUMBER(9,6)
);

ALTER TABLE enderecos ADD CONSTRAINT enderecos_pk PRIMARY KEY (endereco_id);

-- ------------------------------------------------------------
-- USUARIOS (cidadaos)
-- ------------------------------------------------------------
CREATE TABLE usuarios (
    usuario_id            INTEGER       NOT NULL,
    usuario_nome          VARCHAR2(100) NOT NULL,
    usuario_email         VARCHAR2(100) NOT NULL,
    usuario_senha         VARCHAR2(255) NOT NULL,
    usuario_telefone      VARCHAR2(20),
    usuario_data_cadastro DATE          NOT NULL,
    endereco_id           INTEGER       NOT NULL
);

ALTER TABLE usuarios ADD CONSTRAINT usuarios_pk PRIMARY KEY (usuario_id);
ALTER TABLE usuarios ADD CONSTRAINT usuarios_email_uk UNIQUE (usuario_email);

-- ------------------------------------------------------------
-- FUNCIONARIOS (gestores / equipe responsavel)
-- ------------------------------------------------------------
CREATE TABLE funcionarios (
    funcionario_id       INTEGER       NOT NULL,
    funcionario_nome     VARCHAR2(100) NOT NULL,
    funcionario_setor    VARCHAR2(50)  NOT NULL,
    funcionario_cargo    VARCHAR2(50)  NOT NULL,
    funcionario_email    VARCHAR2(100) NOT NULL,
    funcionario_senha    VARCHAR2(255) NOT NULL,
    funcionario_telefone VARCHAR2(20)
);

ALTER TABLE funcionarios ADD CONSTRAINT funcionarios_pk PRIMARY KEY (funcionario_id);
ALTER TABLE funcionarios ADD CONSTRAINT funcionarios_email_uk UNIQUE (funcionario_email);

-- ------------------------------------------------------------
-- CATEGORIAS (tipo do problema a ser resolvido)
-- ------------------------------------------------------------
CREATE TABLE categorias (
    categoria_id         INTEGER       NOT NULL,
    categoria_nome       VARCHAR2(50)  NOT NULL,
    categoria_descricao  VARCHAR2(200),
    categoria_prazo_dias NUMBER(3)     NOT NULL
);

ALTER TABLE categorias ADD CONSTRAINT categorias_pk PRIMARY KEY (categoria_id);
ALTER TABLE categorias ADD CONSTRAINT categorias_nome_uk UNIQUE (categoria_nome);

-- ------------------------------------------------------------
-- SOLICITACOES (problema reportado pelo cidadao)
-- status: A=Aberta, E=Em andamento, C=Concluida, X=Cancelada
-- prioridade: B=Baixa, M=Media, A=Alta
-- ------------------------------------------------------------
CREATE TABLE solicitacoes (
    solicitacao_id             INTEGER        NOT NULL,
    solicitacao_titulo         VARCHAR2(100)  NOT NULL,
    solicitacao_descricao      VARCHAR2(500)  NOT NULL,
    solicitacao_status         CHAR(1)        NOT NULL,
    solicitacao_prioridade     CHAR(1)        NOT NULL,
    solicitacao_data_abertura  DATE           NOT NULL,
    solicitacao_data_conclusao DATE,
    usuario_id                 INTEGER        NOT NULL,
    funcionario_id             INTEGER,
    categoria_id               INTEGER        NOT NULL,
    endereco_id                INTEGER        NOT NULL
);

ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_pk PRIMARY KEY (solicitacao_id);
ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_status_ck
    CHECK (solicitacao_status IN ('A','E','C','X'));
ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_prioridade_ck
    CHECK (solicitacao_prioridade IN ('B','M','A'));

-- ------------------------------------------------------------
-- ANDAMENTOS (historico de atualizacoes da solicitacao)
-- ------------------------------------------------------------
CREATE TABLE andamentos (
    andamento_id        INTEGER       NOT NULL,
    andamento_descricao VARCHAR2(300) NOT NULL,
    andamento_status    CHAR(1)       NOT NULL,
    andamento_data      DATE          NOT NULL,
    solicitacao_id      INTEGER       NOT NULL,
    funcionario_id      INTEGER       NOT NULL
);

ALTER TABLE andamentos ADD CONSTRAINT andamentos_pk PRIMARY KEY (andamento_id);
ALTER TABLE andamentos ADD CONSTRAINT andamentos_status_ck
    CHECK (andamento_status IN ('A','E','C','X'));

-- ------------------------------------------------------------
-- ANEXOS (fotos / evidencias da solicitacao)
-- ------------------------------------------------------------
CREATE TABLE anexos (
    anexo_id       INTEGER       NOT NULL,
    anexo_nome     VARCHAR2(100) NOT NULL,
    anexo_tipo     VARCHAR2(30)  NOT NULL,
    anexo_url      VARCHAR2(300) NOT NULL,
    solicitacao_id INTEGER       NOT NULL
);

ALTER TABLE anexos ADD CONSTRAINT anexos_pk PRIMARY KEY (anexo_id);

-- ------------------------------------------------------------
-- AVALIACOES (feedback do cidadao apos conclusao - mede impacto)
-- ------------------------------------------------------------
CREATE TABLE avaliacoes (
    avaliacao_id         INTEGER       NOT NULL,
    avaliacao_nota       NUMBER(1)     NOT NULL,
    avaliacao_comentario VARCHAR2(300),
    avaliacao_data       DATE          NOT NULL,
    solicitacao_id       INTEGER       NOT NULL
);

ALTER TABLE avaliacoes ADD CONSTRAINT avaliacoes_pk PRIMARY KEY (avaliacao_id);
ALTER TABLE avaliacoes ADD CONSTRAINT avaliacoes_solicitacao_uk UNIQUE (solicitacao_id);
ALTER TABLE avaliacoes ADD CONSTRAINT avaliacoes_nota_ck CHECK (avaliacao_nota BETWEEN 1 AND 5);

-- ============================================================
-- FOREIGN KEYS
-- ============================================================
ALTER TABLE usuarios ADD CONSTRAINT usuarios_enderecos_fk
    FOREIGN KEY (endereco_id) REFERENCES enderecos (endereco_id);

ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_usuarios_fk
    FOREIGN KEY (usuario_id) REFERENCES usuarios (usuario_id);

ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_funcionarios_fk
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios (funcionario_id);

ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_categorias_fk
    FOREIGN KEY (categoria_id) REFERENCES categorias (categoria_id);

ALTER TABLE solicitacoes ADD CONSTRAINT solicitacoes_enderecos_fk
    FOREIGN KEY (endereco_id) REFERENCES enderecos (endereco_id);

ALTER TABLE andamentos ADD CONSTRAINT andamentos_solicitacoes_fk
    FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes (solicitacao_id);

ALTER TABLE andamentos ADD CONSTRAINT andamentos_funcionarios_fk
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios (funcionario_id);

ALTER TABLE anexos ADD CONSTRAINT anexos_solicitacoes_fk
    FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes (solicitacao_id);

ALTER TABLE avaliacoes ADD CONSTRAINT avaliacoes_solicitacoes_fk
    FOREIGN KEY (solicitacao_id) REFERENCES solicitacoes (solicitacao_id);
