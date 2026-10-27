# Subir o Wazuh — Docker Compose (Single-Node)

## Versão
Wazuh 4.14.9 (14 de outubro de 2026)

## Pré-requisitos

1. **WSL2 com Ubuntu** já instalado
2. **Docker** e **Docker Compose** instalados (Docker Desktop já fornece)
3. **Mínimo de recursos:** 4 vCPU, 8 GB RAM, 40 GB de disco

## Passo a passo

### 1. Entrar no WSL2
```bash
wsl
```

### 2. Navegar para o diretório do projeto
```bash
cd /mnt/c/Users/rodri/OneDrive/Documentos/Git/mini-soc-wazuh
```

*Recomendação: copiar para dentro do WSL2 para melhor performance*
```bash
cp -r /mnt/c/Users/rodri/OneDrive/Documentos/Git/mini-soc-wazuh ~/mini-soc-wazuh
cd ~/mini-soc-wazuh
```

### 3. Configurar vm.max_map_count (requisito do Elasticsearch)
```bash
sudo sysctl -w vm.max_map_count=262144
```

Para tornar persistente (opcional):
```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### 4. Baixar o repositório oficial do Wazuh Docker
```bash
cd docker
git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.9
cd wazuh-docker/single-node
```

### 5. Gerar certificados
```bash
docker compose -f generate-indexer-certs.yml run --rm generator
```

### 6. Subir o Wazuh
```bash
docker compose up -d
```

### 7. Verificar status dos containers
```bash
docker compose ps
```

Todos devem estar com status `Up`.

### 8. Acessar o Dashboard
- URL: `https://localhost`
- Credenciais padrão:
  - Usuário: `admin`
  - Senha: `Senha-1234` (verifique no arquivo `.env` gerado)

**IMPORTANTE:** Troque as credenciais padrão imediatamente e guarde no gerenciador de senhas.

**Aviso de certificado:** O certificado é autoassinado (esperado em laboratório). O navegador mostrará um aviso de segurança, que pode ser ignorado.

## Parar o Wazuh
```bash
docker compose down
```

## Ver logs
```bash
docker compose logs -f
```

Para um container específico:
```bash
docker compose logs -f wazuh.dashboard
docker compose logs -f wazuh.indexer
docker compose logs -f wazuh.manager
```

## Troubleshooting

### Indexer reinicia sem parar
- Verifique `vm.max_map_count`: `sysctl vm.max_map_count`
- Verifique RAM disponível: `free -h`
- Ver logs: `docker compose logs wazuh.indexer`

### Dashboard não abre
- Verifique se containers estão `Up`: `docker compose ps`
- Verifique se a porta 443 está livre: `ss -tulpn | grep 443`
- Aguarde mais tempo (primeiro start pode demorar 2-3 minutos)

### Certificado expirado ou erro de conexão
- Regenerar certificados:
  ```bash
  docker compose -f generate-indexer-certs.yml run --rm generator
  docker compose down
  docker compose up -d
  ```

## Próximos passos

1. Configurar agente Linux (ver `docs/agente-linux.md`)
2. Gerar eventos benignos
3. Praticar triagem de alertas
