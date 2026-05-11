-- ══════════════════════════════════════
-- DADOS BASE
-- ══════════════════════════════════════
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id          INT,
    nome        VARCHAR(50),
    cidade      VARCHAR(50),
    valor_gasto DECIMAL(10,2)
);

CREATE TABLE pedidos (
    id         INT,
    cliente_id INT,
    produto    VARCHAR(50),
    valor      DECIMAL(10,2)
);

INSERT INTO clientes VALUES
(1, 'Ana Silva',     'Sao Paulo',      1500.00),
(2, 'Carlos Lima',   'Brasilia',        800.00),
(3, 'Fernanda Dias', 'Rio de Janeiro', 2200.00),
(4, 'Roberto Souza', 'Sao Paulo',       450.00),
(5, 'Julia Mendes',  'Brasilia',       3100.00),
(6, 'Marcos Paulo',  'Sao Paulo',      1900.00),
(7, 'Carla Souza',   'Rio de Janeiro', 2700.00),
(8, 'Pedro Lima',    'Brasilia',        600.00);

INSERT INTO pedidos VALUES
(1, 1, 'Notebook',  3500.00),
(2, 1, 'Tablet',    1800.00),
(3, 2, 'Celular',   1200.00),
(4, 3, 'Notebook',  3500.00),
(5, 3, 'Tablet',    1800.00),
(6, 4, 'Celular',   1200.00),
(7, 5, 'Notebook',  3500.00),
(8, 6, 'Tablet',    1800.00);

-- ══════════════════════════════════════
-- EXERCICIOS DIA 4
-- ══════════════════════════════════════

-- Ex 1: Subquery com MIN
SELECT nome, valor_gasto FROM clientes
WHERE valor_gasto > (SELECT MIN(valor_gasto) FROM clientes);

-- Ex 2: CASE WHEN 3 niveis
SELECT nome, valor_gasto,
CASE
    WHEN valor_gasto >= 2000 THEN 'VIP'
    WHEN valor_gasto >= 1000 THEN 'REGULAR'
    ELSE 'BASICO'
END AS nivel
FROM clientes ORDER BY valor_gasto DESC;

-- Ex 3: Subquery media Sao Paulo
SELECT nome, valor_gasto FROM clientes
WHERE valor_gasto > (
    SELECT AVG(valor_gasto) FROM clientes
    WHERE cidade = 'Sao Paulo'
);

-- Ex 4: CTE total por cidade
WITH soma_cit AS (
    SELECT cidade, SUM(valor_gasto) AS total
    FROM clientes GROUP BY cidade
)
SELECT cidade, total FROM soma_cit
WHERE total > 3000 ORDER BY total DESC;

-- Ex 5: CTE + CASE WHEN
WITH media AS (
    SELECT AVG(valor_gasto) AS media_geral FROM clientes
),
totais AS (
    SELECT cidade, SUM(valor_gasto) AS total
    FROM clientes GROUP BY cidade
)
SELECT t.cidade, t.total,
CASE
    WHEN t.total > m.media_geral THEN 'Acima da media'
    ELSE 'Abaixo da media'
END AS nivel
FROM totais t, media m ORDER BY t.total DESC;

-- Ex 6: Subquery + JOIN
SELECT c.nome, MAX(p.valor) AS maior_pedido
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.nome
HAVING MAX(p.valor) > (SELECT AVG(valor) FROM pedidos)
ORDER BY maior_pedido DESC;

-- Ex 7: CTE + JOIN + CASE WHEN
WITH pedidos_count AS (
    SELECT c.id, c.nome, c.valor_gasto,
    COUNT(p.id) AS total_pedidos
    FROM clientes c
    LEFT JOIN pedidos p ON c.id = p.cliente_id
    GROUP BY c.id, c.nome, c.valor_gasto
)
SELECT nome, valor_gasto, total_pedidos,
CASE
    WHEN total_pedidos >= 2 THEN 'Cliente Premium'
    ELSE 'Cliente Comum'
END AS classificacao
FROM pedidos_count ORDER BY total_pedidos DESC;
