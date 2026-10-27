# Catálogo de Eventos do Windows

## Visão geral

Este documento descreve os eventos Windows mais relevantes para triagem de segurança, incluindo quando ocorrem, campos importantes, falsos positivos comuns e quando escalar.

**Regra importante:** Um evento isolado não comprova ataque. Sempre correlacione com outros eventos e contexto.

## Tabela de eventos

| ID | Nome | Canal | Quando ocorre | Campos importantes | Falsos positivos comuns | Quando escalar |
|---||---|---|---|---|---|
| 4624 | Logon bem-sucedido | Security | Usuário faz logon | `Logon Type`, `Subject`, `Logon ID` | Logons interativos normais, serviços | Logon Type 3 (rede) de IP desconhecido |
| 4625 | Falha de logon | Security | Usuário erra senha/conta bloqueada | `Failure Reason`, `Sub Status`, `IP` | Erro de senha do próprio usuário | Múltiplas falhas do mesmo IP curto intervalo |
| 4688 | Criação de processo | Security | Novo processo é criado | `Process Name`, `Command Line`, `Parent Process` | Aplicativos normais (notepad, calc) | Processo suspeito de local não usual |
| 4720 | Usuário criado | Security | Novo usuário local é criado | `Sam Account Name`, `Sid`, `Who` | Criação de usuário de teste | Usuário criado por conta não-admin |
| 4740 | Conta bloqueada | Security | Conta é bloqueada por muitas falhas | `Target Account Name`, `Caller Computer Name` | Usuário errou senha várias vezes | Bloqueio de conta de serviço ou admin |
| 1102 | Log de segurança limpo | Security | Log de segurança é limpo | `Who`, `When` | Limpeza agendada por política | Limpeza manual por usuário suspeito |

---

## Detalhes por evento

### Event ID 4624 — Logon bem-sucedido

**Quando ocorre:**
- Usuário faz logon interativo (Type 2)
- Usuário acessa rede/compartilhamento (Type 3)
- Serviço inicia com conta de serviço (Type 5)
- Desbloqueio de tela (Type 7)
- Logon RDP (Type 10)

**Campos importantes:**
- `Logon Type`: Tipo de logon (2=interativo, 3=rede, 5=serviço, 7=desbloqueio, 10=RDP)
- `Subject\UserName`: Quem iniciou o logon
- `TargetUserName`: Usuário que fez logon
- `TargetDomainName`: Domínio do usuário
- `WorkstationName`: Nome da máquina de origem
- `IpAddress`: IP de origem (para Type 3 e 10)
- `LogonID`: ID da sessão

**Falsos positivos comuns:**
- Logons interativos normais do usuário
- Logons de serviços (Type 5) de contas de serviço conhecidas
- Logons de rede (Type 3) de máquinas internas confiáveis

**Quando escalar:**
- Logon Type 3 (rede) de IP externo desconhecido
- Logon Type 10 (RDP) de IP não esperado
- Logon de conta de admin fora do horário normal
- Múltiplos logons de diferentes IPs em curto intervalo

---

### Event ID 4625 — Falha de logon

**Quando ocorre:**
- Usuário erra senha
- Conta não existe
- Conta bloqueada/desabilitada
- Senha expirada
- Logon não permitido (horário, local)

**Campos importantes:**
- `Failure Reason`: Motivo da falha (ex: "Wrong Password")
- `Sub Status`: Código de erro (0xC000006A = senha errada, 0xC0000234 = conta bloqueada)
- `TargetUserName`: Usuário que tentou logon
- `IpAddress`: IP de origem
- `Logon Type`: Tipo de logon

**Falsos positivos comuns:**
- Usuário erra própria senha algumas vezes
- Aplicativo configurado com credencial errada
- Serviço tentando autenticar com senha antiga

**Quando escalar:**
- Múltiplas falhas do mesmo IP em curto intervalo (brute force)
- Falhas para múltiplos usuários do mesmo IP (credential spraying)
- Falhas para conta de admin ou serviço
- Falhas fora do horário normal

---

### Event ID 4688 — Criação de processo

**Quando ocorre:**
- Qualquer processo é criado no Windows

**Campos importantes:**
- `New Process Name`: Caminho do executável
- `Command Line`: Linha de comando completa
- `Parent Process Name`: Processo pai
- `Subject\UserName`: Usuário que iniciou o processo
- `Token Elevation Type`: Se o processo tem elevação de privilégio

**Falsos positivos comuns:**
- Aplicativos normais (notepad.exe, calc.exe, chrome.exe)
- Processos do sistema (svchost.exe, explorer.exe)
- Atualizações do Windows

**Quando escalar:**
- Processo executado de local não usual (ex: C:\Temp\malware.exe)
- Linha de comando suspeita (PowerShell codificado, download de arquivo)
- Processo filho de processo suspeito
- Processo com elevação inesperada

---

### Event ID 4720 — Usuário criado

**Quando ocorre:**
- Novo usuário local é criado

**Campos importantes:**
- `SamAccountName`: Nome do usuário criado
- `Sid`: SID do usuário
- `Subject\UserName`: Quem criou o usuário
- `Subject\LogonId`: ID de logon de quem criou

**Falsos positivos comuns:**
- Criação de usuário de teste por administrador
- Scripts de automação que criam usuários
- Provisão de novos funcionários

**Quando escalar:**
- Usuário criado por conta não-admin
- Usuário criado fora do horário normal
- Usuário criado com nome suspeito
- Usuário criado seguido de eventos de logon

---

### Event ID 4740 — Conta bloqueada

**Quando ocorre:**
- Conta é bloqueada por política de bloqueio (muitas falhas)

**Campos importantes:**
- `TargetAccountName`: Conta bloqueada
- `TargetDomainName`: Domínio da conta
- `CallerComputerName`: Máquina de origem
- `Subject\UserName`: Quem reportou o bloqueio

**Falsos positivos comuns:**
- Usuário erra senha várias vezes
- Aplicativo com credencial errada tentando repetidamente

**Quando escalar:**
- Conta de serviço ou admin bloqueada
- Bloqueio de múltiplas contas do mesmo IP
- Bloqueio fora do horário normal

---

### Event ID 1102 — Log de segurança limpo

**Quando ocorre:**
- Log de segurança é limpo manualmente

**Campos importantes:**
- `Subject\UserName`: Quem limpou o log
- `Subject\LogonId`: ID de logon de quem limpou

**Falsos positivos comuns:**
- Limpeza agendada por política de retenção
- Script de manutenção que limpa logs

**Quando escalar:**
- Limpeza manual por usuário não-admin
- Limpeza após eventos suspeitos (tentativa de ocultar)
- Limpeza fora do horário normal

---

## Referências

- [Microsoft Security Event IDs](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/monitor/active-directory-security-events)
- [Windows Event Log documentation](https://learn.microsoft.com/en-us/windows/win32/eventlog/event-logging)
