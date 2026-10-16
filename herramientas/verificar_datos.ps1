# Verifica los JSON de data/ antes de publicar. Recorre cada fila y cada prueba.
# Uso: powershell -ExecutionPolicy Bypass -File herramientas\verificar_datos.ps1
# Termina con código 0 si todo está bien y 1 si hay errores (los avisos no bloquean).
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$errores = New-Object System.Collections.Generic.List[string]
$avisos = New-Object System.Collections.Generic.List[string]
function Err($m) { $errores.Add($m) }
function Aviso($m) { $avisos.Add($m) }
function Leer($n) {
  $p = Join-Path $raiz "data\$n"
  if (-not (Test-Path $p)) { Err "Falta data\$n"; return @() }
  try { return @([IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) | ConvertFrom-Json) }
  catch { Err "data\$n no es JSON válido: $($_.Exception.Message)"; return @() }
}
$reTiempo = '^(\d{1,2}:)?(\d{1,2}:)?\d{1,2}\.\d{2}$'
$reFecha = '^\d{4}-\d{2}-\d{2}( a \d{4}-\d{2}-\d{2})?$'
$hoy = Get-Date
$fechaMax = [datetime]::MinValue
# Devuelve '' si la fecha (o rango "AAAA-MM-DD a AAAA-MM-DD") es real y está en orden; si no, el problema
function ProblemaFecha($f) {
  if ("$f" -notmatch $reFecha) { return "formato raro" }
  $ds = @()
  foreach ($p in ("$f" -split ' a ')) {
    try { $ds += [datetime]::ParseExact($p, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture) } catch { return "fecha imposible ($p)" }
  }
  if ($ds.Count -eq 2 -and $ds[1] -lt $ds[0]) { return "rango invertido" }
  if ($ds[0] -lt [datetime]'2000-01-01' -or $ds[-1] -gt $hoy.AddDays(1)) { return "fuera de rango (antes de 2000 o en el futuro)" }
  if ($ds[-1] -gt $script:fechaMax) { $script:fechaMax = $ds[-1] }
  return ''
}
# Estilo según el nombre de la prueba ("200 Pecho" -> Pecho), que es lo que la página usa para agrupar
function EstiloDe($p) { $x = "$p".Trim() -split '\s+'; if ($x.Count -ge 2) { return $x[1] } else { return '' } }
$rangoOrden = @{ Libre = 0; Mariposa = 10; Espalda = 20; Pecho = 30; Combinado = 40 }
function Seg($t) { $p = $t -split ':'; $s = 0.0; foreach ($x in $p) { $s = $s * 60 + [double]::Parse($x, [Globalization.CultureInfo]::InvariantCulture) }; return [Math]::Round($s, 2) }

$rec = Leer 'records_piscina.json'
$top = Leer 'top10_piscina.json'
$rel = Leer 'relevos_records.json'
$owRec = Leer 'records_aguas_abiertas.json'
$owTop = Leer 'top_aguas_abiertas.json'

# Pruebas esperadas por piscina (100 combinado individual solo en 25 m)
$base = '50 Libre','100 Libre','200 Libre','400 Libre','800 Libre','1500 Libre','50 Mariposa','100 Mariposa','200 Mariposa','50 Espalda','100 Espalda','200 Espalda','50 Pecho','100 Pecho','200 Pecho','200 Combinado','400 Combinado'
$esperadas = @{ LC = $base; SC = $base + '100 Combinado' }
$relEsperados = '4x50 Libre','4x100 Libre','4x50 Combinado','4x100 Combinado'

# ---- Filas individuales (récords y top 10) ----
foreach ($par in @(@{ n = 'records'; d = $rec }, @{ n = 'top10'; d = $top })) {
  $i = 0
  foreach ($r in $par.d) {
    $i++; $id = "$($par.n)[$i] $($r.curso) $($r.genero) $($r.prueba) $($r.tiempo)"
    foreach ($c in 'curso','genero','prueba','orden','tiempo','segundos','nadador','fecha','torneo') { if ($null -eq $r.$c -or "$($r.$c)" -eq '') { Err "$id sin '$c'" } }
    if ($r.curso -notin 'LC','SC') { Err "$id curso inválido" }
    if ($r.genero -notin 'M','F') { Err "$id género inválido" }
    if ($r.tiempo -notmatch $reTiempo) { Err "$id tiempo con formato raro" }
    elseif ([Math]::Abs((Seg $r.tiempo) - [double]$r.segundos) -gt 0.011) { Err "$id 'segundos' ($($r.segundos)) no coincide con 'tiempo'" }
    $pf = ProblemaFecha $r.fecha; if ($pf) { Err "$id fecha '$($r.fecha)': $pf" }
    $est = EstiloDe $r.prueba
    if (-not $rangoOrden.ContainsKey($est)) { Err "$id prueba '$($r.prueba)' con estilo desconocido (saldrá en 'Otras pruebas')" }
    else {
      if ($r.estilo -and $r.estilo -ne $est) { Err "$id campo estilo '$($r.estilo)' no coincide con la prueba" }
      if ([int]$r.orden -lt $rangoOrden[$est] -or [int]$r.orden -ge $rangoOrden[$est] + 10) { Aviso "$id orden $($r.orden) fuera del rango habitual de $est" }
    }
    if ($r.nadador -notmatch ',') { Aviso "$id nombre sin coma (no es 'Apellido, Nombre')" }
    if ($r.marca -notin '', 'x', 'J', $null) { Aviso "$id marca desconocida '$($r.marca)'" }
  }
}

