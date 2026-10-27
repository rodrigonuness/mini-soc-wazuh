# Ambiente WSL2 — Mini-SOC com Wazuh

## Visão geral

Este projeto usa WSL2 (Windows Subsystem for Linux) com Ubuntu para:
- Rodar o Wazuh Manager + Indexer + Dashboard via Docker
- Executar o agente Wazuh Linux no próprio WSL2
- Coletar logs e eventos do WSL2
- Futuramente: adicionar o Windows como agente para eventos 4624/4625/4688

## Arquitetura

```
Windows (host)
├── WSL2 Ubuntu
│   ├── Docker (Wazuh stack)
│   │   ├── Wazuh Manager
│   │   ├── Wazuh Indexer
│   │   └── Wazuh Dashboard
│   └── Agente Wazuh (aponta para localhost)
└── Windows (agente futuro)
    └── Agente Wazuh Windows
```

## Configuração inicial

### 1. Acessar o WSL2
```bash
wsl
```

### 2. Atualizar o Ubuntu
```bash
sudo apt update && sudo apt upgrade -y
```

### 3. Verificar Docker no WSL2
```bash
docker --version
docker compose version
```

*Nota: Docker Desktop já está instalado e deve estar acessível no WSL2.*

### 4. Clonar/mover o projeto para o WSL2
```bash
# Acessar o diretório do projeto no Windows
cd /mnt/c/Users/rodri/OneDrive/Documentos/Git/mini-soc-wazuh
```

Ou mover para dentro do WSL2 para melhor performance:
```bash
cp -r /mnt/c/Users/rodri/OneDrive/Documentos/Git/mini-soc-wazuh ~/mini-soc-wazuh
cd ~/mini-soc-wazuh
```

## Rede no WSL2

O WSL2 usa uma rede NAT. O IP do WSL2 muda a cada reinício.

- Para acessar o dashboard do Windows: `https://localhost` (Docker Desktop expõe as portas)
- Para o agente dentro do WSL2 apontar para o manager: usar `localhost` ou `127.0.0.1`
- Se precisar do IP do WSL2 para conectar de fora: `ip addr show eth0`

## Próximos passos

1. Entrar no WSL2 e acessar o projeto
2. Seguir o dia 29 (subir o Wazuh)
3. Seguir o dia 30 (agente Linux)
4. (Opcional) Configurar agente Windows

## Limitações

- Arquivos grandes no `/mnt/c/` são mais lentos (cross-filesystem)
- Rede WSL2 pode mudar IPs após reinício do Windows
- Docker no WSL2 compartilha recursos com Windows
