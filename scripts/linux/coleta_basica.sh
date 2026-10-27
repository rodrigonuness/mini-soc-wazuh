#!/usr/bin/env bash
# Uso: ./coleta_basica.sh [-h]
# Descrição: Coleta básica de sistema (usuário, processos, conexões, logins). Somente leitura.
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

  echo "## Usuário atual"
  echo "### whoami"
  whoami
  echo ""

  echo "## Informações do usuário"
  echo "### id"
  id
  echo ""

  echo "## Tempo de atividade do sistema"
  echo "### uptime"
  uptime
  echo ""

  echo "## Top 10 processos por CPU"
  echo "### ps aux --sort=-%cpu | head -n 11"
  ps aux --sort=-%cpu | head -n 11
  echo ""

  echo "## Top 10 processos por memória"
  echo "### ps aux --sort=-%mem | head -n 11"
  ps aux --sort=-%mem | head -n 11
  echo ""

  echo "## Conexões de rede (tcp/udp)"
  echo "### ss -tulpn"
  if command -v ss &> /dev/null; then
    ss -tulpn || echo "Não foi possível obter conexões (pode precisar de sudo)"
  else
    echo "ss não disponível, tentando netstat..."
    netstat -tulpn 2>/dev/null || echo "netstat não disponível"
  fi
  echo ""

  echo "## Últimos logins"
  echo "### last -n 10"
  if command -v last &> /dev/null; then
    last -n 10 || echo "Não foi possível obter logins"
  else
    echo "last não disponível"
  fi
  echo ""

  echo "## Usuários logados atualmente"
  echo "### who"
  who
  echo ""

  echo "## Informações do kernel"
  echo "### uname -a"
  uname -a
  echo ""

  echo "## Versão do sistema operacional"
  if [ -f /etc/os-release ]; then
    echo "### cat /etc/os-release"
    cat /etc/os-release
  elif [ -f /etc/lsb-release ]; then
    echo "### cat /etc/lsb-release"
    cat /etc/lsb-release
  else
    echo "Informação de OS não disponível"
  fi
  echo ""

  echo "## Informações de CPU"
  echo "### lscpu"
  if command -v lscpu &> /dev/null; then
    lscpu
  else
    echo "lscpu não disponível"
  fi
  echo ""

  echo "## Informações de memória"
  echo "### free -h"
  free -h
} | tee "$OUT"

echo "Evidência salva em: $OUT"
