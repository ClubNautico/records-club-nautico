<#
.SYNOPSIS
  Mide la fluidez de una pagina como si fuera un celular lento (CPU limitada).

.DESCRIPTION
  Lanza Microsoft Edge sin ventana (headless), se conecta por el Chrome DevTools
  Protocol (CDP), aplica Emulation.setCPUThrottlingRate (y opcionalmente una red
  4G lenta), carga herramientas/rendimiento.html con la pagina elegida y espera
  window.RESULTADO. Imprime una tabla, guarda un JSON y devuelve codigo 0 (sin
  fallos) o 1 (hay fallos o no hubo resultado).

.PARAMETER Pagina    Archivo .html a medir (defecto index.html).
.PARAMETER Repetir   Corridas por escenario; se reporta la mediana (defecto 1, max 5).
.PARAMETER Cpu       Factor de ralentizacion de CPU (defecto 4; 1 = sin limitar; 6 = celular muy lento).
.PARAMETER Red4G     Si se pasa, emula 4G lento (150 ms de latencia, 1,6 Mbps de bajada).
.PARAMETER Modo      Modo de Edge sin ventana: 'new' (--headless=new, defecto), 'old' (--headless)
                     o 'minimizada' (con ventana fuera de pantalla en --window-position=-2000,0).
.PARAMETER Gpu       Modo de GPU: 'defecto' (sin banderas de GPU, lo que haga Edge), 'sin' (--disable-gpu:
                     todo por software, sin compositor GPU), 'sw' (rasterizado/compositor GPU con SwiftShader
                     por software: --use-angle=swiftshader --enable-unsafe-swiftshader --enable-gpu-rasterization
                     --ignore-gpu-blocklist) o 'hw' (GPU real: --use-angle=d3d11 --enable-gpu-rasterization
                     --ignore-gpu-blocklist). Se imprime el renderer WebGL para verificar.
