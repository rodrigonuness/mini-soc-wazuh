# Leitura de Conexão com Wireshark

## Visão geral

Este documento explica como capturar tráfego de rede com Wireshark, filtros úteis e como analisar um handshake TCP.

**IMPORTANTE:** Capturar apenas tráfego do próprio laboratório. Não capturar tráfego de redes de terceiros.

## Como capturar tráfego do próprio host

### Opção 1: Capturar no próprio host (Linux/WSL2)

```bash
# Instalar Wireshark (se necessário)
sudo apt install wireshark -y

# Adicionar usuário ao grupo wireshark (para capturar sem sudo)
sudo usermod -aG wireshark $USER
# Logout e login novamente

# Iniciar Wireshark
wireshark
```

### Opção 2: Capturar com tcpdump (sem interface gráfica)

```bash
# Capturar 100 pacotes na interface eth0
sudo tcpdump -i eth0 -c 100 -w captura.pcap

# Capturar apenas tráfego HTTP
sudo tcpdump -i eth0 -A -s 0 'tcp port 80'

# Capturar tráfego DNS
sudo tcpdump -i eth0 -i any port 53
```

### Opção 3: Capturar no Windows

1. Baixar Wireshark: https://www.wireshark.org/download.html
2. Instalar e executar como administrador
3. Selecionar a interface de rede (ex: WSL, Ethernet, Wi-Fi)
4. Clicar em "Start capturing packets"

## Filtros úteis

### Filtros básicos

```
dns              # Capturar apenas tráfego DNS
http             # Capturar apenas tráfego HTTP
tcp              # Capturar apenas tráfego TCP
udp              # Capturar apenas tráfego UDP
icmp             # Capturar apenas ICMP (ping)
```

### Filtros por IP

```
ip.addr == 192.168.1.100           # Tráfego de/para este IP
ip.src == 192.168.1.100            # Tráfego de origem
ip.dst == 192.168.1.100            # Tráfego de destino
ip.addr == 192.168.1.0/24          # Tráfego da rede /24
```

### Filtros por porta

```
tcp.port == 80                      # Porta 80 (HTTP)
tcp.port == 443                     # Porta 443 (HTTPS)
tcp.port == 22                      # Porta 22 (SSH)
udp.port == 53                      # Porta 53 (DNS)
```

### Filtros TCP avançados

```
tcp.flags.syn == 1                  # Pacotes SYN (início de conexão)
tcp.flags.ack == 1                  # Pacotes ACK
tcp.flags.fin == 1                  # Pacotes FIN (fim de conexão)
tcp.flags.reset == 1                # Pacotes RST (reset)
tcp.flags.syn == 1 and tcp.flags.ack == 1  # SYN-ACK
```

### Filtros combinados

```
dns and ip.addr == 8.8.8.8                    # DNS para 8.8.8.8
http and ip.src == 192.168.1.100             # HTTP de origem específica
tcp.port == 443 and ip.addr == 1.1.1.1       # HTTPS para 1.1.1.1
```

## Como ler um handshake TCP

### O que é handshake TCP

O handshake TCP (3-way handshake) estabelece uma conexão confiável entre cliente e servidor:
1. **SYN:** Cliente solicita conexão
2. **SYN-ACK:** Servidor aceita e solicita confirmação
3. **ACK:** Cliente confirma

### Visualização no Wireshark

```
Tempo    Origem        Destino      Protocolo  Info
0.000    192.168.1.100  1.1.1.1      TCP       [SYN] Seq=0
0.050    1.1.1.1        192.168.1.100 TCP       [SYN, ACK] Seq=0 Ack=1
0.100    192.168.1.100  1.1.1.1      TCP       [ACK] Seq=1 Ack=1
```

### Como identificar

1. Procure por `tcp.flags.syn == 1` no filtro
2. Veja a sequência:
   - Primeiro pacote: apenas SYN
   - Segundo pacote: SYN + ACK
   - Terceiro pacote: apenas ACK
3. O número de sequência (Seq) e acknowledgment (Ack) deve fazer sentido

### O que cada flag significa

- **SYN (Synchronize):** Inicia conexão
- **ACK (Acknowledge):** Confirma recebimento
- **FIN (Finish):** Encerra conexão
- **RST (Reset):** Reseta conexão abruptamente
- **PSH (Push):** Dados devem ser entregues imediatamente
- **URG (Urgent):** Dados urgentes

## Como gerar tráfego benigno para captura

### Exemplo 1: Tráfego DNS
```bash
# No terminal, faça algumas consultas DNS
dig google.com
dig example.com
nslookup ubuntu.com
```

### Exemplo 2: Tráfego HTTP
```bash
# Fazer requisições HTTP
curl -I https://example.com
curl https://httpbin.org/get
```

### Exemplo 3: Tráfego SSH
```bash
# Tentar conectar a um servidor (mesmo que falhe)
ssh usuario@localhost
# Ctrl+C para cancelar
```

### Exemplo 4: Tráfego ICMP (ping)
```bash
# Fazer alguns pings
ping -c 5 google.com
ping -c 5 8.8.8.8
```

## Salvar captura

### No Wireshark
1. File > Save As
2. Escolha formato: `.pcap` (recomendado)
3. Salvar em `pcap/`
4. **IMPORTANTE:** Não salvar credenciais ou dados sensíveis

### Com tcpdump
```bash
# Salvar diretamente em pcap/
sudo tcpdump -i eth0 -c 100 -w pcap/captura_sintetica.pcap
```

## Anonimizar capturas

Antes de compartilhar capturas:
1. Usar `editcap` ou `tshark` para anonimizar IPs
2. Remover pacotes com dados sensíveis
3. Verificar se há credenciais em texto (ex: HTTP básico)

Exemplo com tshark:
```bash
# Anonimizar IPs (substituir por 10.0.0.X)
tshark -r captura.pcap -T fields -e ip.src -e ip.dst | sort -u
```

## Troubleshooting

### "Permission denied" ao capturar
- Adicionar usuário ao grupo `wireshark` (Linux)
- Executar como administrador (Windows)
- Usar `sudo` (Linux)

### Não vejo tráfego
- Verifique se está capturando na interface correta
- Verifique se o firewall não está bloqueando
- Gere tráfego ativamente (ping, curl, etc.)

### Captura muito grande
- Use filtros para reduzir
- Limite o número de pacotes (`-c 100`)
- Capture apenas protocolos específicos

## Arquivo de exemplo

Ver `pcap/exemplo_sintetico.pcap` para uma captura de exemplo com tráfego DNS e HTTP benigno.

## Referências

- [Documentação Wireshark](https://www.wireshark.org/docs/)
- [Filtros de exibição Wireshark](https://wiki.wireshark.org/DisplayFilters)
