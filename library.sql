-- 1. CRIAÇÃO DAS TABELAS

-- Tabela de usuários (Clientes da Biblioteca)
CREATE TABLE Usuarios (
    UsuarioID INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefone VARCHAR(15),
    DataCadastro DATE DEFAULT CURRENT_DATE
);

-- Tabela de autores
CREATE TABLE Autores (
    AutorID INT PRIMARY KEY AUTO_INCREMENT,
    NomeAutor VARCHAR(100) NOT NULL
);

-- Tabela de livros
CREATE TABLE Livros (
    LivroID INT PRIMARY KEY AUTO_INCREMENT,
    Titulo VARCHAR(200) NOT NULL,
    Genero VARCHAR(50),
    AnoPublicacao INT,
    AutorID INT,
    QuantidadeTotal INT NOT NULL,
    QuantidadeDisponivel INT NOT NULL,
    FOREIGN KEY (AutorID) REFERENCES Autores(AutorID)
);

-- Tabela de aluguéis
CREATE TABLE Alugueis (
    AluguelID INT PRIMARY KEY AUTO_INCREMENT,
    UsuarioID INT,
    LivroID INT,
    DataAluguel DATE NOT NULL,
    DataDevolucao DATE,
    Status VARCHAR(20) DEFAULT 'Em andamento',
    FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (LivroID) REFERENCES Livros(LivroID)
);

-- Tabela de multas
CREATE TABLE Multas (
    MultaID INT PRIMARY KEY AUTO_INCREMENT,
    AluguelID INT,
    ValorMulta DECIMAL(10,2) NOT NULL,
    Pago BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (AluguelID) REFERENCES Alugueis(AluguelID)
);

-- 2. INSERÇÃO DE DADOS INICIAIS

-- Inserindo autores
INSERT INTO Autores (NomeAutor) VALUES 
('J.K. Rowling'),
('George R.R. Martin'),
('J.R.R. Tolkien'),
('Agatha Christie');

-- Inserindo livros
INSERT INTO Livros (Titulo, Genero, AnoPublicacao, AutorID, QuantidadeTotal, QuantidadeDisponivel) VALUES 
('Harry Potter e a Pedra Filosofal', 'Fantasia', 1997, 1, 10, 10),
('Game of Thrones', 'Fantasia', 1996, 2, 7, 7),
('O Senhor dos Anéis', 'Fantasia', 1954, 3, 5, 5),
('Assassinato no Expresso do Oriente', 'Mistério', 1934, 4, 8, 8);

-- Inserindo usuários
INSERT INTO Usuarios (Nome, Email, Telefone) VALUES 
('Ana Silva', 'ana.silva@gmail.com', '123456789'),
('João Oliveira', 'joao.oliveira@gmail.com', '987654321'),
('Mariana Costa', 'mariana.costa@gmail.com', '555123456');

-- Inserindo aluguéis
INSERT INTO Alugueis (UsuarioID, LivroID, DataAluguel) VALUES 
(1, 1, '2025-01-01'),
(2, 2, '2025-01-05'),
(3, 3, '2025-01-10');

-- Inserindo multas
INSERT INTO Multas (AluguelID, ValorMulta, Pago) VALUES 
(1, 5.00, FALSE),
(2, 10.00, TRUE);

-- 3. CONSULTAS IMPORTANTES

-- 3.1. Listar todos os usuários e seus aluguéis ativos
SELECT U.Nome, L.Titulo, A.DataAluguel, A.Status
FROM Usuarios U
JOIN Alugueis A ON U.UsuarioID = A.UsuarioID
JOIN Livros L ON A.LivroID = L.LivroID
WHERE A.Status = 'Em andamento';

-- 3.2. Livros mais alugados
SELECT L.Titulo, COUNT(A.AluguelID) AS TotalAlugueis
FROM Livros L
JOIN Alugueis A ON L.LivroID = A.LivroID
GROUP BY L.LivroID
ORDER BY TotalAlugueis DESC;

-- 3.3. Multas pendentes por usuário
SELECT U.Nome, SUM(M.ValorMulta) AS TotalMultas
FROM Usuarios U
JOIN Alugueis A ON U.UsuarioID = A.UsuarioID
JOIN Multas M ON A.AluguelID = M.AluguelID
WHERE M.Pago = FALSE
GROUP BY U.UsuarioID;

-- 4. VIEWS

-- View para verificar status dos aluguéis
CREATE VIEW View_StatusAlugueis AS
SELECT U.Nome AS Usuario, L.Titulo AS Livro, A.DataAluguel, A.DataDevolucao, A.Status
FROM Usuarios U
JOIN Alugueis A ON U.UsuarioID = A.UsuarioID
JOIN Livros L ON A.LivroID = L.LivroID;

-- 5. TRIGGERS

-- Trigger para atualizar a quantidade de livros disponíveis ao realizar um aluguel
CREATE TRIGGER AtualizaQuantidadeDisponivel_Aluguel
AFTER INSERT ON Alugueis
FOR EACH ROW
BEGIN
    UPDATE Livros
    SET QuantidadeDisponivel = QuantidadeDisponivel - 1
    WHERE LivroID = NEW.LivroID;
END;

-- Trigger para atualizar a quantidade de livros disponíveis ao devolver um livro
CREATE TRIGGER AtualizaQuantidadeDisponivel_Devolucao
AFTER UPDATE ON Alugueis
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Devolvido' THEN
        UPDATE Livros
        SET QuantidadeDisponivel = QuantidadeDisponivel + 1
        WHERE LivroID = NEW.LivroID;
    END IF;
END;

-- 6. STORED PROCEDURES

-- Procedure para registrar devolução e gerar multa se necessário
DELIMITER //
CREATE PROCEDURE RegistrarDevolucao (
    IN p_AluguelID INT,
    IN p_DataDevolucao DATE
)
BEGIN
    DECLARE v_DataAluguel DATE;
    DECLARE v_DiasAtraso INT;

    -- Busca a data de aluguel
    SELECT DataAluguel INTO v_DataAluguel
    FROM Alugueis
    WHERE AluguelID = p_AluguelID;

    -- Calcula dias de atraso
    SET v_DiasAtraso = DATEDIFF(p_DataDevolucao, v_DataAluguel) - 14; -- 14 dias de prazo

    -- Atualiza o status do aluguel
    UPDATE Alugueis
    SET DataDevolucao = p_DataDevolucao, Status = 'Devolvido'
    WHERE AluguelID = p_AluguelID;

    -- Gera multa se houver atraso
    IF v_DiasAtraso > 0 THEN
        INSERT INTO Multas (AluguelID, ValorMulta, Pago)
        VALUES (p_AluguelID, v_DiasAtraso * 2.50, FALSE); -- Multa de 2.50 por dia
    END IF;
END //
DELIMITER ;
