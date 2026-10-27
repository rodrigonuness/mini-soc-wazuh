# Uso: .\coleta_eventos.ps1 [-h] [-Horas N]
# Descrição: Coleta eventos 4624, 4625 e 4688 das últimas N horas. Somente leitura.
param(
    [switch]$h,
    [int]$Horas = 24
)

if ($h) {
    Write-Host "Uso: .\coleta_eventos.ps1 [-h] [-Horas N]"
    Write-Host "  -h         : Mostra esta ajuda"
    Write-Host "  -Horas N   : Coleta eventos das últimas N horas (padrão: 24)"
    exit 0
}

# Verificar se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERRO: Este script requer privilégios de administrador." -ForegroundColor Red
    Write-Host "Execute o PowerShell como administrador e tente novamente."
    exit 1
}

# Calcular data de início
$startTime = (Get-Date).AddHours(-$Horas)

# Criar diretório de evidências
$scriptPath = $PSScriptRoot
$outDir = Join-Path $scriptPath "..\..\evidencias"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path $outDir "coleta_eventos_${stamp}.csv"

Write-Host "# Coleta: coleta_eventos.ps1 | $(Get-Date -Format o) | host: $env:COMPUTERNAME"
Write-Host "# Horas: $Horas (de $startTime até agora)"
Write-Host ""

# Função para coletar eventos
function Get-EventLogData {
    param(
        [int]$EventId,
        [string]$LogName = "Security"
    )

    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName = $LogName
            ID = $EventId
            StartTime = $startTime
        } -ErrorAction SilentlyContinue

        if ($events) {
            foreach ($event in $events) {
                [PSCustomObject]@{
                    Timestamp = $event.TimeCreated
                    EventId = $event.Id
                    Level = "Information"
                    Computer = $event.MachineName
                    Message = $event.Message
                    XML = $event.ToXml()
                }
            }
        }
    } catch {
        Write-Host "AVISO: Não foi possível coletar evento $EventId: $_" -ForegroundColor Yellow
    }
}

# Coletar eventos
Write-Host "Coletando eventos..."
$allEvents = @()

# Event ID 4624 - Logon bem-sucedido
Write-Host "  - Event ID 4624 (Logon bem-sucedido)"
$allEvents += Get-EventLogData -EventId 4624

# Event ID 4625 - Falha de logon
Write-Host "  - Event ID 4625 (Falha de logon)"
$allEvents += Get-EventLogData -EventId 4625

# Event ID 4688 - Criação de processo
Write-Host "  - Event ID 4688 (Criação de processo)"
$allEvents += Get-EventLogData -EventId 4688

# Ordenar por timestamp
$allEvents = $allEvents | Sort-Object Timestamp

# Exportar para CSV
if ($allEvents.Count -gt 0) {
    $allEvents | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8
    Write-Host ""
    Write-Host "Evidência salva em: $outFile" -ForegroundColor Green
    Write-Host "Total de eventos coletados: $($allEvents.Count)"
} else {
    Write-Host ""
    Write-Host "AVISO: Nenhum evento encontrado nas últimas $Horas horas." -ForegroundColor Yellow
    Write-Host "Verifique se:"
    Write-Host "  - A auditoria de eventos está habilitada"
    Write-Host "  - Os eventos ocorreram no período especificado"
    Write-Host "  - Você tem permissão para ler o log de segurança"
}
