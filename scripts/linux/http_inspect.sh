#!/usr/bin/env bash
# Uso: ./http_inspect.sh [-h] [URL]
# Descrição: Inspeção de requisição HTTP (código, cabeçalhos, redirecionamentos). Somente leitura (GET/HEAD).
set -euo pipefail

usage() { echo "Uso: $0 [-h] [URL]"; exit 0; }
[[ "${1:-}" == "-h" ]] && usage

URL="${1:-https://example.com}"

OUT_DIR="$(dirname "$0")/../../evidencias"
mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$OUT_DIR/$(basename "$0" .sh)_$STAMP.txt"

{
  echo "# Coleta: $(basename "$0") | $(date -Is) | host: $(hostname)"
  echo "# URL: $URL"
  echo ""

  if ! command -v curl &> /dev/null; then
    echo "ERRO: curl não está instalado."
    exit 1
  fi

  echo "## Informações básicas (curl -sSIL)"
  echo "### Código de resposta e redirecionamentos"
  curl -sSIL "$URL" || echo "Falha na requisição"
  echo ""

  echo "## Detalhes da requisição (curl -v)"
  echo "### Requisição HEAD (apenas cabeçalhos)"
  curl -v -I "$URL" 2>&1 || echo "Falha na requisição"
  echo ""

  echo "## Cabeçalhos de resposta"
  echo "### curl -sI -D - $URL"
  curl -sI -D - "$URL" 2>&1 || echo "Falha na requisição"
  echo ""

  echo "## Cabeçalhos de segurança relevantes"
  echo "### HSTS (Strict-Transport-Security)"
  curl -sI "$URL" 2>&1 | grep -i "strict-transport-security" || echo "HSTS não encontrado"
  echo ""

  echo "### CSP (Content-Security-Policy)"
  curl -sI "$URL" 2>&1 | grep -i "content-security-policy" || echo "CSP não encontrado"
  echo ""

  echo "### X-Frame-Options"
  curl -sI "$URL" 2>&1 | grep -i "x-frame-options" || echo "X-Frame-Options não encontrado"
  echo ""

  echo "### X-Content-Type-Options"
  curl -sI "$URL" 2>&1 | grep -i "x-content-type-options" || echo "X-Content-Type-Options não encontrado"
  echo ""

  echo "## Resumo"
  echo "### Código de status final"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>&1 || echo "000")
  echo "HTTP Status: $STATUS"
  echo ""

  echo "### Número de redirecionamentos"
  REDIRECTS=$(curl -s -o /dev/null -w "%{redirect_url}" "$URL" 2>&1 || echo "0")
  echo "Redirecionamentos: $REDIRECTS"
} | tee "$OUT"

echo "Evidência salva em: $OUT"
