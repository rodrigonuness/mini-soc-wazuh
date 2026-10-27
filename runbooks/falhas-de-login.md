# Runbook — Falhas de Login

**Gatilho:** Alerta de falha de autenticação (Event ID 4625 no Windows, `sshd: Failed password` no Linux)

**Contexto a verificar:**
- Ativo: qual host/máquina gerou o alerta
- Usuário: qual usuário alvo (usuário comum, admin, serviço)
- Horário: é horário normal de atividade
- Origem: IP de origem (interno, externo, conhecido, desconhecido)
- Frequência: quantidade de falhas em curto intervalo

**Passos de validação:**

1. **Identificar o alerta no Wazuh Dashboard**
   - Navegar para `Discover` ou `Security events`
   - Filtrar por `rule.groups: "authentication_failed"`
   - Verificar nível de severidade, agente, horário

2. **Verificar contexto do usuário**
   - O usuário existe? (usuário legítimo ou inexistente)
   - É usuário comum, admin ou serviço?
   - O usuário deveria estar logando neste horário?

3. **Verificar IP de origem**
   - É IP interno (rede própria) ou externo?
   - É IP conhecido (usuário habitual, VPN, escritório)?
   - É IP desconhecido ou suspeito?
   - Há geolocalização anormal?

4. **Verificar frequência e padrão**
   - Quantas falhas em quanto tempo? (ex: 10 falhas em 1 minuto)
   - Há múltiplos usuários alvo do mesmo IP? (credential spraying)
   - Há falhas recorrentes do mesmo IP? (ataque contínuo)
   - Há logons bem-sucedidos após as falhas? (comprometimento)

5. **Correlacionar com outros eventos**
   - Há eventos 4624 (logon bem-sucedido) após as falhas?
   - Há eventos 4688 (processos criados) após o logon?
   - Há eventos 4740 (conta bloqueada)?
   - Há eventos de rede suspeitos?

6. **Verificar logs do sistema**
   - Linux: `/var/log/auth.log` ou `journalctl -u ssh`
   - Windows: Event Viewer > Security > Event ID 4625
   - Verificar `Failure Reason` e `Sub Status`

**É falso positivo se:**
- Usuário errou própria senha algumas vezes (erro humano)
- Aplicativo configurado com credencial errada tentando repetidamente
- Serviço tentando autenticar com senha antiga após atualização
- Script de automação com credencial desatualizada
- Usuário em fuso horário diferente logando em horário incomum

**Escalar quando:**
- Múltiplas falhas do mesmo IP em curto intervalo (brute force)
- Falhas para múltiplos usuários do mesmo IP (credential spraying)
- Falhas para conta de admin ou serviço
- Falhas fora do horário normal de atividade
- Falhas de IP externo desconhecido
- Logon bem-sucedido após múltiplas falhas (credencial comprometida)
- Conta bloqueada (evento 4740)

**Evidências a guardar:**
- Fatos: timestamps, IPs, usuários, quantidade de falhas
- Fontes: logs do sistema, Wazuh Dashboard, capturas de tela
- Horários: hora exata das falhas e de possíveis sucessos
- Consultas: filtros usados no Dashboard
- Hipóteses: ataque de força bruta, erro humano, credencial desatualizada

**Hipóteses e limitações:**
- Separar fato de suposição (ex: "IP X tentou logar" é fato; "IP X é atacante" é suposição)
- Limitação: IP pode ser NAT/proxy, não necessariamente IP real do atacante
- Limitação: sem correlação com threat intelligence, difícil confirmar se IP é malicioso
- Limitação: em laboratório, eventos são sintéticos, não representam ameaça real

**Registro (ITSM):**
- ID: [preencher se houver sistema de ticket]
- Severidade: [baixa/média/alta] baseada em contexto
- Status: [falso positivo/benigno/suspeito/incidente]
- Responsável: [analista que fez triagem]
- Resolução: [ação tomada, ex: bloqueio de IP, redefinição de senha]
