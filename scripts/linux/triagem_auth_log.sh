#!/usr/bin/env bash
# Uso: ./triagem_auth_log.sh [-h]
# Descrição: Triagem de logs de autenticação (falhas por usuário/IP, horários de pico). Somente leitura.
set -euo pipefail

usage() { echo "Uso: $0 [-h]"; exit 0; }
[[ "${1:-}" == "-h" ]] && usage

OUT_DIR="$(dirname "$0")/../../evidencias"
mkdir -p "$OUT_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$OUT_DIR/$(basename "$0" .sh)_$STAMP.txt"

# Detectar local do log de autenticação
if [ -f /var/log/auth.log ]; then
  AUTH_LOG="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
  AUTH_LOG="/var/log/secure"
else
  echo "ERRO: Log de autenticação não encontrado (/var/log/auth.log ou /var/log/secure)"
  exit 1
fi

{
  echo "# Coleta: $(basename "$0") | $(date -Is) | host: $(hostname)"
  echo "# Log: $AUTH_LOG"
  echo ""

  echo "## Falhas de login por usuário"
  echo "### grep -i 'failed password' $AUTH_LOG | awk '{print \$11}' | sort | uniq -c | sort -rn"
  grep -i "failed password" "$AUTH_LOG" 2>/dev/null | awk '{print $11}' | sort | uniq -c | sort -rn || echo "Nenhuma falha encontrada"
  echo ""

  echo "## Falhas de login por IP de origem"
  echo "### grep -i 'failed password' $AUTH_LOG | awk '{print \$13}' | sort | uniq -c | sort -rn"
  grep -i "failed password" "$AUTH_LOG" 2>/dev/null | awk '{print $13}' | sort | uniq -c | sort -rn || echo "Nenhuma falha encontrada"
  echo ""

  echo "## Sucessos de login por usuário"
  echo "### grep -i 'accepted' $AUTH_LOG | awk '{print \$9}' | sort | uniq -c | sort -rn"
  grep -i "accepted" "$AUTH_LOG" 2>/dev/null | awk '{print $9}' | sort | uniq -c | sort -rn || echo "Nenhum sucesso encontrado"
  echo ""

  echo "## Sucessos de login por IP de origem"
  echo "### grep -i 'accepted' $AUTH_LOG | awk '{print \$11}' | sort | uniq -c | sort -rn"
  grep -i "accepted" "$AUTH_LOG" 2>/dev/null | awk '{print $11}' | sort | uniq -c | sort -rn || echo "Nenhum sucesso encontrado"
  echo ""

  echo "## Horários de pico de falhas (por hora)"
  echo "### grep -i 'failed password' $AUTH_LOG | awk '{print \$1, \$2, \$3}' | cut -d: -f1,2 | sort | uniq -c | sort -rn | head -10"
  grep -i "failed password" "$AUTH_LOG" 2>/dev/null | awk '{print $1, $2, $3}' | cut -d: -f1,2 | sort | uniq -c | sort -rn | head -10 || echo "Nenhuma falha encontrada"
  echo ""

  echo "## Horários de pico de sucessos (por hora)"
  echo "### grep -i 'accepted' $AUTH_LOG | awk '{print \$1, \$2, \$3}' | cut -d: -f1,2 | sort | uniq -c | sort -rn | head -10"
  grep -i "accepted" "$AUTH_LOG" 2>/dev/null | awk '{print $1, $2, $3}' | cut -d: -f1,2 | sort | uniq -c | sort -rn | head -10 || echo "Nenhum sucesso encontrado"
  echo ""

  echo "## Sucessos após falhas (usuários que erraram senha mas depois conseguiram)"
  echo "### Identificar usuários com falhas e depois sucesso"
  FAILED_USERS=$(grep -i "failed password" "$AUTH_LOG" 2>/dev/null | awk '{print $11}' | sort -u)
  if [ -n "$FAILED_USERS" ]; then
    for user in $FAILED_USERS; do
      HAS_SUCCESS=$(grep -i "accepted.*$user" "$AUTH_LOG" 2>/dev/null | wc -l)
      if [ "$HAS_SUCCESS" -gt 0 ]; then
        echo "Usuário: $user - Sucessos após falhas: $HAS_SUCCESS"
      fi
    done
  else
    echo "Nenhum usuário com falhas encontrado"
  fi
  echo ""

  echo "## Últimas 10 falhas de login"
  echo "### grep -i 'failed password' $AUTH_LOG | tail -n 10"
  grep -i "failed password" "$AUTH_LOG" 2>/dev/null | tail -n 10 || echo "Nenhuma falha encontrada"
  echo ""

  echo "## Últimos 10 sucessos de login"
  echo "### grep -i 'accepted' $AUTH_LOG | tail -n 10"
  grep -i "accepted" "$AUTH_LOG" 2>/dev/null | tail -n 10 || echo "Nenhum sucesso encontrado"
  echo ""

  echo "## Tentativas de login de usuário não existente"
  echo "### grep -i 'invalid user' $AUTH_LOG | awk '{print \$10}' | sort | uniq -c | sort -rn"
  grep -i "invalid user" "$AUTH_LOG" 2>/dev/null | awk '{print $10}' | sort | uniq -c | sort -rn || echo "Nenhuma tentativa de usuário inválido encontrada"
} | tee "$OUT"

echo "Evidência salva em: $OUT"
