#!/usr/bin/env bash
# Uso: ./dns_check.sh [-h] [domínio]
# Descrição: Verifica DNS (A, AAAA, MX, NS) para um domínio. Somente leitura.
set -euo pipefail

usage() { echo "Uso: $0 [-h] [domínio]"; exit 0; }
[[ "${1:-}" == "-h" ]] && usage

DOMAIN="${1:-${LAB_DOMAIN:-example.com}}"

OUT_DIR="$(dirname "$0")/../../evidencias"
mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$OUT_DIR/$(basename "$0" .sh)_$STAMP.txt"

{
  echo "# Coleta: $(basename "$0") | $(date -Is) | host: $(hostname)"
  echo "# Domínio: $DOMAIN"
  echo ""

  if command -v dig &> /dev/null; then
    echo "## Registro A (IPv4)"
    echo "### dig +short A $DOMAIN"
    dig +short A "$DOMAIN" || echo "Nenhum registro A encontrado"
    echo ""

    echo "## Registro AAAA (IPv6)"
    echo "### dig +short AAAA $DOMAIN"
    dig +short AAAA "$DOMAIN" || echo "Nenhum registro AAAA encontrado"
    echo ""

    echo "## Registro MX (Mail Exchange)"
    echo "### dig +short MX $DOMAIN"
    dig +short MX "$DOMAIN" || echo "Nenhum registro MX encontrado"
    echo ""

    echo "## Registro NS (Name Server)"
    echo "### dig +short NS $DOMAIN"
    dig +short NS "$DOMAIN" || echo "Nenhum registro NS encontrado"
    echo ""

    echo "## Dig completo (todas as respostas)"
    echo "### dig $DOMAIN ANY"
    dig "$DOMAIN" ANY +short || echo "Nenhuma resposta ANY encontrada"
  else
    echo "AVISO: dig não está instalado. Tentando nslookup..."
    echo ""

    if command -v nslookup &> /dev/null; then
      echo "## nslookup (A record)"
      nslookup "$DOMAIN" || echo "Falha ao consultar com nslookup"
    else
      echo "ERRO: nem dig nem nslookup estão disponíveis."
      echo "Instale dnsutils (dig) ou dnsutils-utils."
    fi
  fi
} | tee "$OUT"

echo "Evidência salva em: $OUT"
