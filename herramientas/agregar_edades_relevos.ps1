# Agrega el campo "edades" (edad de cada integrante, en orden de nado) a data/relevos_records.json,
# tomándolo de relevos_club.csv (extraído de los PDFs FENA). No cambia ningún otro campo.
# Uso: powershell -ExecutionPolicy Bypass -File herramientas\agregar_edades_relevos.ps1 -Csv "<ruta a relevos_club.csv>"
param(
  [Parameter(Mandatory = $true)][string]$Csv,
  [string]$Json = ''
)
$ErrorActionPreference = 'Stop'
if (-not $Json) { $Json = Join-Path (Split-Path -Parent $PSScriptRoot) 'data\relevos_records.json' }
$rel = [IO.File]::ReadAllText($Json, [Text.Encoding]::UTF8) | ConvertFrom-Json
$filas = Import-Csv $Csv -Encoding UTF8
$sinDato = @()
foreach ($r in $rel) {
  $c = @($filas | Where-Object {
      $_.piscina -eq $r.curso -and $_.sexo -eq $r.genero -and $_.estilo -eq $r.estilo -and
      [int]$_.distancia_posta -eq [int]$r.posta -and $_.tiempo -eq $r.tiempo -and
      ($_.fecha -eq $r.fecha_ini -or $_.fecha -eq '' -or $_.fecha -eq $null)
    })
  # Desempate: mismos integrantes (apellido) en el mismo orden
  if ($c.Count -gt 1) {
    $c = @($c | Where-Object { $f = $_; $ok = $true; for ($i = 0; $i -lt 4; $i++) { $a = ($r.integrantes[$i] -split ',')[0].Trim().ToLower(); if (-not $f."n$($i+1)".ToLower().StartsWith($a.Substring(0, [Math]::Min(4, $a.Length)))) { $ok = $false } }; $ok })
  }
  $ed = $null
  if ($c.Count -eq 1) {
    $ed = @(1..4 | ForEach-Object { ($c[0]."edad$_" -replace '\D', '') })
    if (($ed | Where-Object { $_ }).Count -eq 0) { $ed = $null }
  }
  if ($ed) { $r | Add-Member -NotePropertyName edades -NotePropertyValue $ed -Force }
  else { $sinDato += "$($r.curso) $($r.genero) $($r.prueba) $($r.tiempo) (coincidencias: $($c.Count))" }
}
$out = $rel | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($Json, $out, (New-Object Text.UTF8Encoding $false))
Write-Host "Relevos con edades: $(@($rel | Where-Object { $_.edades }).Count) de $($rel.Count)"
if ($sinDato) { Write-Host "Sin edades:"; $sinDato | ForEach-Object { Write-Host "  $_" } }