# ---- Récords: exactamente uno por prueba (las marcas de exhibición "x" cuentan igual) ----
foreach ($c in 'LC','SC') { foreach ($g in 'M','F') {
  $sub = @($rec | Where-Object { $_.curso -eq $c -and $_.genero -eq $g })
  foreach ($p in $esperadas[$c]) {
    $n = @($sub | Where-Object { $_.prueba -eq $p }).Count
    if ($n -ne 1) { Err "Récords $c $g '$p': hay $n (debe haber 1)" }
  }
  foreach ($x in $sub) { if ($x.prueba -notin $esperadas[$c]) { Err "Récords $c $g prueba inesperada '$($x.prueba)'" } }
} }

# ---- Top 10: puestos 1..n, orden por tiempo, un nadador una vez, #1 = récord ----
foreach ($grupo in ($top | Group-Object curso, genero, prueba)) {
  $f = @($grupo.Group | Sort-Object { [int]$_.puesto })
  $id = "Top10 $($grupo.Name)"
  if ($f.Count -gt 10) { Err "$id tiene $($f.Count) filas" }
  for ($k = 0; $k -lt $f.Count; $k++) {
    if ([int]$f[$k].puesto -ne $k + 1) { Err "$id puestos no consecutivos (en la fila $($k+1) dice $($f[$k].puesto))" ; break }
    if ($k -gt 0 -and [double]$f[$k].segundos -lt [double]$f[$k - 1].segundos) { Err "$id puesto $($k+1) es más rápido que el $k" }
  }
  $dup = $f | Group-Object nadador | Where-Object Count -gt 1
  foreach ($d in $dup) { Err "$id nadador repetido: $($d.Name)" }
  $r1 = $rec | Where-Object { $_.curso -eq $f[0].curso -and $_.genero -eq $f[0].genero -and $_.prueba -eq $f[0].prueba }
  if (-not $r1) { Err "$id no tiene récord correspondiente" }
  elseif ($r1.tiempo -ne $f[0].tiempo -or $r1.nadador -ne $f[0].nadador) { Err "$id puesto 1 ($($f[0].tiempo) $($f[0].nadador)) no coincide con el récord ($($r1.tiempo) $($r1.nadador))" }
  if ($f.Count -lt 10) { Aviso "$id tiene solo $($f.Count) nadadores" }
}
foreach ($r in $rec) { if (-not ($top | Where-Object { $_.curso -eq $r.curso -and $_.genero -eq $r.genero -and $_.prueba -eq $r.prueba })) { Err "Récord $($r.curso) $($r.genero) $($r.prueba) sin Top 10" } }

# ---- Relevos ----
foreach ($c in 'LC','SC') { foreach ($g in 'M','F','Mixto') {
  $sub = @($rel | Where-Object { $_.curso -eq $c -and $_.genero -eq $g })
  $esp = if ($c -eq 'LC' -and $g -ne 'Mixto') { $relEsperados + '4x200 Libre' } else { $relEsperados }
  foreach ($p in $esp) { $n = @($sub | Where-Object { $_.prueba -eq $p }).Count; if ($n -ne 1) { Err "Relevos $c $g '$p': hay $n (debe haber 1)" } }
  foreach ($x in $sub) { if ($x.prueba -notin $esp) { Aviso "Relevos $c $g prueba adicional '$($x.prueba)' (se mostrará)" } }
} }
foreach ($r in $rel) {
  $id = "Relevo $($r.curso) $($r.genero) $($r.prueba) $($r.tiempo)"
  if ($r.tiempo -notmatch $reTiempo) { Err "$id tiempo con formato raro" }
  $rango = if ($r.fecha_fin -and $r.fecha_fin -ne $r.fecha_ini) { "$($r.fecha_ini) a $($r.fecha_fin)" } else { "$($r.fecha_ini)" }
  $pf = ProblemaFecha $rango; if ($pf) { Err "$id fecha '$rango': $pf" }
  $est = EstiloDe $r.prueba
  if ($est -notin 'Libre','Combinado') { Err "$id prueba '$($r.prueba)' con estilo desconocido" }
  elseif ($r.estilo -and $r.estilo -ne $est) { Err "$id campo estilo '$($r.estilo)' no coincide con la prueba" }
  if ($r.genero -notin 'M','F','Mixto') { Err "$id género inválido" }
  if (-not $r.torneo) { Err "$id sin torneo" }
  $ni = @($r.integrantes).Count
  if ($ni -ne 0 -and $ni -ne 4) { Err "$id tiene $ni integrantes" }
  if ($ni -eq 0) { Aviso "$id sin integrantes (se mostrará la nota)" }
}

