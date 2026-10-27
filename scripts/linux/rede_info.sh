#!/usr/bin/env bash
# Uso: ./rede_info.sh [-h]
# Descrição: Coleta informações de rede (IP, rota, gateway, DNS). Somente leitura.
set -euo pipefail

usage() { echo "Uso: $0 [-h]"; exit 0; }
[[ "${1:-}" == "-h" ]] && usage

OUT_DIR="$(dirname "$0")/../../evidencias"
mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$OUT_DIR/$(basename "$0" .sh)_$STAMP.txt"

{
  echo "# Coleta: $(basename "$0") | $(date -Is) | host: $(hostname)"
  echo ""
  echo "## Endereços IP"
  echo "### ip addr show"
  ip addr show
  echo ""
  echo "## Tabela de roteamento"
  echo "### ip route show"
  ip route show
  echo ""
  echo "## Gateway padrão"
  echo "### ip route | grep default"
  ip route | grep default || echo "Nenhum gateway padrão encontrado"
  echo ""
  echo "## DNS configurado"
  if command -v resolvectl &> /dev/null; then
    echo "### resolvectl status"
    resolvectl status
  else
    echo "### /etc/resolv.conf"
    cat /etc/resolv.conf
  fi
  echo ""
  echo "## IP público (se houver conexão com internet)"
  if command -v curl &> /dev/null; then
    echo "### curl -s ifconfig.me"
    curl -s ifconfig.me || echo "Não foi possível obter IP público"
  else
    echo "curl não disponível"
  fi
  echo ""
  echo "## IP privado"
  echo "### hostname -I"
  hostname -I
} | tee "$OUT"

echo "Evidência salva em: $OUT"
