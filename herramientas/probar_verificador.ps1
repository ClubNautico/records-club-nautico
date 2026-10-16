# Prueba el verificador: en una copia temporal introduce errores, uno por uno, y comprueba que
# verificar_datos.ps1 los detecta (sale con código 1). También exige que los datos reales pasen.
# Uso: powershell -ExecutionPolicy Bypass -File herramientas\probar_verificador.ps1
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$tmp = Join-Path $env:TEMP ("rcn_prueba_" + [guid]::NewGuid().ToString('N').Substring(0, 8))
function Copia {
  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -Confirm:$false }
  New-Item -ItemType Directory -Path "$tmp\data", "$tmp\herramientas" | Out-Null
  Copy-Item "$raiz\data\*.json" "$tmp\data\"; Copy-Item "$raiz\index.html" $tmp; Copy-Item "$raiz\herramientas\verificar_datos.ps1" "$tmp\herramientas\"
}
function Leer($n) { [IO.File]::ReadAllText("$tmp\data\$n", [Text.Encoding]::UTF8) | ConvertFrom-Json }
function Guardar($n, $o) { [IO.File]::WriteAllText("$tmp\data\$n", (ConvertTo-Json @($o) -Depth 6), (New-Object Text.UTF8Encoding $false)) }
function Correr { & powershell -NoProfile -ExecutionPolicy Bypass -File "$tmp\herramientas\verificar_datos.ps1" | Out-Null; return $LASTEXITCODE }

$casos = [ordered]@{
  'Datos reales (deben pasar)'           = { }
  'Récord borrado'                       = { $r = Leer 'records_piscina.json'; Guardar 'records_piscina.json' ($r | Select-Object -Skip 1) }
  'Fecha imposible 2025-13-45'           = { $r = Leer 'records_piscina.json'; $r[0].fecha = '2025-13-45'; Guardar 'records_piscina.json' $r }
  'Rango de fechas invertido'            = { $r = Leer 'records_piscina.json'; $r[0].fecha = '2025-01-10 a 2020-01-01'; Guardar 'records_piscina.json' $r }
  'Tiempo y segundos distintos'          = { $r = Leer 'records_piscina.json'; $r[0].segundos = [double]$r[0].segundos + 1; Guardar 'records_piscina.json' $r }
  'Top 10 con #1 distinto del récord'    = { $r = Leer 'top10_piscina.json'; $x = $r | Where-Object { $_.puesto -eq 1 } | Select-Object -First 1; $x.nadador = 'Otro, Nombre'; Guardar 'top10_piscina.json' $r }
  'Top 10 desordenado'                   = { $r = Leer 'top10_piscina.json'; $x = $r | Where-Object { $_.puesto -eq 3 } | Select-Object -First 1; $x.segundos = 1; $x.tiempo = '1.00'; Guardar 'top10_piscina.json' $r }
  'Relevo con estilo incoherente'        = { $r = Leer 'relevos_records.json'; ($r | Where-Object { $_.prueba -like '*Combinado' })[0].estilo = 'Libre'; Guardar 'relevos_records.json' $r }
  'Relevo con 3 integrantes'             = { $r = Leer 'relevos_records.json'; $r[0].integrantes = @($r[0].integrantes | Select-Object -First 3); Guardar 'relevos_records.json' $r }
  'Exhibición más rápida que el récord'  = { $r = Leer 'top10_piscina.json'; $x = $r | Where-Object { $_.puesto -eq 2 } | Select-Object -First 1; $x.marca = 'x'; $x.segundos = 1; $x.tiempo = '1.00'; Guardar 'top10_piscina.json' $r }
  'Aguas abiertas vacío'                 = { Guardar 'records_aguas_abiertas.json' @(); Guardar 'top_aguas_abiertas.json' @() }
  'Prueba con estilo desconocido'        = { $r = Leer 'records_piscina.json'; $r[0].prueba = '50 Delfin'; Guardar 'records_piscina.json' $r }
  'JSON roto'                            = { [IO.File]::WriteAllText("$tmp\data\top10_piscina.json", '[{"curso":', (New-Object Text.UTF8Encoding $false)) }
  'Pie con fecha vieja'                  = { $h = [IO.File]::ReadAllText("$tmp\index.html", [Text.Encoding]::UTF8) -replace 'Actualizado al \d{2}/\d{2}/\d{4}', 'Actualizado al 01/01/2020'; [IO.File]::WriteAllText("$tmp\index.html", $h, (New-Object Text.UTF8Encoding $false)) }
}
$fallos = 0
foreach ($nombre in $casos.Keys) {
  Copia; & $casos[$nombre]
  $code = Correr
  $esperado = if ($nombre -like 'Datos reales*') { 0 } else { 1 }
  $ok = $code -eq $esperado
  if (-not $ok) { $fallos++ }
  Write-Host ("{0} {1}  (código {2}, se esperaba {3})" -f $(if ($ok) { 'OK   ' } else { 'FALLA' }), $nombre, $code, $esperado) -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
}
Remove-Item $tmp -Recurse -Force -Confirm:$false
if ($fallos) { Write-Host "`n$fallos caso(s) no se comportaron como se esperaba." -ForegroundColor Red; exit 1 }
Write-Host "`nEl verificador detecta todos los errores de prueba." -ForegroundColor Green
exit 0
