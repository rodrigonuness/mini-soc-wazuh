# Agente Wazuh Linux — Instalação e Configuração

## Contexto

Este guia mostra como instalar o agente Wazuh em Linux (Ubuntu no WSL2) e conectá-lo ao Wazuh Manager.

## Pré-requisitos

- Wazuh Manager rodando (ver `docker/README.md`)
- Ubuntu/Debian com acesso à internet
- Acesso sudo

## Passo a passo

### 1. Adicionar o repositório Wazuh

```bash
# Importar a chave GPG
sudo mkdir -p /etc/apt/keyrings
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /etc/apt/keyrings/wazuh.gpg

# Adicionar o repositório
echo "deb [signed-by=/etc/apt/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

# Atualizar
sudo apt update
```

### 2. Instalar o agente

```bash
sudo apt install wazuh-agent -y
```

### 3. Configurar o agente

Opção A: Durante a instalação (interativo)
```bash
sudo /var/ossec/bin/wazuh-control agent
```

Opção B: Editar manualmente o arquivo de configuração
```bash
sudo nano /var/ossec/etc/ossec.conf
```

Alterar:
```xml
<client>
  <server>
    <address>127.0.0.1</address>  <!-- IP do Wazuh Manager (localhost se no mesmo host) -->
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
  <agent_name>lab-wsl-ubuntu</agent_name>  <!-- Nome do agente -->
</client>
```

### 4. Iniciar o agente

```bash
sudo systemctl start wazuh-agent
sudo systemctl enable wazuh-agent
```

### 5. Verificar status

```bash
sudo systemctl status wazuh-agent
```

Deve mostrar `Active: active (running)`.

### 6. Verificar logs de conexão

```bash
sudo tail -n 50 /var/ossec/logs/ossec.log
```

Procure por:
- `Connected to the server` (conectado com sucesso)
- `Unable to connect to server` (erro de conexão)

### 7. Adicionar o agente no Wazuh Manager (se necessário)

Se o agente não foi registrado automaticamente:

No Wazuh Dashboard:
1. Navegue para `Agents` > `Agents management`
2. Clique em `Add new agent`
3. Preencha o nome (ex: `lab-wsl-ubuntu`)
4. Copie o comando de registro

No agente:
```bash
sudo /var/ossec/bin/agent-auth -m <IP_DO_MANAGER> -A lab-wsl-ubuntu
sudo systemctl restart wazuh-agent
```

## Verificação no Dashboard

1. Acesse `https://localhost`
2. Navegue para `Agents` > `Agents management`
3. O agente deve aparecer como `Active` (status verde)

## Variáveis de ambiente

Use o arquivo `.env` no projeto:
```bash
export WAZUH_MANAGER_IP=127.0.0.1
export WAZUH_AGENT_NAME=lab-wsl-ubuntu
```

## Troubleshooting

### Agente não conecta
- Verifique se o manager está rodando: `docker compose ps` (no diretório do docker)
- Verifique firewall: `sudo ufw status` (permita portas 1514/1515 se necessário)
- Verifique IP do manager: `ip addr show` no host do manager
- Ver logs: `sudo tail -f /var/ossec/logs/ossec.log`

### Agente aparece como "Disconnected"
- Reinicie o agente: `sudo systemctl restart wazuh-agent`
- Verifique logs de erro: `sudo journalctl -u wazuh-agent -n 50`
- Verifique se o manager aceita conexões do IP do agente

### Erro de permissão
- Rodar comandos com `sudo`
- Verificar se o usuário tem permissão para acessar logs do sistema

## Desinstalar

```bash
sudo apt remove wazuh-agent -y
sudo rm -rf /var/ossec
```

## Próximos passos

1. Gerar eventos benignos (falhas de login SSH, etc.)
2. Verificar eventos no Dashboard
3. Praticar triagem de alertas
4. Criar filtros e consultas (ver `docs/queries.md`)
