# Runbook — Acesso Remoto Inesperado

**Gatilho:** Alerta de logon remoto (Event ID 4624 Logon Type 10 no Windows, SSH no Linux)

**Contexto a verificar:**
- Ativo: qual host/máquina recebeu o acesso remoto
- Usuário: qual usuário fez o acesso remoto
- Origem: IP de origem (interno, externo, conhecido, desconhecido)
- Horário: é horário normal de atividade
- Tipo de acesso: RDP (Windows), SSH (Linux), VPN
- Duração: quanto tempo a sessão durou

**Passos de validação:**

1. **Identificar o alerta no Wazuh Dashboard**
   - Navegar para `Discover` ou `Security events`
   - Filtrar por `rule.groups: "authentication_success"` e tipo de logon remoto
   - Verificar nível de severidade, agente, horário

2. **Verificar tipo de logon**
   - Windows: Logon Type 10 (RDP), Type 3 (rede)
   - Linux: SSH, telnet (se aplicável)
   - É tipo de acesso esperado para este usuário?

3. **Verificar IP de origem**
   - É IP interno (rede própria) ou externo?
   - É IP conhecido (VPN, escritório, casa do usuário)?
   - É IP desconhecido ou suspeito?
   - Há geolocalização anormal? (ex: login do Brasil, depois da China)

4. **Verificar usuário**
   - O usuário tem permissão para acesso remoto?
   - É usuário comum, admin ou serviço?
   - É usuário esperado para este tipo de acesso?
   - O usuário está em férias ou licença?

5. **Verificar horário**
   - É horário normal de atividade?
   - O acesso foi fora do horário de trabalho?
   - Há acessos recorrentes em horários incomuns?

6. **Verificar duração da sessão**
   - Quanto tempo a sessão durou?
   - É duração normal para este usuário?
   - Há múltiplas sessões curtas (possível automatização)?

7. **Correlacionar com outros eventos**
   - Há falhas de login antes do sucesso? (credential spraying)
   - Há processos suspeitos iniciados após o acesso?
   - Há eventos de FIM (alteração de arquivo) durante a sessão?
   - Há eventos de criação de usuário durante a sessão?
   - Há eventos de rede suspeitos durante a sessão?

8. **Verificar logs do sistema**
   - Linux: `/var/log/auth.log` ou `journalctl -u ssh`
   - Windows: Event Viewer > Security > Event ID 4624
   - Verificar `Logon Type`, `IpAddress`, `WorkstationName`

9. **Verificar histórico de acessos**
   - Este usuário já acessou este host antes?
   - Este IP já acessou este host antes?
   - Há padrão de acesso normal para este usuário?

**É falso positivo se:**
- Acesso remoto de IP conhecido (VPN, escritório, casa do usuário)
- Acesso remoto em horário normal de trabalho
- Acesso remoto de usuário legítimo com permissão
- Acesso remoto para suporte ou manutenção agendada
- Acesso remoto de ferramenta de automação (ex: Ansible)

**Escalar quando:**
- Acesso remoto de IP externo desconhecido
- Acesso remoto de IP com geolocalização anormal
- Acesso remoto de usuário não-admin fora do horário normal
- Acesso remoto seguido de atividades suspeitas (processos, FIM)
- Acesso remoto múltiplos IPs em curto intervalo
- Acesso remoto para conta de serviço ou admin
- Acesso remoto após múltiplas falhas de login
- Acesso remoto de usuário em férias/licença

**Evidências a guardar:**
- Fatos: timestamps, IPs, usuários, tipo de acesso, duração
- Fontes: logs do sistema, Wazuh Dashboard, capturas de tela
- Horários: hora exata do início e fim da sessão
- Consultas: filtros usados no Dashboard
- Hipóteses: acesso legítimo, comprometimento de credencial, ataque

**Hipóteses e limitações:**
- Separar fato de suposição (ex: "IP X acessou via RDP" é fato; "IP X é atacante" é suposição)
- Limitação: IP pode ser NAT/proxy, não necessariamente IP real do atacante
- Limitação: sem geolocalização precisa, difícil confirmar se localização é anormal
- Limitação: usuário pode ter compartilhado credencial sem saber
- Limitação: em laboratório, acessos são sintéticos, não representam ameaça real

**Registro (ITSM):**
- ID: [preencher se houver sistema de ticket]
- Severidade: [baixa/média/alta] baseada em contexto
- Status: [falso positivo/benigno/suspeito/incidente]
- Responsável: [analista que fez triagem]
- Resolução: [ação tomada, ex: encerrar sessão, bloquear IP, redefinição de senha]
