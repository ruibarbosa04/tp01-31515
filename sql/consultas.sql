-- Consultas à tabela transferencias_eficiencia
-- TP1 ISI 2026/27 - Rui Barbosa (nº 31515)
--
-- Antes de correr, importar o dump:  SOURCE sql/transferencias_dump.sql;

USE transferencias;

-- 1. Total de transferências carregadas (esperado: 8430)
SELECT COUNT(*) AS total_transferencias
FROM transferencias_eficiencia;

-- 2. Primeiras 10 linhas, com o total ao lado
SELECT
    (SELECT COUNT(*) FROM transferencias_eficiencia) AS total_linhas,
    nome_jogador,
    nome_clube,
    transfer_fee,
    golos,
    assistencias,
    custo_por_golo_ou_assistencia,
    classificacao
FROM transferencias_eficiencia
LIMIT 10;

-- 3. Distribuição por classificação
SELECT
    classificacao,
    COUNT(*) AS transferencias
FROM transferencias_eficiencia
GROUP BY classificacao
ORDER BY transferencias DESC;

-- 4. As 10 transferências mais eficientes (menor custo por golo ou assistência)
SELECT
    nome_jogador,
    nome_clube,
    nome_liga,
    transfer_fee,
    golos,
    assistencias,
    custo_por_golo_ou_assistencia,
    classificacao
FROM transferencias_eficiencia
WHERE custo_por_golo_ou_assistencia IS NOT NULL
ORDER BY custo_por_golo_ou_assistencia ASC
LIMIT 10;

-- 5. As 10 transferências menos eficientes (maior custo por golo ou assistência)
SELECT
    nome_jogador,
    nome_clube,
    nome_liga,
    transfer_fee,
    golos,
    assistencias,
    custo_por_golo_ou_assistencia,
    classificacao
FROM transferencias_eficiencia
WHERE custo_por_golo_ou_assistencia IS NOT NULL
ORDER BY custo_por_golo_ou_assistencia DESC
LIMIT 10;

-- 6. Custo médio por golo ou assistência, por liga (só ligas com 20 ou mais transferências)
SELECT
    nome_liga,
    pais_liga,
    COUNT(*) AS transferencias,
    ROUND(AVG(custo_por_golo_ou_assistencia), 0) AS custo_medio
FROM transferencias_eficiencia
WHERE custo_por_golo_ou_assistencia IS NOT NULL
GROUP BY nome_liga, pais_liga
HAVING COUNT(*) >= 20
ORDER BY custo_medio DESC;

-- 7. Golos e assistências médios no primeiro ano, por posição
SELECT
    position,
    COUNT(*) AS transferencias,
    ROUND(AVG(golos_e_assistencias), 2) AS media_golos_e_assistencias
FROM transferencias_eficiencia
GROUP BY position
ORDER BY media_golos_e_assistencias DESC;

-- 8. Transferências com liga desconhecida, por código de liga
SELECT
    codigo_liga,
    COUNT(*) AS transferencias
FROM transferencias_eficiencia
WHERE nome_liga = 'Desconhecida'
GROUP BY codigo_liga
ORDER BY transferencias DESC;

-- 9. Transferências por época
SELECT
    transfer_season,
    COUNT(*) AS transferencias,
    ROUND(AVG(transfer_fee), 0) AS taxa_media
FROM transferencias_eficiencia
GROUP BY transfer_season
ORDER BY transfer_season;