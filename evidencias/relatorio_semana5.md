# Relatório de Evidências — Semana 5

## Informações do ambiente

**Data:** [preencher]
**Nome do analista:** [seu nome]
**Objetivo:** Prática de triagem de eventos em laboratório Mini-SOC com Wazuh

### Versões do ambiente

- **Wazuh:** [versão, ex: 4.14.9]
- **Sistema operacional do agente:** [ex: Ubuntu 22.04 LTS no WSL2]
- **Docker:** [versão]
- **Docker Compose:** [versão]

### Topologia

- **Wazuh Manager:** [localização, ex: WSL2 Ubuntu]
- **Agente Linux:** [nome, ex: lab-wsl-ubuntu]
- **Agente Windows:** [se aplicável, ex: Windows 11]
- **Rede:** [descrição, ex: WSL2 NAT]

---

## O que foi observado

### Eventos benignos gerados

| Tipo de evento | Data/hora | Como foi gerado | Onde foi observado |
|---|---|---|---|
| Falha de login SSH | [preencher] | Tentativa de login com senha errada (3x) | auth.log + Wazuh Dashboard |
| Logon bem-sucedido | [preencher] | Login normal com senha correta | auth.log + Wazuh Dashboard |
| Novo processo | [preencher] | Abertura de aplicação (ex: notepad) | Wazuh Dashboard |
| [outro] | [preencher] | [descrição] | [local] |

### Consultas realizadas no Dashboard

| Consulta | Filtros usados | Resultado principal |
|---|---|---|
| Falhas de login últimas 24h | `rule.groups: "authentication_failed" AND @timestamp >= now-24h` | [número] eventos |
| Eventos por agente | `agent.name: "lab-wsl-ubuntu"` | [número] eventos |
| Eventos de alta severidade | `rule.level >= 10` | [número] eventos |
| [outra] | [filtros] | [resultado] |

---

## Como encontrei os eventos no Dashboard

### Passo a passo para localizar cada evento

1. **Falha de login SSH:**
   - Acessei o Dashboard em `https://localhost`
   - Naveguei para `Discover`
   - Usei o filtro: `rule.groups: "authentication_failed"`
   - Filtrei pelo timestamp: [hora específica]
   - Cliquei no evento para ver detalhes

2. **Logon bem-sucedido:**
   - [descrever passos]

3. **Novo processo:**
   - [descrever passos]

---

## Limitações e incertezas

### Limitações do laboratório

- [Listar limitações, ex: apenas um agente, eventos sintéticos, rede isolada]

### Incertezas ou dúvidas

- [Listar o que não consegui entender ou precisa investigar mais]

### O que não funcionou como esperado

- [Listar problemas encontrados, ex: agente desconectou, não encontrei evento X]

---

## Próximos passos

- [ ] Gerar mais eventos benignos (tipo específico)
- [ ] Praticar triagem de um cenário específico
- [ ] Criar runbook para [tipo de evento]
- [ ] Adicionar agente Windows para eventos 4624/4625/4688
- [ ] [outro objetivo]

---

## Anexos

- [ ] Captura de tela do Dashboard (sem dados sensíveis)
- [ ] Arquivo de log exportado (sem dados sensíveis)
- [ ] [outro anexo]

---

## Checklist de revisão (antes de compartilhar)

- [ ] Não há senhas, tokens ou chaves no relatório
- [ ] Capturas de tela não mostram IPs reais, usuários reais ou e-mails
- [ ] Hostnames foram alterados ou são genéricos
- [ ] Logs foram anonimizados se necessário
- [ ] O relatório está claro e pode ser entendido por outra pessoa
