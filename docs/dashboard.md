# Dashboard e Relatório — Wazuh

## Visão geral

Este documento descreve os painéis montados no Wazuh Dashboard, como criar visualizações e como exportar relatórios sem vazar dados sensíveis.

## Painéis recomendados

### 1. Eventos por severidade

**Objetivo:** Ver distribuição de eventos por nível de alerta.

**Como criar:**
1. Navegue para `Visualize Library` > `Create visualization`
2. Escolha `Pie chart`
3. Índice: `wazuh-alerts-*`
4. Bucket aggregation: `Terms`
5. Field: `rule.level`
6. Tamanho: 5-10

**O que mostra:**
- Quantos eventos de cada nível (0-15)
- Permite ver se há muitos eventos de alta severidade

**Ação:**
- Se muitos eventos de nível alto, investigar prioridade

---

### 2. Top agentes

**Objetivo:** Ver quais agentes geram mais eventos.

**Como criar:**
1. `Create visualization` > `Horizontal bar chart`
2. Índice: `wazuh-alerts-*`
3. Bucket aggregation: `Terms`
4. Field: `agent.name`
5. Tamanho: 10

**O que mostra:**
- Quais hosts são mais ativos
- Pode indicar anomalias se um host gera muito mais eventos que o normal

**Ação:**
- Investigar agentes com atividade anormal

---

### 3. Falhas de login ao longo do tempo

**Objetivo:** Ver tendência de falhas de autenticação.

**Como criar:**
1. `Create visualization` > `Line chart`
2. Índice: `wazuh-alerts-*`
3. Bucket aggregation (X-axis): `Date histogram`
4. Field: `@timestamp`
5. Interval: `1h` ou `1d`
6. Sub-aggregation: `Terms`
7. Field: `rule.groups` ou `data.srcip`

**O que mostra:**
- Quando ocorreram falhas de login
- Se há picos em horários específicos
- Se há IPs que tentam múltiplas vezes

**Ação:**
- Investigar picos anormais
- Bloquear IPs com muitas tentativas (se aplicável)

---

### 4. Eventos por tipo de regra

**Objetivo:** Ver quais tipos de eventos são mais comuns.

**Como criar:**
1. `Create visualization` > `Donut chart`
2. Índice: `wazuh-alerts-*`
3. Bucket aggregation: `Terms`
4. Field: `rule.groups`
5. Tamanho: 10

**O que mostra:**
- Categorias de eventos mais frequentes
- Ex: `authentication_failed`, `web`, `syslog`

**Ação:**
- Focar investigação nas categorias mais relevantes

---

## Como criar um Dashboard

1. Navegue para `Dashboard` > `Create dashboard`
2. Dê um nome: `Mini-SOC - Visão Geral`
3. Clique em `Add from library`
4. Selecione as visualizações criadas
5. Arraste e solte para organizar o layout
6. Salve o dashboard

## Como exportar relatório

### Opção 1: Exportar PDF

1. No Dashboard, clique em `Share` > `PDF Reports`
2. Configure:
   - Layout: `A4 landscape`
   - Intervalo de tempo: escolha o período
   - Incluir: visualizações desejadas
3. Clique em `Generate report`
4. Baixe o PDF

### Opção 2: Captura de tela

1. Use a ferramenta de captura do Windows (Win + Shift + S)
2. Capture apenas o painel desejado
3. Salve como PNG em `evidencias/`

### Opção 3: Exportar dados CSV

1. Em `Discover`, aplique os filtros desejados
2. Clique em `Save reports` > `CSV`
3. Baixe o arquivo
4. **IMPORTANTE:** Revise o CSV antes de compartilhar para remover dados sensíveis

---

## Checklist de revisão (antes de exportar/compartilhar)

### Remover dados sensíveis

- [ ] **Não mostrar senhas:** Verifique se algum campo contém senhas ou tokens
- [ ] **Não mostrar IPs reais:** Se necessário, anonimize IPs (ex: 192.168.1.X)
- [ ] **Não mostrar usuários reais:** Anonimize usernames (ex: user-01, admin-test)
- [ ] **Não mostrar e-mails:** Remova ou anonimize e-mails
- [ ] **Não mostrar hostnames reais:** Use nomes genéricos (ex: lab-host-01)
- [ ] **Não mostrar nomes de domínio reais:** Use `example.com` ou similar

### Verificar capturas de tela

- [ ] Recortar áreas com dados sensíveis
- [ ] Não mostrar URLs completas com tokens
- [ ] Não mostrar configurações detalhadas com credenciais
- [ ] Focar apenas no painel/gráfico, não na barra de endereço

### Verificar arquivos de log/CSV

- [ ] Abrir arquivo em editor de texto
- [ ] Buscar por palavras-chave: `password`, `token`, `key`, `secret`
- [ ] Remover ou anonimizar linhas com dados sensíveis
- [ ] Verificar se há IPs públicos (se sim, anonimizar)

### Documentação

- [ ] Adicionar nota: "Laboratório pessoal, dados anonimizados"
- [ ] Explicar contexto: "Eventos benignos gerados para estudo"
- [ ] Indicar que não há dados reais de produção

---

## Como anonimizar dados

### IPs
- Real: `192.168.1.100` → Anonimizado: `192.168.1.X`
- Real: `200.145.45.123` → Anonimizado: `200.145.X.X`

### Usuários
- Real: `joao.silva` → Anonimizado: `user-01`
- Real: `admin` → Anonimizado: `admin-test`

### Hostnames
- Real: `desktop-prod-01` → Anonimizado: `lab-host-01`
- Real: `srv-web-2024` → Anonimizado: `srv-lab-01`

### Domínios
- Real: `empresa.com.br` → Anonimizado: `example.com`

---

## Próximos passos

1. Criar pelo menos 3 visualizações úteis
2. Montar um dashboard com essas visualizações
3. Gerar um relatório PDF ou capturas de tela
4. Revisar o relatório com o checklist acima
5. Salvar em `evidencias/` sem dados sensíveis
6. Usar o relatório no portfólio (com aviso de laboratório pessoal)
