# TP1 – Análise de Desempenho e Eficiência de Transferências de Jogadores

Trabalho Prático I de **Integração de Sistemas de Informação** (ISI), 2026/27.
Processo ETL (Extract, Transform, Load) com **Pentaho Data Integration (Spoon)**.

- **Aluno:** Rui Barbosa (nº 31515)
- **Docente:** Óscar Ribeiro
- **Curso:** Licenciatura em Engenharia de Sistemas Informáticos
- **Vídeo de demonstração:** [PREENCHER LINK]

## O que o projeto faz

Mede se uma transferência de futebol compensou: quanto custou cada golo ou assistência que o jogador produziu nos primeiros 365 dias no novo clube.

O resultado são 8 430 transferências, cada uma com jogos, golos, assistências, custo por jogo, custo por golo ou assistência, valorização e uma classificação (Excelente, Boa, Fraca, Muito fraca ou Sem contribuições).

## Fontes de dados

| Ficheiro | Formato | Conteúdo |
| --- | --- | --- |
| `transfers.csv` | CSV | Transferências, com data, clubes e taxa paga |
| `appearances.csv` | CSV | Jogos de cada jogador: golos, assistências, minutos |
| `players.csv` | CSV | Nome, posição, valores de mercado |
| `clubs.csv` | CSV | Nome do clube e código da liga |
| `data/ligas.xml` | XML | 31 ligas com código, nome e país |
| `data/limiares.yaml` | YAML | Limites de custo da classificação |

Os quatro CSV vêm do conjunto público [dcaribou/transfermarkt-datasets](https://github.com/dcaribou/transfermarkt-datasets) e **não estão no repositório** (ver abaixo). O XML e o YAML foram criados para este trabalho.

## Como funciona

1. **Transformação 02** (`02_join_transfers_appearances.ktr`): filtra as transferências pagas, junta os jogos do primeiro ano no novo clube (chave jogador + clube), agrega e calcula as métricas. Escreve `output/transferencias_eficiencia.csv`.
2. **Transformação 03** (`03_enriquecer_ligas.ktr`): limpa as ligas do XML (regex e trim), junta-as às transferências, classifica com os limiares do YAML e escreve três saídas: CSV, JSON e MySQL.
3. **Job** (`job_transferencias.kjb`): corre as duas transformações por ordem, regista os erros, envia email com os ficheiros em anexo e pára com erro se algo falhar.

As transformações `01a` a `01f` são de exploração e leitura de cada fonte.

## Requisitos

- Pentaho Data Integration (Spoon) 10.2
- MySQL e MySQL Workbench (a tabela de destino é criada com o dump em `sql/`)
- MySQL Connector/J, colocado na pasta `lib` do Spoon
- Power BI Desktop (opcional, para o dashboard)
- Conta Gmail com palavra-passe de aplicação (opcional, para o email)

## Configuração

1. **Dados:** descarregar os quatro CSV do conjunto acima para `data/raw/` (a pasta está no `.gitignore`).
2. **Base de dados:** no MySQL, criar o schema e carregar a tabela:
   ```sql
   CREATE DATABASE transferencias;
   USE transferencias;
   SOURCE sql/transferencias_dump.sql;
   ```
3. **Variáveis:** o repositório é público, por isso as credenciais ficam fora dele. Adicionar ao ficheiro `kettle.properties` (no Spoon: *Editar > Edit the kettle.properties file…*):
   ```
   MYSQL_PASSWORD=...
   SMTP_USER=...
   SMTP_PASSWORD=...
   EMAIL_DESTINO=...
   ```
4. **Driver:** copiar o MySQL Connector/J (`.jar`) para a pasta `lib` do Spoon e reiniciar.

Todos os caminhos são relativos (`${Internal.Entry.Current.Directory}`), por isso o projeto corre em qualquer computador sem editar caminhos.

## Como correr

1. Abrir o Spoon e o ficheiro `jobs/job_transferencias.kjb`.
2. Clicar em **Run**.
3. No fim, os resultados estão em `output/` e na tabela `transferencias_eficiencia` do MySQL.

## Estrutura

```
data/
  ligas.xml
  limiares.yaml
  raw/              (CSV, fora do Git)
transformations/    (ficheiros .ktr)
jobs/               (job_transferencias.kjb)
output/             (CSV e JSON gerados)
sql/                (dump e consultas)
docs/               (relatório, capturas e dashboard Power BI)
```

## Resultados

| Classificação | Transferências |
| --- | --- |
| Excelente | 1 721 |
| Boa | 1 677 |
| Fraca | 1 466 |
| Muito fraca | 1 295 |
| Sem contribuições | 2 271 |
| **Total** | **8 430** |

Regras (custo por golo ou assistência): Excelente até 300 000, Boa até 1 000 000, Fraca até 3 000 000 e Muito fraca acima disso. Os limites estão em `data/limiares.yaml`.

## Dashboard

O ficheiro `docs/dashboard_transferencias.pbix` lê `output/transferencias_final.csv`. Depois de correr o job, clicar em **Atualizar** no Power BI para ver os dados novos.

## Limitações

- 184 transferências ficam com a liga "Desconhecida", porque 85 clubes não têm código de liga no `clubs.csv`.
- Os limiares do YAML são arbitrários.
- A valorização compara o valor de mercado atual com a taxa paga, em épocas diferentes.
- O Stream lookup guarda uma só transferência por jogador e clube.
- O job não está agendado e o log fica só na consola do Spoon.
