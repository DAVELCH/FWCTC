$reconnectCount = 0
$startTime = Get-Date

$wasOnline = $false
$connectionStartTime = $null
$lastConnectionDuration = "N/A"

# ==============================
# CONFIGURACION ACCNAME 
# ==============================
$accname = "MEZQUI-JAL1092-NE40-X8A-CA"

# ==============================
# FUNCION: ACTIVAR PORTAL
# ==============================
function Activate-Portal {

    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object { $_.IPAddress -like "10.*" } |
           Select-Object -First 1 -ExpandProperty IPAddress)

    if (-not $ip) { return }

    $adapter = Get-NetAdapter |
               Where-Object { $_.Status -eq "Up" -and $_.MacAddress } |
               Select-Object -First 1

    if (-not $adapter) { return }

    $mac = $adapter.MacAddress

    $url = "https://clubwifi.totalplay.com.mx/ClubMovil/inicio" +
           "?wlanuserip=$ip" +
           "&wlanacname=" +
           "&wlanparameter=$mac" +
           "&accname=$accname" +
           "&type=DESKTOP" +
           "&webView=false"

    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0 Safari/537.36"
    }

    try {
        Invoke-WebRequest $url -Headers $headers -TimeoutSec 8 -ErrorAction Stop | Out-Null
    }
    catch { }
}

# ==============================
# LOOP PRINCIPAL
# ==============================
while ($true) {

    $now = Get-Date
    $uptime = $now - $startTime

    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object {$_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1"} |
           Select-Object -First 1 -ExpandProperty IPAddress)

    # --- DETECCIÓN REAL DE INTERNET (generate_204) ---
    try {
        $response = Invoke-WebRequest `
            -Uri "http://clients3.google.com/generate_204" `
            -UseBasicParsing `
            -TimeoutSec 5 `
            -ErrorAction Stop

        $online = ($response.StatusCode -eq 204)
    }
    catch {
        $online = $false
    }

    # --- DETECCIÓN DE CAMBIO DE ESTADO ---
    if ($online -and -not $wasOnline) {
        $connectionStartTime = Get-Date
    }

    if (-not $online -and $wasOnline -and $connectionStartTime) {
        $duration = (Get-Date) - $connectionStartTime
        $lastConnectionDuration = "$([int]$duration.TotalMinutes) min $([int]$duration.Seconds) seg"
        $connectionStartTime = $null
    }

    $wasOnline = $online

    Clear-Host

    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host " DAVELCH'S FREE Wi-Fi CLUB TOTALPLAY CONNECTOR " -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hora: $($now.ToString('HH:mm:ss'))"
    Write-Host "IP Local: $ip"
    Write-Host "Reconexiones: $reconnectCount"
    Write-Host "Tiempo activo script: $([int]$uptime.TotalMinutes) min $([int]$uptime.Seconds) seg"
    Write-Host "Duracion ultima conexion: $lastConnectionDuration"
    Write-Host ""
    Write-Host "-----------------------------------------------"
    Write-Host ""

    if ($online) {

        Write-Host "STATUS: CONNECTED" -ForegroundColor Green
        Write-Host "Internet real detectado (204 OK)."

    }
    else {

        Write-Host "STATUS: CONNECTING..." -ForegroundColor Red
        Write-Host "Activando portal (modo limpio HTTPS)..."

        Activate-Portal

        Start-Sleep -Seconds 1

        $reconnectCount++
    }

    Start-Sleep -Seconds 1
}
