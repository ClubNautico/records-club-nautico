# Récords Club Náutico — guía para Claude

Página estática con los récords, el Top 10 histórico, las aguas abiertas FENA y las travesías del Club Náutico (natación, Quito).
Dueño: el entrenador del club. No es programador: respóndele en español, directo y breve, sin jerga; confía en tu criterio y no hagas preguntas innecesarias.

**Lee también `CLAUDE.local.md`** (misma carpeta, no se publica: está en `.gitignore`): nombre del dueño, rutas de la PC, alias y ortografía de nombres de nadadores y notas internas.
Este archivo SÍ se publica (GitHub Pages sirve los .md): aquí no van nombres de nadadores, del dueño ni rutas locales.

## Reglas que no se pueden romper

- **El enlace y el QR no cambian nunca** (están impresos y enviados): https://clubnautico.github.io/records-club-nautico/
  - Repo `ClubNautico/records-club-nautico`, rama `main`, carpeta raíz, GitHub Pages. La página principal es `index.html`.
  - No renombres el repo, no cambies la rama de Pages, no muevas `index.html`. El `manifest.webmanifest` usa `start_url`/`scope` relativos (`./`).
- **Hay menores en la página**: conserva `<meta name="robots" content="noindex, nofollow">` y **no muestres ni publiques edades**:
  ningún JSON de `data/` puede traer la clave `edad` (el verificador da ERROR), ni fechas de nacimiento, ni IDs internos (N-###),
  ni la categoría de las travesías (suele ser la edad exacta: "M12", "F13", "14"…).
- **No inventes ni corrijas datos sin fuente oficial** (resultados FENA o torneos internacionales verificados; en travesías, los resultados del evento).
- Las marcas de exhibición (`marca = "x"`) **sí cuentan** como récord del club si son las más rápidas; la etiqueta "Exhibición" es solo informativa.
- Respeta la ortografía y los alias de nombres de `CLAUDE.local.md`.
- Las marcas del Excel oficial de Cali 2023 (piscina 50 m) son oficiales y deben seguir en los datos.
- **Las travesías no son récords oficiales FENA**: van aparte (sub-pestaña "Travesías"), con la línea que lo explica y la etiqueta "Mejor marca" (no "Récord").
  No se suman a las cifras del encabezado ("récords vigentes").

## Estructura

- `index.html` — toda la página (HTML + CSS + JS en un solo archivo, sin compilación). Lee `data/*.json` con `fetch(..., {cache:'no-cache'})`.
  - Enlaces profundos por hash: `#c=LC|SC|OW&g=M|F&p=<prueba>`; travesías: `#c=OW&g=M|F&a=TV` (también `#c=TV`). Sin `a`, `c=OW` abre las aguas abiertas FENA (enlaces viejos).
  - Pie: "Fuente: resultados oficiales FENA 2017–2026 y torneos internacionales verificados. Travesías y otras competencias: … Actualizado al dd/mm/aaaa." (busca `Actualizado al`).
  - Nombres "Nombre Apellido"; fechas dd/mm/aaaa (rangos "08 al 10/12/2022"); relevos combinados con (E)(P)(M)(L);
    relevo sin integrantes → "Integrantes no publicados en los resultados oficiales"; `lugar` vacío → "Ecuador" (no en travesías: ahí se muestra fecha · evento).
  - Error de carga: mensaje para padres sin rutas ("No se pudieron cargar los récords…") + "Reintentar"; el detalle técnico va a `console.error`.
  - Las marcas entran con opacity/transform sobre el texto real (no hay conteo desde 0: nunca se ve una marca intermedia).
- `data/` — `records_piscina.json`, `top10_piscina.json`, `relevos_records.json`, `records_aguas_abiertas.json`, `top_aguas_abiertas.json`,
  `travesias_records.json`, `travesias_top.json`. En aguas abiertas y travesías, `puesto` es la posición dentro del club, no en la carrera.
  Los de aguas abiertas FENA traen `categoria` (grupos de edad tipo "10-11", "Girls 12-13"); la página NO la muestra.
- Travesías y otras competencias (no FENA): `travesias.py` (carpeta `_records_club`, ver `CLAUDE.local.md`) → `herramientas/traer_travesias.py`
  (valida y deja solo lo publicable: sin edad, categoría ni IDs; corrige la ortografía acordada; quita notas internas del evento) → `data/travesias_*.json`.
- `assets/` — `og.png` (vista previa de WhatsApp, 1200×630), `reflejos.jpg` (reflejos del encabezado), iconos de instalación
  (`icon-192.png`, `icon-512.png`, `icon-512-maskable.png`, `apple-touch-icon.png` 180, `favicon-32.png`: cuadro azul #22409A con "R" y ola,
  el mismo motivo que el acceso del escritorio). `manifest.webmanifest` en la raíz. **Sin service worker** (a propósito).
- `historico.html` — sección aparte "Histórico 2002–2009" (decisión del dueño, 28/10/2026): mismas piezas que `index.html`
  (se genera desde ella con `hacer_historico_html.py`, ruta en `CLAUDE.local.md`; si cambias el diseño de `index.html`, vuelve a generarla),
  solo piscina 50/25 m, sin relevos, aguas abiertas ni travesías. Lee `data/historico_records.json` y `data/historico_top10.json`
  (de `hacer_historico.py`, resultados FENA 2002–2009 recuperados de web.archive.org).
  No se mezcla con los récords vigentes. Enlazada desde el pie de `index.html` ("Ver el histórico 2002–2009").
  `herramientas/dispositivos.html?pagina=historico.html` sirve para probarla.
- `anterior.html` — diseño anterior (respaldo). `opus.html` — redirige a la raíz conservando el hash (no borrar: hay enlaces viejos).
- `DESIGN.md` — colores y tipografías de la marca: azul rey #22409A, pervinca, perla, pizarra; Josefin Slab + Open Sans. Nombre visible: "Club Náutico".
- `ACTUALIZAR.md` — guía para el dueño (cambiar los JSON y publicar). Mantenla al día si cambias el proceso.

## Diseño actual ("la carrera")

Carril horizontal arriba con un nadador (sprite) que nada al desplazarse y descansa agarrado de la corchera (se oculta en celular horizontal, alto ≤500 px);
encabezado con reflejos; filas de récord con su marca; al tocar una prueba se abre su Top 10 con "Foto de llegada" y botón "Nadar la carrera";
ficha del nadador al tocar su nombre (incluye sus travesías si el nombre visible coincide); botón compartir. Debe verse y funcionar bien en celulares
(320 px en adelante, toques ≥44 px, letra del tablero ≥14 px). Instalable ("Añadir a pantalla de inicio") con manifest e iconos.

Selector: `.seg[data-key=curso]` LC | SC | OW ("50 m | 25 m | Abiertas"); con OW aparece debajo `.seg[data-key=aa]` FENA | TV
("FENA | Travesías"). Se eligió la sub-pestaña y no un cuarto botón porque a 320 px cuatro botones no caben ("Abiertas" ya ocupa casi todo)
y así LC/SC/OW y los enlaces viejos no cambian.

Rendimiento: anima solo `transform`/`opacity` (nada de `left`, `box-shadow` animado ni filtros SVG en vivo);
la carrera usa Web Animations API (`element.animate`); pausa animaciones fuera de pantalla con IntersectionObserver.
Compatibilidad: sin `??`, `?.` ni `\p{L}` (Safari < 13.4 deja la página en blanco). CSP y `referrer` en `<meta>` del `<head>`.

## Verificación antes de publicar (obligatoria)

Servidor local (solo responde a esta PC, puerto **8766**; 8765 lo usan otras páginas):
`powershell -NoProfile -ExecutionPolicy Bypass -File .claude\serve.ps1 -Port 8766` (o `.claude/launch.json`, configuración "records").

1. Datos: `powershell -ExecutionPolicy Bypass -File herramientas\verificar_datos.ps1` → debe decir "OK: datos verificados, sin errores".
   (`herramientas\probar_verificador.ps1` comprueba que el verificador detecta errores, incluida la clave `edad` y las travesías.)
2. Funcional: `herramientas/verificar.html` → "✓ Todo bien" (~7.000 comprobaciones, con travesías). Acepta `?pagina=otra.html`.
3. Celulares: `herramientas/dispositivos.html` → "OK" en 9 tamaños (320×568 a 1440×900), incluida la vista de travesías.
4. Visual: `herramientas/vista.html?w=360,390&escala=3` (iframes con tamaños de teléfono; admite `&hash=`, p. ej. `&hash=c%3DOW%26g%3DF%26a%3DTV`).
5. Fluidez (opcional): `herramientas/rendimiento.html` o
   `powershell -NoProfile -ExecutionPolicy Bypass -File herramientas\medir_movil.ps1 -Pagina index.html -Cpu 6 -Repetir 3 -Gpu hw`.
   La PC es lenta y ruidosa: compara intercalando corridas; esta métrica mide el hilo principal, no las animaciones de la GPU.

Si cambias el DOM, respeta lo que esperan las pruebas: `.seg[data-key=curso]` (LC/SC/OW), `.seg[data-key=genero]` (M/F) y
`.seg[data-key=aa]` (FENA/TV, oculto fuera de OW) con `aria-pressed`;
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
Nunca le digas al dueño que algo está publicado sin esta comprobación. En los celulares la caché tarda ~10 minutos.

## Datos fuente

Los JSON se generan en el proyecto "Club - Reportes y tests" con los scripts de la carpeta `_records_club` (rutas, versiones y
detalles en `CLAUDE.local.md`). Usar siempre los JSON de esta carpeta `data/` como base (tienen Cali 2023 y la ortografía acordada).
Desde el 12/11/2026 `fusionar_top10.py` ya no escribe `edad`. Travesías: ver "Estructura" y `ACTUALIZAR.md`.

## Entorno (Windows)

- PowerShell 5.1: guarda los scripts `.ps1` con UTF-8 **con BOM**; usa rutas cortas (<260 caracteres) con `-File`; `ConvertFrom-Json` necesita `| ForEach-Object {$_}` para desenrollar arreglos.
- No hay Node. Hay Python (sin Pillow): los iconos PNG se hicieron con PowerShell + System.Drawing. Edge headless sirve para medir, pero sus capturas fallan bajo ~500 px de ancho: usa `vista.html`.
