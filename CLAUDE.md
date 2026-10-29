# Récords Club Náutico — guía para Claude

Página estática con los récords, el Top 10 histórico y las aguas abiertas del Club Náutico (natación, Quito).
Dueño: Ricardo Armas, entrenador. No es programador: respóndele en español, directo y breve, sin jerga.
Ha pedido que confíes en tu criterio y no le hagas preguntas innecesarias.

## Reglas que no se pueden romper

- **El enlace y el QR no cambian nunca** (están impresos y enviados): https://clubnautico.github.io/records-club-nautico/
  - Repo `ClubNautico/records-club-nautico`, rama `main`, carpeta raíz, GitHub Pages. La página principal es `index.html`.
  - No renombres el repo, no cambies la rama de Pages, no muevas `index.html`.
- **Hay menores en la página**: conserva `<meta name="robots" content="noindex, nofollow">` y **no muestres edades**.
- **No inventes ni corrijas datos sin fuente oficial** (resultados FENA o torneos internacionales verificados).
- Las marcas de exhibición (`marca = "x"`) **sí cuentan** como récord del club si son las más rápidas; la etiqueta "Exhibición" es solo informativa.
- La nadadora se escribe **"Natalí"** (Fustillos, Natalí), no Nataly.
- Las marcas del Excel oficial de Cali 2023 (piscina 50 m) son oficiales y deben seguir en los datos.

## Estructura

- `index.html` — toda la página (HTML + CSS + JS en un solo archivo, sin compilación). Lee `data/*.json` con `fetch(..., {cache:'no-cache'})`.
  - Enlaces profundos por hash: `#c=LC|SC|OW&g=M|F&p=<prueba>`.
  - Pie: "Fuente: resultados oficiales FENA 2017–2026 y torneos internacionales verificados. Actualizado al dd/mm/aaaa." (busca `Actualizado al`).
  - Nombres "Nombre Apellido"; fechas dd/mm/aaaa (rangos "08 al 10/12/2022"); relevos combinados con (E)(P)(M)(L);
    relevo sin integrantes → "Integrantes no publicados en los resultados oficiales"; `lugar` vacío → "Ecuador".
- `data/` — `records_piscina.json`, `top10_piscina.json`, `relevos_records.json`, `records_aguas_abiertas.json`, `top_aguas_abiertas.json`.
  En aguas abiertas, `puesto` es la posición dentro del club, no en la carrera.
- `assets/` — `og.png` (vista previa de WhatsApp, 1200×630), `reflejos.jpg` (reflejos del encabezado).
- `anterior.html` — diseño anterior (respaldo). `opus.html` — redirige a la raíz conservando el hash (no borrar: hay enlaces viejos).
- `DESIGN.md` — colores y tipografías de la marca (natacionluciorojas.com): azul rey #22409A, pervinca, perla, pizarra; Josefin Slab + Open Sans. Nombre visible: "Club Náutico".
- `ACTUALIZAR.md` — guía para Ricardo (cambiar los JSON y publicar). Mantenla al día si cambias el proceso.

## Diseño actual ("la carrera")

Carril horizontal arriba con un nadador (sprite) que nada al desplazarse y descansa agarrado de la corchera; encabezado con reflejos;
filas de récord con reloj de competencia; al tocar una prueba se abre su Top 10 con "Foto de llegada" y botón "Nadar la carrera";
ficha del nadador al tocar su nombre; botón compartir. Debe verse y funcionar bien en celulares (320 px en adelante, toques ≥44 px).

Rendimiento: anima solo `transform`/`opacity` (nada de `left`, `box-shadow` animado ni filtros SVG en vivo);
la carrera usa Web Animations API (`element.animate`); pausa animaciones fuera de pantalla con IntersectionObserver.

## Verificación antes de publicar (obligatoria)

