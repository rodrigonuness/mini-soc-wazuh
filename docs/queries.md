# Consultas e Filtros Úteis no Wazuh Dashboard

## Visão geral

Este documento descreve as consultas e filtros mais úteis para o Wazuh Dashboard, incluindo como usar, interpretar resultados e evitar armadilhas comuns.

## Como acessar as consultas

1. Acesse o Dashboard: `https://localhost`
2. Navegue para `Discover` ou `Security events`
3. Use a barra de filtros (KQL - Kibana Query Language)

## Filtros por categoria

### 1. Filtro por intervalo de tempo

**Objetivo:** Ver eventos em um período específico.

**KQL:**
```
@timestamp >= "2024-10-27T00:00:00" AND @timestamp <= "2024-10-27T23:59:59"
```

**Como usar:**
- Use o seletor de tempo no canto superior direito
- Opções: Last 15 minutes, Last 1 hour, Last 24 hours, Custom

**Armadilhas:**
- Fuso horário: o dashboard pode mostrar UTC em vez do horário local
- Muitos eventos em um intervalo largo podem tornar a consulta lenta

**Interpretação:**
- Verifique o timestamp de cada evento para entender a cronologia
- Use para correlacionar eventos antes/depois de um incidente

---

### 2. Filtro por nome do agente

**Objetivo:** Ver eventos de um host específico.

**KQL:**
```
agent.name: "lab-wsl-ubuntu"
```

**Como usar:**
- Útil em ambientes com múltiplos agentes
- Pode combinar com outros filtros

**Armadilhas:**
- Nome do agente é case-sensitive
- O nome deve corresponder exatamente ao configurado no agente

**Interpretação:**
- Se você tem apenas um agente, pode não precisar deste filtro
- Em ambientes maiores, essencial para isolar eventos por host

---

### 3. Filtro por IP de origem

**Objetivo:** Ver eventos de um IP específico (fonte da conexão).

**KQL:**
```
data.srcip: "192.168.1.100"
```

**Como usar:**
- Útil para investigar atividade de um IP específico
- Pode usar wildcards: `data.srcip: "192.168.1.*"`

**Armadilhas:**
- Nem todos os eventos têm `data.srcip` (ex: eventos locais)
- IPs podem ser NAT: o IP visto pode não ser o IP real do atacante
- IPs dinâmicos podem mudar ao longo do tempo

**Interpretação:**
- IP de origem pode indicar:
  - Usuário esperado (IP conhecido)
  - IP desconhecido (suspeito)
  - IP externo (possível ataque da internet)

---

### 4. Filtro por nível de severidade

**Objetivo:** Ver eventos por nível de alerta (0-15).

**KQL:**
```
rule.level >= 10
```

**Como usar:**
- Níveis mais altos indicam eventos mais graves
- Níveis 0-3: informativos
- Níveis 4-6: baixa severidade
- Níveis 7-10: média severidade
- Níveis 11-15: alta severidade

**Armadilhas:**
- Alto nível não significa necessariamente incidente (pode ser falso positivo)
- Eventos importantes podem ter nível baixo se a regra não está bem configurada
- Não dependa apenas do nível para triagem

**Interpretação:**
- Use para priorizar triagem: comece pelos níveis mais altos
- Combine com outros filtros para reduzir falsos positivos

---

### 5. Filtro por ID da regra

**Objetivo:** Ver eventos de uma regra específica.

**KQL:**
```
rule.id: "5710"
```

**Como usar:**
- Cada regra Wazuh tem um ID único
- Útil para investigar um tipo específico de evento
- Consulte a documentação do Wazuh para IDs de regras comuns

**Armadilhas:**
- IDs de regras podem mudar entre versões do Wazuh
- Não memorize IDs; consulte a documentação quando necessário

**Interpretação:**
- Mesmo ID = mesmo tipo de evento
- Útil para ver histórico de um tipo específico de alerta

---

### 6. Filtro por grupos de regras

**Objetivo:** Ver eventos de uma categoria específica.

**KQL:**
```
rule.groups: "authentication_failed"
```

**Como usar:**
- Grupos categorizam regras por tipo (auth, web, syslog, etc.)
- Útil para investigar eventos de uma categoria específica

**Grupos comuns:**
- `authentication_failed`: falhas de autenticação
- `web`: eventos web
- `syslog`: eventos de sistema
- `vulnerability-detector`: vulnerabilidades detectadas

**Armadilhas:**
- Uma regra pode pertencer a múltiplos grupos
- Nomes de grupos podem variar entre versões

**Interpretação:**
- Use para filtrar por tipo de evento em vez de regra específica
- Útil para ver tendências em uma categoria

---

## Exemplos de consultas combinadas

### Ver falhas de login de um IP específico
```
rule.groups: "authentication_failed" AND data.srcip: "192.168.1.100"
```

### Ver eventos de alta severidade nas últimas 24 horas
```
rule.level >= 10 AND @timestamp >= now-24h
```

### Ver eventos de um agente com nível alto
```
agent.name: "lab-wsl-ubuntu" AND rule.level >= 7
```

## Como salvar consultas

1. Execute a consulta desejada
2. Clique em `Save` (ícone de disquete)
3. Dê um nome descritivo (ex: "Falhas de login - últimas 24h")
4. Escolha `Save query` ou `Save as visualization`

## Próximos passos

1. Salvar 4 consultas úteis no Dashboard
2. Criar visualizações (gráficos de eventos por tempo, top IPs, etc.)
3. Criar dashboards personalizados
4. Documentar as consultas que mais usa no seu laboratório