# ---- Aguas abiertas: campos, y récord = puesto 1 del top ----
if ($owRec.Count -eq 0 -or $owTop.Count -eq 0) { Err "Aguas abiertas: archivo vacío (la pestaña quedaría en blanco)" }
$i = 0
foreach ($r in @($owRec) + @($owTop)) {
  $i++; $id = "Aguas abiertas fila $i $($r.distancia) $($r.rama) $($r.tiempo)"
  foreach ($c in 'distancia','dist_km','rama','tiempo','segundos','nadador','fecha','torneo') { if ($null -eq $r.$c -or "$($r.$c)" -eq '') { Err "$id sin '$c'" } }
  if ($r.tiempo -match $reTiempo -and [Math]::Abs((Seg $r.tiempo) - [double]$r.segundos) -gt 0.011) { Err "$id 'segundos' no coincide con 'tiempo'" }
  $pf = ProblemaFecha $r.fecha; if ($pf) { Err "$id fecha '$($r.fecha)': $pf" }
}
foreach ($r in $owTop) { if ($null -eq $r.puesto -or "$($r.puesto)" -notmatch '^\d+$') { Err "Top aguas abiertas $($r.distancia) $($r.rama) $($r.tiempo) sin puesto válido" } }
foreach ($r in $owRec) {
  $id = "Aguas abiertas $($r.distancia) $($r.rama)"
  if ($r.rama -notin 'M','F') { Err "$id rama inválida" }
  if ($r.tiempo -notmatch $reTiempo) { Err "$id tiempo con formato raro" }
  $t1 = $owTop | Where-Object { $_.distancia -eq $r.distancia -and $_.rama -eq $r.rama -and [int]$_.puesto -eq 1 }
  if (-not $t1) { Err "$id sin puesto 1 en el top" } elseif ($t1.tiempo -ne $r.tiempo -or $t1.nadador -ne $r.nadador) { Err "${id}: récord y puesto 1 del top no coinciden" }
}
foreach ($g in ($owTop | Group-Object distancia, rama)) {
  $f = @($g.Group | Sort-Object { [int]$_.puesto })
  for ($k = 0; $k -lt $f.Count; $k++) { if ([int]$f[$k].puesto -ne $k + 1) { Err "Top aguas abiertas $($g.Name): puestos no consecutivos"; break }; if ($k -gt 0 -and [double]$f[$k].segundos -lt [double]$f[$k-1].segundos) { Err "Top aguas abiertas $($g.Name): orden de tiempos" } }
  if (-not ($owRec | Where-Object { "$($_.distancia), $($_.rama)" -eq $g.Name })) { Err "Top aguas abiertas $($g.Name) sin récord" }
}

# ---- Pie de página y vista previa ----
$html = [IO.File]::ReadAllText((Join-Path $raiz 'index.html'), [Text.Encoding]::UTF8)
if ($html -notmatch 'Actualizado al (\d{2}/\d{2}/\d{4})') { Err "index.html: falta 'Actualizado al dd/mm/aaaa' en el pie" }
else {
  $pie = $Matches[1]; Write-Host "Fecha del pie: $pie · marca más reciente en los datos: $($fechaMax.ToString('dd/MM/yyyy'))"
  try { $dPie = [datetime]::ParseExact($pie, 'dd/MM/yyyy', [Globalization.CultureInfo]::InvariantCulture); if ($dPie -lt $fechaMax) { Err "La fecha del pie ($pie) es anterior a la marca más reciente ($($fechaMax.ToString('dd/MM/yyyy'))): actualízala en index.html" } }
  catch { Err "La fecha del pie '$pie' no es una fecha real" }
}
if ($html -match 'property="og:image" content="(?!https://)') { Aviso "og:image no es una URL completa (https://...): WhatsApp puede no mostrar la imagen" }

Write-Host ""
Write-Host "Récords: $($rec.Count) · Top 10: $($top.Count) filas · Relevos: $($rel.Count) · Aguas abiertas: $($owRec.Count) récords / $($owTop.Count) filas"
if ($avisos.Count) { Write-Host "`nAvisos ($($avisos.Count)):" -ForegroundColor Yellow; $avisos | ForEach-Object { Write-Host "  - $_" } }
if ($errores.Count) { Write-Host "`nERRORES ($($errores.Count)):" -ForegroundColor Red; $errores | ForEach-Object { Write-Host "  - $_" }; exit 1 }
Write-Host "`nOK: datos verificados, sin errores." -ForegroundColor Green
exit 0