Servidor local: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\serve.ps1 -Port 8765` (si no existe, cualquier servidor estático sirve).

1. Datos: `powershell -ExecutionPolicy Bypass -File herramientas\verificar_datos.ps1` → debe decir "OK: datos verificados, sin errores".
   (`herramientas\probar_verificador.ps1` comprueba que el verificador detecta errores.)
2. Funcional: `herramientas/verificar.html` → "✓ Todo bien" (~6.584 comprobaciones). Acepta `?pagina=otra.html`.
3. Celulares: `herramientas/dispositivos.html` → "OK" en 9 tamaños (320×568 a 1440×900).
4. Visual: `herramientas/vista.html?w=360,390&escala=3` (iframes con tamaños de teléfono; admite `&hash=`).
5. Fluidez (opcional): `herramientas/rendimiento.html` o
   `powershell -NoProfile -ExecutionPolicy Bypass -File herramientas\medir_movil.ps1 -Pagina index.html -Cpu 6 -Repetir 3 -Gpu hw`.
   La PC es lenta y ruidosa: compara intercalando corridas; esta métrica mide el hilo principal, no las animaciones de la GPU.

Si cambias el DOM, respeta lo que esperan las pruebas: `.seg[data-key=curso]` (LC/SC/OW) y `.seg[data-key=genero]` (M/F) con `aria-pressed`;
`a.item.rowlink[data-prueba][aria-expanded]` seguido de `div.top10[data-prueba]`; carril con `data-carril`, `aria-hidden` y `pointer-events:none`.

## Publicar

```bash
git add -A
git commit -m "Descripción en español"
git push
```

Si `git push` pide usuario, ejecuta `gh auth setup-git`. Después **confirma** que Pages publicó tu commit:

```bash
gh api repos/ClubNautico/records-club-nautico/pages/builds/latest --jq '.status + " " + .commit'
```

Debe decir `built` y el hash de `git rev-parse HEAD`. Luego abre verificar.html y dispositivos.html en la URL publicada.
Nunca le digas a Ricardo que algo está publicado sin esta comprobación. En los celulares la caché tarda ~10 minutos.

## Datos fuente

Carpeta de Dropbox de Ricardo: `C:\Users\secre\Dropbox\CLUB NAUTICO 2026 (1)\REPORTES NADADORES\Resultados FENA historico\`
(PDF de FENA, Excel de Cali 2023, y `_records_club\` con CSV, scripts y la versión final). Los JSON se generan en el proyecto "Club - Reportes y tests".
Actualización del 28/10/2026 (Cali 2025, Selectivo Pichincha 2025, aguas abiertas FENA 2020–2023 con festivales de 500 m a 2,5 km):
scripts en `_records_club\ACTUALIZACION 2026-10-27\scripts\` — `fusionar_top10.py` (suma marcas nuevas a `data/top10_piscina.json`) y `aa_fena.py`
(aguas abiertas desde `_records_club\aguas_abiertas_club.csv`). Usar siempre los JSON de esta carpeta `data/` como base: tienen Cali 2023 y "Natalí".
Procedimiento completo: `REPORTES NADADORES\_CLAUDE (archivos de Claude para Claude)\documentos del proyecto\10_PROCEDIMIENTO_RESULTADOS_Y_RECORDS.md`.
Alias conocido: "Ramos Robalino, Erick" en los PDF = Adrian Ramos. Pendiente sin resolver: Steven Navas nadó ANAMG 2026 como invitado ("INVI"), no se agregó.
Reclamos de Natalí sin documento oficial (no agregar sin prueba): Pentatlón Rancho 2023 y "Chequeo Regatas 2020".

## Entorno (Windows)

- PowerShell 5.1: guarda los scripts `.ps1` con UTF-8 **con BOM**; usa rutas cortas (<260 caracteres) con `-File`; `ConvertFrom-Json` necesita `| ForEach-Object {$_}` para desenrollar arreglos.
- No hay Node. Hay Python (sin Pillow). Edge headless sirve para medir, pero sus capturas fallan bajo ~500 px de ancho: usa `vista.html`.