.PARAMETER Puerto    Puerto de depuracion remota (defecto 9333).
.PARAMETER Servidor  URL base del servidor local (defecto http://localhost:8765).
.PARAMETER MaxMinutos Tiempo maximo de espera del resultado (defecto 6).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File herramientas\medir_movil.ps1 -Pagina base.html -Cpu 6 -Red4G

.NOTES
  Modo de Edge verificado: ver el resumen impreso al inicio ("rAF ~NN Hz"). El script
  mide la frecuencia de requestAnimationFrame de about:blank antes de la prueba y avisa
  si no esta cerca de 60 Hz.
#>
[CmdletBinding()]
param(
  [string]$Pagina = 'index.html',
  [int]$Repetir = 1,
  [double]$Cpu = 4,
  [switch]$Red4G,
  [ValidateSet('new', 'old', 'minimizada')][string]$Modo = 'new',
  [ValidateSet('defecto', 'sin', 'sw', 'hw')][string]$Gpu = 'defecto',
  [int]$Puerto = 9333,
  [string]$Servidor = 'http://localhost:8765',
  [int]$MaxMinutos = 6
)

$ErrorActionPreference = 'Stop'
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { Write-Host "No se encuentra Edge en $edge"; exit 2 }
if ($Pagina -notmatch '^[\w-]+\.html$') { Write-Host "Pagina invalida: $Pagina"; exit 2 }
if ($Repetir -lt 1) { $Repetir = 1 }
if ($Repetir -gt 5) { $Repetir = 5 }

$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$nombreBase = [IO.Path]::GetFileNameWithoutExtension($Pagina)
$cpuTxt = ([string]$Cpu).Replace(',', '.')
$sufGpu = $(if ($Gpu -eq 'defecto') { '' } else { "_gpu$Gpu" })
$salidaJson = Join-Path $aqui ("resultados_movil_{0}_cpu{1}{2}.json" -f $nombreBase, $cpuTxt, $sufGpu)

$perfil = Join-Path ([IO.Path]::GetTempPath()) ('medir_movil_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $perfil | Out-Null

$argsEdge = @(
  "--remote-debugging-port=$Puerto",
  "--user-data-dir=`"$perfil`"",
  '--window-size=1000,1000',
  '--no-first-run', '--no-default-browser-check',
  '--disable-extensions', '--disable-background-networking',
  '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows',
  '--disable-background-timer-throttling'
)
switch ($Modo) {
  'new'        { $argsEdge = @('--headless=new') + $argsEdge }
  'old'        { $argsEdge = @('--headless') + $argsEdge }
  'minimizada' { $argsEdge = @('--window-position=-2000,0', '--start-minimized') + $argsEdge }
}
switch ($Gpu) {
  'sin' { $argsEdge += '--disable-gpu' }
  'sw'  { $argsEdge += @('--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--enable-gpu-rasterization', '--ignore-gpu-blocklist') }
  'hw'  { $argsEdge += @('--use-angle=d3d11', '--enable-gpu-rasterization', '--ignore-gpu-blocklist') }
}
$argsEdge += 'about:blank'

$proc = $null
$ws = $null
$script:id = 0
$script:eventos = New-Object System.Collections.ArrayList
$codigo = 1

function Recibir-Mensaje([int]$ms) {
  # Lee un mensaje CDP completo (maneja fragmentos). Devuelve $null si vence el tiempo.
  $buf = New-Object byte[] 65536
  $seg = New-Object 'System.ArraySegment[byte]' -ArgumentList (,$buf)
  $ms2 = New-Object System.IO.MemoryStream
  $cts = New-Object System.Threading.CancellationTokenSource
  $cts.CancelAfter($ms)
  try {
    do {
      $t = $ws.ReceiveAsync($seg, $cts.Token)
      $t.GetAwaiter().GetResult() | Out-Null
      $r = $t.Result
      if ($r.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) { throw 'WebSocket cerrado por Edge' }
      $ms2.Write($buf, 0, $r.Count)
    } while (-not $r.EndOfMessage)
  } catch [System.OperationCanceledException] { return $null }
  catch { if ($_.Exception.InnerException -is [System.OperationCanceledException]) { return $null }; throw }
  return [Text.Encoding]::UTF8.GetString($ms2.ToArray())
}

function Enviar-Cdp([string]$metodo, $parametros = @{}, [string]$sesion = '', [int]$timeoutMs = 30000) {
  $script:id++
  $miId = $script:id
  $msg = [ordered]@{ id = $miId; method = $metodo; params = $parametros }
  if ($sesion) { $msg['sessionId'] = $sesion }
  $json = $msg | ConvertTo-Json -Depth 10 -Compress
  $bytes = [Text.Encoding]::UTF8.GetBytes($json)
  $seg = New-Object 'System.ArraySegment[byte]' -ArgumentList (,$bytes)
  [void]$ws.SendAsync($seg, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
  $fin = [DateTime]::UtcNow.AddMilliseconds($timeoutMs)
  while ([DateTime]::UtcNow -lt $fin) {
    $texto = Recibir-Mensaje 1000
    if ($null -eq $texto) { continue }
    $o = $texto | ConvertFrom-Json
    if ($o.PSObject.Properties['id'] -and $o.id -eq $miId) {
      if ($o.PSObject.Properties['error']) { throw "CDP $metodo : $($o.error.message)" }
      return $o.result
    }
    if ($o.PSObject.Properties['method']) { [void]$script:eventos.Add($o) }
  }
  throw "Tiempo agotado esperando respuesta de $metodo"
}

function Aplicar-Emulacion([string]$sesion) {
  [void](Enviar-Cdp 'Emulation.setCPUThrottlingRate' @{ rate = $Cpu } $sesion)
  if ($Red4G) {
    [void](Enviar-Cdp 'Network.enable' @{} $sesion)
    [void](Enviar-Cdp 'Network.emulateNetworkConditions' @{
      offline = $false; latency = 150
      downloadThroughput = [math]::Floor(1.6 * 1000 * 1000 / 8)
      uploadThroughput = [math]::Floor(0.75 * 1000 * 1000 / 8)
    } $sesion)
  }
}

function Procesar-Eventos {
  # Aplica la emulacion a cada destino (iframe en otro proceso, workers) que se adjunte.
  $n = 0
  while ($script:eventos.Count -gt 0) {
    $e = $script:eventos[0]; $script:eventos.RemoveAt(0)
    if ($e.method -eq 'Target.attachedToTarget') {
      $s = $e.params.sessionId
      try { Aplicar-Emulacion $s; $n++ } catch { Write-Verbose "No se pudo emular en $s : $_" }
      try { [void](Enviar-Cdp 'Runtime.runIfWaitingForDebugger' @{} $s) } catch { }
    }
  }
  return $n
}

try {
  Write-Host "Lanzando Edge (modo $Modo, puerto $Puerto, CPU x$cpuTxt$(if($Red4G){', 4G lento'}))..."
  $proc = Start-Process -FilePath $edge -ArgumentList $argsEdge -PassThru -WindowStyle Minimized

  # Esperar al puerto de depuracion y a la pestana
  $pestana = $null
  for ($i = 0; $i -lt 60 -and -not $pestana; $i++) {
    Start-Sleep -Milliseconds 500
    try {
      $lista = Invoke-RestMethod -Uri "http://127.0.0.1:$Puerto/json" -TimeoutSec 3
      $pestana = @($lista | Where-Object { $_.type -eq 'page' -and $_.webSocketDebuggerUrl })[0]
    } catch { }
  }
  if (-not $pestana) { throw 'Edge no expuso la pestana de depuracion en 30 s' }

  $ws = New-Object System.Net.WebSockets.ClientWebSocket
  [void]$ws.ConnectAsync([Uri]$pestana.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()

  [void](Enviar-Cdp 'Page.enable')
  [void](Enviar-Cdp 'Runtime.enable')

  # Destinos hijos (iframes fuera de proceso): se adjuntan en modo plano y se les aplica lo mismo
  [void](Enviar-Cdp 'Target.setAutoAttach' @{ autoAttach = $true; waitForDebuggerOnStart = $false; flatten = $true })
  Aplicar-Emulacion ''

  # Sanidad: frecuencia de rAF de about:blank (sin limitar no aplica; se mide con CPU limitada)
  $hz = Enviar-Cdp 'Runtime.evaluate' @{
    expression = 'new Promise(r=>{let n=0,t0=0;function f(t){if(!t0)t0=t;n++;if(t-t0>=1000)r(Math.round(n*1000/(t-t0)*10)/10);else requestAnimationFrame(f)}requestAnimationFrame(f);setTimeout(()=>r(-1),4000)})'
    awaitPromise = $true; returnByValue = $true
  }
  Write-Host ("Sanidad: requestAnimationFrame de about:blank = {0} Hz (con CPU x{1})" -f $hz.result.value, $cpuTxt)
  if ($hz.result.value -lt 30) { Write-Host 'AVISO: rAF muy por debajo de 60 Hz; prueba otro -Modo (old / minimizada).' }

  $gl = Enviar-Cdp 'Runtime.evaluate' @{
    expression = '(()=>{try{const c=document.createElement("canvas");const g=c.getContext("webgl");if(!g)return "sin WebGL";const e=g.getExtension("WEBGL_debug_renderer_info");return e?g.getParameter(e.UNMASKED_RENDERER_WEBGL):g.getParameter(g.RENDERER)}catch(x){return "error "+x}})()'
    returnByValue = $true
  }
  Write-Host ("GPU (modo {0}): WebGL renderer = {1}" -f $Gpu, $gl.result.value)

  $url = "$Servidor/herramientas/rendimiento.html?pagina=$Pagina&repetir=$Repetir"
  Write-Host "Navegando a $url"
  [void](Enviar-Cdp 'Page.navigate' @{ url = $url })

  $limite = [DateTime]::UtcNow.AddMinutes($MaxMinutos)
  $resultado = $null
  $t0 = Get-Date
  $adjuntos = 0
  while ([DateTime]::UtcNow -lt $limite) {
    Start-Sleep -Seconds 3
    $adjuntos += (Procesar-Eventos)
    $r = Enviar-Cdp 'Runtime.evaluate' @{ expression = 'JSON.stringify(window.RESULTADO||null)'; returnByValue = $true }
    $v = $r.result.value
    if ($v -and $v -ne 'null') { $resultado = $v | ConvertFrom-Json; break }
    Write-Host ("  ...esperando ({0:N0} s)" -f ((Get-Date) - $t0).TotalSeconds)
  }
  if (-not $resultado) { throw "No hubo resultado en $MaxMinutos minutos" }
  Write-Host ("Medicion terminada en {0:N0} s. Destinos adicionales emulados: {1}" -f ((Get-Date) - $t0).TotalSeconds, $adjuntos)

  # Tabla legible
  $f1 = { param($x) if ($null -eq $x) { '-' } else { ([math]::Round([double]$x, 1)).ToString('0.0', [Globalization.CultureInfo]::InvariantCulture) } }
  Write-Host ''
  Write-Host ("Pagina: {0} | CPU x{1} | Red: {2} | Corridas: {3}" -f $Pagina, $cpuTxt, $(if ($Red4G) { '4G lento' } else { 'sin limitar' }), $Repetir)
  $filas = foreach ($m in $resultado.metricas) {
    [pscustomobject][ordered]@{
      Escenario   = $m.escenario
      FPS         = & $f1 $m.fps
      'Pct>20ms'  = & $f1 $m.pct20
      'Pct>50ms'  = & $f1 $m.pct50
      'Peor(ms)'  = & $f1 $m.peor
      LongTasks   = & $f1 $m.longtasks
      'LT(ms)'    = & $f1 $m.longtaskMs
      Resultado   = $m.resultado
    }
  }
  ($filas | Format-Table -AutoSize | Out-String -Width 200).TrimEnd() | Write-Host
  $nf = @($resultado.fallos).Count
  Write-Host ''
  Write-Host ("Comprobaciones: {0} | Fallos: {1}" -f $resultado.pruebas, $nf)
  foreach ($x in $resultado.fallos) { Write-Host "  X $x" }

  $salida = [ordered]@{
    pagina = $Pagina; cpu = $Cpu; gpu = $Gpu; glRenderer = $gl.result.value; red4G = [bool]$Red4G; repetir = $Repetir; modo = $Modo
    rafAboutBlankHz = $hz.result.value; fecha = (Get-Date).ToString('s')
    pruebas = $resultado.pruebas; fallos = @($resultado.fallos); metricas = @($resultado.metricas)
  }
  $json = $salida | ConvertTo-Json -Depth 8
  [IO.File]::WriteAllText($salidaJson, $json, (New-Object Text.UTF8Encoding($false)))
  Write-Host "JSON guardado en $salidaJson"
  $codigo = $(if ($nf -eq 0) { 0 } else { 1 })
}
catch {
  Write-Host "ERROR: $_"
  $codigo = 1
}
finally {
  try { if ($ws -and $ws.State -eq 'Open') { [void](Enviar-Cdp 'Browser.close' @{} '' 3000) } } catch { }
  try { if ($ws) { $ws.Dispose() } } catch { }
  Start-Sleep -Milliseconds 800
  try { if ($proc -and -not $proc.HasExited) { Stop-Process -Id $proc.Id -Force } } catch { }
  # Procesos hijos de ESTE perfil (el user-data-dir unico evita tocar otros Edge del usuario)
  try {
    Get-CimInstance Win32_Process -Filter "Name='msedge.exe'" |
      Where-Object { $_.CommandLine -and $_.CommandLine.Contains($perfil) } |
      ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
  } catch { }
  Start-Sleep -Milliseconds 500
  try { Remove-Item -Recurse -Force $perfil -ErrorAction SilentlyContinue } catch { }
}
exit $codigo
