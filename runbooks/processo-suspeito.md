# Runbook — Processo Suspeito

**Gatilho:** Alerta de criação de processo (Event ID 4688 no Windows, FIM no Linux detectando novo executável)

**Contexto a verificar:**
- Ativo: qual host/máquina executou o processo
- Usuário: qual usuário iniciou o processo
- Processo: nome do executável, caminho completo
- Linha de comando: argumentos e parâmetros
- Processo pai: qual processo iniciou este processo
- Horário: é horário normal de atividade

**Passos de validação:**

1. **Identificar o alerta no Wazuh Dashboard**
   - Navegar para `Discover` ou `Security events`
   - Filtrar por `rule.groups: "process"` ou `syscheck` (FIM)
   - Verificar nível de severidade, agente, horário

2. **Verificar informações do processo**
   - Nome do executável (ex: `notepad.exe`, `powershell.exe`, `unknown.exe`)
   - Caminho completo (ex: `C:\Windows\System32\notepad.exe` vs `C:\Temp\malware.exe`)
   - Linha de comando completa (há argumentos suspeitos?)
   - Hash do arquivo (se disponível)

3. **Verificar local do executável**
   - É local seguro? (`C:\Windows\System32\`, `/usr/bin/`)
   - É local suspeito? (`C:\Temp\`, `/tmp/`, `Downloads`)
   - É local não usual para este tipo de processo?

4. **Verificar linha de comando**
   - Há argumentos codificados (Base64, hex)?
   - Há download de arquivo da internet?
   - Há execução de comando remoto?
   - Há ofuscação?

5. **Verificar processo pai**
   - Qual processo iniciou este processo?
   - O processo pai é legítimo? (ex: `explorer.exe`, `sshd`)
   - O processo pai é suspeito? (ex: `cmd.exe` iniciando `powershell.exe`)

6. **Verificar usuário**
   - Quem iniciou o processo?
   - É usuário comum, admin ou serviço?
   - É usuário esperado para este tipo de processo?

7. **Verificar horário**
   - É horário normal de atividade?
   - O processo foi iniciado fora do horário de trabalho?
   - Há outros processos suspeitos no mesmo horário?

8. **Correlacionar com outros eventos**
   - Há eventos de rede antes do processo? (download de arquivo)
   - Há eventos de FIM (alteração de arquivo) antes?
   - Há eventos de criação de usuário antes?
   - Há eventos de logon suspeito antes?

9. **Verificar reputação do arquivo**
   - Pesquisar hash em VirusTotal (se disponível)
   - Verificar se arquivo é conhecido (assinado, legítimo)
   - Verificar se arquivo é desconhecido/novo

**É falso positivo se:**
- Processo legítimo em local seguro (ex: `notepad.exe` em `C:\Windows\System32\`)
- Processo de atualização do sistema
- Processo de aplicativo conhecido (ex: navegador, Office)
- Script de automação ou ferramenta de administrador
- Processo iniciado por usuário legítimo para atividade normal

**Escalar quando:**
- Processo executado de local não usual (ex: `C:\Temp\`)
- Linha de comando suspeita (download, execução remota, ofuscação)
- Processo filho de processo suspeito
- Processo com elevação inesperada
- Processo de arquivo desconhecido/não assinado
- Processo iniciado por usuário não-admin para atividade suspeita
- Processo correlacionado com eventos de rede suspeitos

**Evidências a guardar:**
- Fatos: nome do processo, caminho, linha de comando, hash, usuário, horário
- Fontes: logs do sistema, Wazuh Dashboard, VirusTotal
- Horários: hora exata da criação do processo
- Consultas: filtros usados no Dashboard
- Hipóteses: malware legítimo, ferramenta de admin, processo normal

**Hipóteses e limitações:**
- Separar fato de suposição (ex: "processo X foi executado" é fato; "processo X é malware" é suposição)
- Limitação: sem análise de malware, difícil confirmar se arquivo é malicioso
- Limitação: hash pode não estar em VirusTotal (arquivo novo/único)
- Limitação: linha de comando pode ser ofuscada, difícil interpretar
- Limitação: em laboratório, processos são benignos, não representam ameaça real

**Registro (ITSM):**
- ID: [preencher se houver sistema de ticket]
- Severidade: [baixa/média/alta] baseada em contexto
- Status: [falso positivo/benigno/suspeito/incidente]
- Responsável: [analista que fez triagem]
- Resolução: [ação tomada, ex: isolar host, encerrar processo, análise de malware]
