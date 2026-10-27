# Capturas PCAP

Este diretório contém capturas de rede sintéticas para estudo.

## Como gerar uma captura

```bash
# No Linux/WSL2
sudo tcpdump -i eth0 -c 100 -w pcap/exemplo_sintetico.pcap

# Gerar tráfego DNS e HTTP antes
dig google.com
curl -I https://example.com
ping -c 5 8.8.8.8
```

## Regras

- Apenas capturas sintéticas/benignas
- Sem credenciais ou dados sensíveis
- Arquivos pequenos (máximo 1 MB)
- Ver `docs/wireshark.md` para filtros úteis

## Arquivo de exemplo

`exemplo_sintetico.pcap` — Captura com tráfego DNS e HTTP benigno (a ser gerado)
