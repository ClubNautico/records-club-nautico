---
version: alpha
name: Records-Club-Nautico
description: Página pública de récords de natación competitiva del Club Náutico (Quito). Una "piscina vista desde la tribuna": hero azul rey con banderines de espalda y corcheras, listas claras con las marcas como protagonistas y un tablero de resultados oscuro donde se despliega cada Top 10. El scroll se mide con un carril de piscina real (corchera + nadador). Móvil primero, claro y oscuro automáticos.
colors:
  brand: "#22409A"        # azul rey
  brand-deep: "#1C3480"
  pervinca: "#5970B3"
  perla: "#BEC7CD"
  pizarra: "#313E4F"
  ink: "#292B2D"           # casi negro
  claro: "#C8CFE6"         # azul claro
  agua: "#DCE3F5"
  amber: "#FFC93C"         # señal: marcador/récord (único color fuera de la paleta del club)
typography:
  display: { fontFamily: "Josefin Slab", fontWeight: 700 }
  text:    { fontFamily: "Open Sans",   fontWeight: "400/600/700/800" }
rounded: { sm: 4px, md: 6px, full: 9999px }
spacing: { s1: 4px, s2: 8px, s3: 12px, s4: 16px, s5: 24px, s6: 32px, s7: 48px, s8: 72px }
---

# DESIGN.md — Récords Club Náutico

Entregable de diseño para reescribir `index.html` (HTML+CSS+JS puro, sin build). Se revisa por ciclos contra la sección 12 (checklist). Todo lo no dicho aquí se hereda del comportamiento actual de `index.html` (carga de datos, hash, alternar Top 10, textos).

## 1. Dirección de arte

**"La tribuna del Club": la hoja de resultados de un campeonato, vista desde la piscina.** Azul rey sólido y blanco como el borde de la piscina; tipografía de cartel (Josefin Slab) para los títulos; las marcas en cifras grandes y tabulares como en un marcador; y el Top 10 se abre como un *tablero de resultados* oscuro (pizarra) dentro de la lista clara.

Por qué:
- La audiencia son padres y nadadores que llegan de un QR o WhatsApp para **encontrar una marca en 5 segundos** en el celular. La emoción vive en el tiempo (cifra), el nombre y la prueba; todo lo demás se calla.
- La identidad la dan objetos reales de la natación competitiva (banderines de espalda a 5 m de la pared, corcheras con flotadores, línea T del fondo, tablero de tiempos), no adornos: cada uno cumple una función (separar, enmarcar, indicar progreso).
- Es lo opuesto a la plantilla genérica: sin tarjetas con sombra, sin gradientes, sin degradados morados, sin emojis, sin iconos en cuadritos, sin etiquetas pequeñas en mayúsculas espaciadas. La profundidad viene de saltos de tono (blanco / azul pálido / pizarra) y no de sombras.
- Una sola "voz" de color de alerta: ámbar marcador (#FFC93C), usado solo donde el sistema habla de marcas (puesto 1 en tablero, extremos de corchera, cofia del nadador, etiqueta de exhibición en tablero). Fuera de ese uso, solo la paleta del club.

Mapa de decisiones anti-genéricas (impeccable + taste): sin eyebrow sobre títulos (el "Club Náutico" del hero es el nombre de marca, no una etiqueta); sin numeración de secciones (los números del tablero son puestos reales; los números de carril del arte del hero son parte del dibujo, `aria-hidden`); sin hairlines decorativas (solo separadores de filas de datos, que son una tabla); sin monoespaciada; sin glassmorphism; una sola animación protagonista (el carril) y una entrada del hero; tipografía con 5 tamaños de trabajo; botones planos de esquina recta (4 px).

## 2. Tokens

### 2.1 Color (tema claro por defecto, oscuro por `prefers-color-scheme`)

| Token | Claro | Oscuro | Rol |
|---|---|---|---|
| `--bg` | #F3F5FA | #0F1524 | fondo de página |
| `--surface` | #FFFFFF | #18203A | filas/listas, controles |
| `--surface-2` | #E6EAF5 | #121A31 | fila abierta, hover |
| `--ink` | #292B2D | #E8ECF5 | texto principal |
| `--ink-2` | #313E4F | #C8CFE6 | subtítulos |
| `--muted` | #4A5668 | #A7B3CC | metadatos (fecha, lugar, torneo) |
| `--brand` | #22409A | #9FB2F2 | acciones/enlaces/cifras de énfasis (en oscuro se aclara) |
| `--on-brand` | #FFFFFF | #0F1524 | texto sobre `--sel` |
| `--sel` | #22409A | #C8CFE6 | botón seleccionado / indicador |
| `--hero` | #22409A | #1C3480 | fondo del hero |
| `--hero-ink` | #FFFFFF | #FFFFFF | título hero |
| `--hero-sub` | #C8CFE6 | #C8CFE6 | bajada hero |
| `--board` | #313E4F | #0A0F1D | tablero del Top 10 y de aguas abiertas |
| `--board-ink` | #FFFFFF | #FFFFFF | tiempo/nombre en tablero |
| `--board-muted` | #BEC7CD | #BEC7CD | meta en tablero |
| `--line` | #CBD3E6 | #2C3858 | separador de filas de datos |
| `--agua` | #DCE3F5 | #16215A | agua del carril y fondo de `html` |
| `--float-a` / `--float-b` | #22409A / #5970B3 | #C8CFE6 / #5970B3 | flotadores |
| `--end-float` | #FFC93C | #FFC93C | flotadores de los 5 m finales (contorno 1 px `--brand` en claro) |
| `--sw-body` / `--sw-cap` | #22409A / #FFC93C | #C8CFE6 / #FFC93C | nadador |
| `--record` | #8A5A00 | #FFC93C | texto de "Récord" fuera de tablero (claro usa ocre oscuro) |
| `--warn-bg` / `--warn-fg` | #FFF3D6 / #5E4200 | #3A2C10 / #F3D79C | Exhibición, notas |
| `--tag-bg` / `--tag-fg` | #DDE3F4 / #22409A | #26346B / #DDE3F8 | etiquetas "Mixto", "Récord" |
| `--err-bg` / `--err-fg` | #FDECEC / #6B1D1D | #4A1B1B / #FFD6D6 | errores |
| `--focus` | #22409A | #C8CFE6 | anillo de foco (3 px, offset 2 px) |

Razones de contraste calculadas (WCAG 2.x). Texto normal ≥ 4,5; texto grande y gráficos ≥ 3.

| Par | Razón |
|---|---|
| ink #292B2D / bg #F3F5FA | 13,03 |
| ink / surface #FFF | 14,21 |
| ink / surface-2 #E6EAF5 | 11,81 |
| ink-2 #313E4F / surface | 10,87 |
| muted #4A5668 / surface · bg · surface-2 | 7,44 · 6,82 · 6,18 |
| brand #22409A / surface · bg · surface-2 | 9,26 · 8,49 · 7,70 |
| blanco / brand (botón seleccionado, hero) | 9,26 |
| claro #C8CFE6 / brand (bajada hero) | 5,96 |
| claro / brand-deep #1C3480 (hero oscuro) | 7,30 |
| blanco / pizarra #313E4F (tablero claro) | 10,87 |
| perla #BEC7CD / pizarra | 6,33 |
| ámbar #FFC93C / pizarra | 7,07 |
| ink / ámbar (etiqueta Exhibición en tablero) | 9,25 |
| Récord claro `--record` #8A5A00 / surface · bg | 5,93 · 5,43 |
| warn-fg #5E4200 / warn-bg #FFF3D6 | 8,44 |
| tag brand / #DDE3F4 | 7,22 |
| err #6B1D1D / #FDECEC | 10,11 |
| Oscuro: ink #E8ECF5 / bg · surface | 15,39 · 13,58 |
| Oscuro: muted #A7B3CC / surface · bg | 7,63 · 8,64 |
| Oscuro: brand #9FB2F2 / surface · bg · surface-2 | 7,75 · 8,78 · 8,31 |
| Oscuro: #0F1524 / sel #C8CFE6 (seleccionado) | 11,73 |
| Oscuro: blanco / tablero #0A0F1D | 19,11 |
| Oscuro: perla / tablero · ámbar / tablero | 11,14 · 12,44 |
| Oscuro: ámbar / surface | 10,46 |
| Oscuro: warn #F3D79C / #3A2C10 | 9,70 |
| Oscuro: tag #DDE3F8 / #26346B | 9,19 |
| Oscuro: err #FFD6D6 / #4A1B1B | 10,82 |
| Nadador claro #22409A / agua #DCE3F5 | 7,21 |
| Nadador oscuro #C8CFE6 / agua #16215A | 9,66 |
| Foco claro brand / bg | 8,49 · oscuro #C8CFE6 / bg: 11,73 |

Decorativos sin requisito de texto: pervinca #5970B3 (4,78 sobre blanco, solo flotadores y líneas), perla en líneas, separadores `--line` (1,38 claro; son separadores de filas, la fila se identifica por su texto). Los flotadores blancos NO se usan sobre agua clara (1,28): alternan azul rey/pervinca.

**Tema: ambos, automático.** Claro por defecto (QR impreso, uso a pleno sol en la piscina/tribuna) y oscuro cuando el sistema lo pide (consulta nocturna en WhatsApp, ahorra batería OLED). El hero conserva el azul de marca en ambos para que la identidad no cambie. Sin interruptor manual (menos interfaz); se conserva `:root[data-theme]` como gancho para pruebas. `color-scheme: light dark`. `<meta name="theme-color">` dos veces con `media`: #22409A (claro) y #1C3480 (oscuro).

### 2.2 Tipografía

Google Fonts, una sola petición: `https://fonts.googleapis.com/css2?family=Josefin+Slab:wght@600..700&family=Open+Sans:wght@400..800&display=swap` con `preconnect` a `fonts.googleapis.com` y `fonts.gstatic.com` (crossorigin). Solo estas dos familias (no hay tercera: los tiempos van en Open Sans 800, cuyos dígitos ya son tabulares, y se ahorra una descarga en datos móviles; una fuente "de marcador" tipo 7 segmentos se descartó por legibilidad y por parecer disfraz).

- `--f-display: "Josefin Slab", "Roboto Slab", Rockwell, Georgia, serif` — SOLO títulos y marca (hero, h2, h3 de grupo, cabecera del tablero). Peso 700 (600 no se usa bajo 22 px: las astas finas de Josefin se pierden en celulares).
- `--f-text: "Open Sans", system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif` — todo lo demás.
- Cifras: `font-variant-numeric: tabular-nums lining-nums`. Tiempos 800, puestos 800.
- Si las fuentes no cargan, se ve la pila de sistema sin reflujo grave: `font-display: swap` y el titular tiene `min-height` de 2 líneas en el hero para evitar saltos.

Escala fluida (rem = 16 px; valores en px a 320 / 390 / 768 / 1440):

| Token | clamp() | 320 / 390 / 768 / 1440 | Uso |
|---|---|---|---|
| `--fs-hero` | `clamp(2.5rem, 1.6rem + 4.6vw, 4.75rem)` | 40 / 43 / 61 / 76 | h1, Josefin 700, lh 1.0, ls -0.01em |
| `--fs-h2` | `clamp(1.625rem, 1.3rem + 1.6vw, 2.5rem)` | 26 / 28 / 36 / 40 | "Récords · Piscina…", Josefin 700, lh 1.1 |
| `--fs-h3` | `clamp(1.375rem, 1.2rem + .9vw, 1.875rem)` | 22 / 23 / 28 / 30 | grupos (Libre, Mariposa…), Josefin 700 |
| `--fs-ev` | `clamp(1.0625rem, 1rem + .3vw, 1.25rem)` | 17 / 18 / 19 / 20 | nombre de prueba, Open Sans 700 |
| `--fs-time` | `clamp(1.375rem, 1.1rem + 1.2vw, 1.875rem)` | 22 / 24 / 28 / 30 | tiempos, Open Sans 800 |
| `--fs-body` | `1rem` | 16 | nombre del nadador, bajadas |
| `--fs-meta` | `.875rem` | 14 | fecha · lugar · torneo, etiquetas (mínimo absoluto) |
| `--fs-ctl` | `1rem` | 16 | botones/controles (evita zoom de iOS) |

Medida: texto corrido ≤ 62ch (`max-width: 62ch`); `text-wrap: balance` en h1–h3 y `pretty` en párrafos; `overflow-wrap: anywhere` en torneo y lugar (nombres largos en 320 px). Etiquetas (tags) en sentence case 14 px / 700, sin mayúsculas ni tracking.

### 2.3 Espaciado, radios, sombras, capas, puntos de corte
- Espaciado: 4 · 8 · 12 · 16 · 24 · 32 · 48 · 72. Entre grupos 48 px (72 en ≥1024); dentro de la fila 14 px vertical (12 en tablero).
- Radios: `--r-sm 4px` (botones, tags, controles), `--r-md 6px` (listas desde 768 px), `999px` solo flotadores. En celular las listas van de borde a borde del área de contenido (radio 0).
- Sombras: ninguna en reposo. Solo flota la barra de contexto móvil: `0 4px 12px rgb(15 21 36 / .18)`.
- z-index: 0 contenido · 1 arte del hero · 20 controles sticky · 30 barra de contexto · 40 carril. Sin otros.
- Puntos de corte (mínimos, mobile-first): base (320–479) · `480` · `768` (tablet, controles sticky) · `1024` (escritorio, tabla de 5 columnas) · `1280` (grupo en columna lateral). Más `@media (orientation: landscape) and (max-height: 500px)` (celular horizontal) y `(hover: hover)` solo para realces.
- Contenedor: `.wrap { width: 100%; max-width: 1120px; margin-inline: auto; padding-inline: max(16px, env(safe-area-inset-left)) 16px }`.

## 3. Estructura global y carril

`<html>` lleva `background: var(--agua)`; `<body>` tiene `background: var(--bg)` y `margin-inline-end: calc(var(--lane-w) + env(safe-area-inset-right, 0px))`. La tira derecha queda como agua: el carril ocupa su ancho exacto, como una barra de scroll clásica (así el contenido nunca queda tapado y los márgenes del contenido siguen iguales a izquierda y derecha). `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">`.

Orden del DOM: `header.top` → `#ctx` (barra de contexto, solo móvil) → `.controls` → `#status` → `main#main` → `footer` → `.lane` (al final; decorativo).

## 4. Composición por vista

### 4.1 Hero (`header.top`)
Fondo `--hero` sólido, sin gradiente. Arte SVG inline (`aria-hidden`, `preserveAspectRatio` fijo, `overflow:hidden` en el header para no provocar scroll horizontal):
1. **Banderines de espalda**: cuerda a 10 px del borde superior con triángulos 14×18 px alternando blanco y `--claro`, patrón `repeat-x` de 56 px; cuelga con una caída de 420 ms al cargar (opacity/translateY).
2. **Corcheras** al pie: dos hileras horizontales de flotadores (círculos 8 px, paso 16 px, azul claro/blanco al 55–85 % de opacidad) separadas por la línea T; la última banda de 10 px actúa de borde de piscina hacia el contenido.
3. Solo ≥1024: columna derecha de 5 carriles dibujados (líneas horizontales con flotadores, números de carril 1–5 en Josefin 20 px al 70 % de blanco, un rastro de estela) ocupando 40 % del ancho del hero; en celular se omite.

Contenido (z-index sobre el arte):
- Marca: "Club Náutico" Josefin 700 22 px, blanco, con 3 flotadores (círculos 8 px) a la izquierda. Sin logos de terceros ni escudo.
- `h1` "Récords del club": `--fs-hero`, blanco.
- Bajada (texto actual): 16 px, `--hero-sub`, `max-width: 34ch`.
- Alturas: celular vertical 250–280 px (padding 40 px arriba por los banderines + 28 abajo); 768: 320 px; ≥1024: 380 px; celular horizontal bajo 500 px de alto: padding 16 px, se oculta la bajada y h1 baja a 2rem. Safe-area: `padding-top: max(40px, calc(env(safe-area-inset-top) + 28px))`.

### 4.2 Selectores (`.controls`) — "Tablero de salida"
Dos `.seg` (mismo DOM). Cada `.seg`: fondo `--surface`, radio 4, padding 4, `position: relative`; un **indicador** (`::before`, `transform: translateX(calc(var(--i) * 100%))`, ancho `calc((100% - 8px) / var(--n))`, fondo `--sel`, radio 3) se desliza 220 ms entre opciones; JS escribe `--i` y `--n` en cada `.seg` dentro de `draw()`. Los botones (`transparent`, z-index sobre el indicador) llevan 16 px / 700, `min-height: 56px` en celular (dos líneas permitidas: "Piscina / 50 m", "Aguas / abiertas"; `text-wrap: balance; line-height: 1.15`) y 48 px desde 768. Seleccionado = `--on-brand` sobre `--sel`; no seleccionado = `--ink`. El estado se comunica por `aria-pressed` y además por fondo + peso (no solo color).
- Celular: dos filas apiladas (piscina 3 columnas, rama 2 columnas), gap 8 px, padding de la franja 12 px 0; **no sticky** (ocupan 140 px).
- ≥768 y alto ≥600: la franja es `position: sticky; top: 0; z-index: 20`, una sola fila (flex, piscina `flex: 3`, rama `flex: 2`, gap 12 px), fondo `--bg`, separador inferior 1 px `--line` solo cuando está pegada.

### 4.3 Barra de contexto móvil (`#ctx`, solo < 768 px)
Resuelve "no puedo cambiar de piscina sin volver arriba". Fija arriba (z 30, alto 48 px + `env(safe-area-inset-top)`), fondo `--pizarra` (#313E4F, también en oscuro), texto blanco 14 px/600: izquierda "Piscina 50 m · Varones" (texto del estado, actualizado en `draw()`), derecha botón "Cambiar" (≥44×44, texto 16 px, subrayado de 2 px ámbar). Aparece (translateY -100% → 0, 200 ms) cuando `.controls` sale de la vista (IntersectionObserver, `rootMargin: "-48px 0px 0px 0px"`) y se oculta al volver; mientras está oculta lleva `inert` y `aria-hidden="true"`. "Cambiar" hace `controls.scrollIntoView({block:"start", behavior: reducido ? "auto" : "smooth"})` y mueve el foco al primer botón `.seg`. No duplica controles ni usa `.seg` (el DOM de pruebas no cambia). Sombra flotante permitida (es lo único que flota).

### 4.4 Título de vista
`h2` (`--fs-h2`, `--ink`) + párrafo `.sub` (texto actual, 15 px, `--muted` → 6,82). Margen superior 32 px (el hero ya cerró con la corchera).

### 4.5 Grupos de pruebas
Cada grupo = `<section class="grp">` con `h3.group` + `.card` (los hijos de `#main` siguen siendo bloques; el contrato solo exige la `.card`). `h3` en Josefin `--fs-h3`, sentence case, `--ink`; debajo, una **corchera divisoria** de 8 px de alto (SVG `background-image` de flotadores azul/pervinca, `repeat-x`, ancho 96 px) como firma, no como línea.
- < 1280: título arriba, lista debajo, 12 px de separación.
- ≥1280: `grid-template-columns: 220px 1fr; column-gap: 40px`; el `h3` es `position: sticky; top: calc(var(--controls-h) + 16px)` (altura de franja sticky medida con `ResizeObserver`), la lista a la derecha. Efecto "horario de campeonato".
- Lista (`.card`): `--surface`, sin borde ni sombra en celular (borde a borde, separador 1 px `--line` entre filas); desde 768 radio 6 y borde 1 px `--line`.

### 4.6 Fila de récord individual (`a.item.rowlink`)
Celular (grid 2 columnas `1fr auto`, padding 14 px 16 px, `min-height: 72 px`, todo el bloque es el objetivo táctil):
1. Línea 1: `.ev` ("50 m Libre", `--fs-ev`) + etiqueta Exhibición si aplica | `.time` a la derecha (`--fs-time`, 800, `--brand`, tabular). El tiempo es lo más grande de la fila.
2. Línea 2: `.who` nombre (16 px, `--ink`).
3. Línea 3: `.meta` fecha · lugar · torneo (14 px, `--muted`, máx. 2 líneas visibles por `overflow-wrap`), y `.go`: texto "Ver Top 10" / "Ocultar Top 10" 14 px/700 `--brand` más chevron (pseudo-elemento SVG 14 px que rota 180° con `aria-expanded`, `transform` 200 ms). Se retiran los glifos ▾▴ del texto.
- Escritorio ≥1024: una sola línea, columnas `minmax(180px,1.1fr) 120px minmax(170px,1.5fr) minmax(240px,2.2fr)` (prueba | tiempo alineado a la derecha | nadador | meta con `.go` al final); altura 60 px.
- Abierta: fondo `--surface-2`, `.ev` en `--brand`, chevron girado; SIN borde lateral de color (prohibido); la relación fila→tablero la da el tono y que el tablero se pega debajo.
- Hover (solo `@media (hover: hover)`): fondo `--surface-2`. Pulsado: `:active` fondo `--surface-2` + `transform: scale(.995)` 90 ms.
- Foco: `outline: 3px solid var(--focus); outline-offset: -3px`.

### 4.7 Top 10 desplegado (`div.top10`, hermano siguiente de la fila, dentro de la misma `.card`)
Tablero de resultados: fondo `--board`, texto `--board-ink`, sin sombra ni borde. Cabecera: título Josefin 700 22 px "Top 10 · 50 m Libre" (blanco) y a su derecha/abajo "mejor marca de cada nadador" (14 px, `--board-muted`).
- Nota de exhibición (cuando aplica): fondo `--warn-bg`, texto `--warn-fg`, 14 px, radio 4, margen 8 px 16 px.
- Filas `.item.top` (separadas por 1 px `rgb(255 255 255 / .14)`; padding 12 px 16 px; mínimo 64 px): línea 1 = `.ev` con `.pos` ("1.", 800, ancho 2ch, `--board-muted`; el 1 en ámbar) + `.time` (800, `--fs-time` reducido a 22 px en tablero, blanco; el puesto 1 en ámbar); línea 2 = `.who` nombre (16 px, blanco) + tag Exhibición (en tablero: fondo ámbar, texto `--ink`, 9,25); línea 3 = `.meta` (14 px, `--board-muted`) y, para exhibición con oficial, "Mejor marca oficial: <strong>…</strong>" en blanco.
- Escritorio: columnas `120px minmax(200px,1.4fr) minmax(260px,2fr)` (puesto+tiempo | nombre | meta).
- Pie del tablero: botón "Cerrar Top 10" (ancho completo en celular, 48 px, texto 16 px/700 blanco, borde 2 px `--board-muted`, radio 4; foco ámbar 3 px). Evita tener que volver a la fila tras leer 10 puestos. El botón hace lo mismo que tocar la fila y devuelve el foco a la fila.
- Entrada: ver 7.2.

### 4.8 Relevos (`div.item.relay`)
No son interactivos. Misma rejilla de la fila de récord sin chevron: `.ev` + tag "Mixto" (fondo `--tag-bg`, texto `--tag-fg`, 14 px/700) | `.time`; integrantes `ol.team` (sin viñetas del navegador; cada `li` 16 px con marcador de estilo (E)(P)(M)(L) en `--muted` 14 px, con un espacio previo; no usar números ordinales); celular una columna, ≥768 dos columnas (`columns: 2`); nota "Integrantes no publicados en los resultados oficiales" en 14 px `--muted`. Meta igual que en récords. Los relevos reciben un fondo `--surface` sin tono especial (distintos a los individuales por el h3 "Relevos…").

### 4.9 Aguas abiertas
Mismo h2/sub. Por distancia: `h3.group` + `.card.board` (el tablero oscuro completo, siempre abierto; mismas filas `.item.top`). El puesto 1 lleva tag "Récord" (en tablero: fondo `--claro`, texto #16215A, 9,66) y tiempo en ámbar. El `.sub` explica que el número es la posición dentro del club (texto actual). Sin filas clicables.

### 4.10 Pie
`--muted` 14 px, `padding: 32px 0 72px` (el 72 deja respirar al carril y a la barra de gestos), dos párrafos actuales ("Fuente: … Actualizado al 18/10/2026." y "Página del Club Náutico. No es una página oficial de la FENA."). Sobre el pie, una corchera divisoria de 8 px a todo el ancho. Sin nombre repetido en grande ni sitemap. `padding-bottom: calc(32px + env(safe-area-inset-bottom))`.

## 5. Estados
| Estado | Diseño |
|---|---|
| Cargando | `main[aria-busy=true]`; 6 filas esqueleto `div.sk` (NO usar la clase `.item`: la prueba espera el primer `.item` como señal de carga) de 72 px, fondo `--surface-2`, pulso de opacidad .55↔1 en 1,2 s; texto `sr-only` "Cargando…" (se conserva `.sub` "Cargando…" visible bajo el h2 si no hay datos aún). El Top 10 pendiente muestra "Cargando Top 10…" 14 px sobre el tablero. |
| Error | `.err`: fondo `--err-bg`, texto `--err-fg` (10,11), padding 16, radio 4, texto actual + botón "Reintentar" (`location.reload()`, 48 px, fondo `--brand`/`--sel`, texto `--on-brand`). `role="alert"`. |
| Vacío | "Sin marcas." / "Sin marcas registradas." centrados, `--muted`, 16 px, padding 32 px. |
| Sin JavaScript | `<noscript>` actual dentro de `.err`; el hero y el pie siguen visibles. |
| Abierto/cerrado | Ver 4.6/4.7. Solo una prueba abierta a la vez (comportamiento actual); al cambiar piscina/rama se cierra. |
| Foco | Anillo único 3 px `--focus`, offset 2 px (botones, `.go`, "Cambiar", "Cerrar"); en filas offset -3 px. En el tablero oscuro el anillo es ámbar. Siempre visible con teclado (`:focus-visible`). |
| Pulsado | Botones `scale(.98)` 90 ms; filas fondo `--surface-2`. |
| Deshabilitado | No existen controles deshabilitados. |
| Selección de texto | `::selection { background: var(--brand); color: var(--on-brand) }`. |

## 6. Copy
Se mantiene el copy actual de datos y notas. Solo cambia: "Ver Top 10"/"Ocultar Top 10" sin glifos, "Cambiar" (barra de contexto), "Cerrar Top 10", "Reintentar", "Cargando…". Prohibida la palabra "años" en cualquier texto visible (la prueba la busca en todo `body`). Sin edades. Tono: directo, en segunda persona de ser necesario ("Toca una prueba…" se mantiene).

## 7. Movimiento
Principio: transform y opacity únicamente; un protagonista (el carril); lo demás es respuesta a la mano. Curvas: `--out: cubic-bezier(.22, 1, .36, 1)` (entradas y cambios), `--io: cubic-bezier(.4, 0, .2, 1)` (bucles). Sin rebote ni elástico.

### 7.1 Tabla
| Elemento | Propiedad | Duración | Curva |
|---|---|---|---|
| Banderines al cargar | translateY(-100%→0) + opacity | 420 ms (una vez) | out |
| Título hero (por línea/palabra, 2 niveles) | translateY(16px→0) + opacity | 360 ms, retardo 60 ms | out |
| Indicador de selector | translateX | 220 ms | out |
| Filas al cambiar de vista | opacity + translateY(8px→0) | 200 ms, retardo `min(i,10)*18ms` | out |
| Chevron | rotate(180°) | 200 ms | out |
| Tablero Top 10 (contenedor) | opacity + translateY(-6px→0) | 220 ms | out |
| Filas del tablero | opacity + translateY(6px→0) | 180 ms, retardo `i*25ms` (máx. 250 ms) | out |
| Barra de contexto | translateY | 200 ms | out |
| Pulsado de botones | scale(.98) | 90 ms | io |
| Esqueleto | opacity | 1200 ms bucle | io |

### 7.2 Reglas
- **El DOM cambia instantáneamente** (clic → `.top10` ya existe a los 40 ms, el cierre lo quita de inmediato): la animación es solo cosmética sobre contenido ya presente. No se anima `height`. Se conserva la compensación `scrollBy` para que la fila tocada no se mueva.
- El contenido es visible por defecto; las animaciones de entrada usan `@keyframes ... both` (si el CSS de animación no corre, queda visible).
- `prefers-reduced-motion: reduce`: se eliminan todas las animaciones y transiciones (`animation: none !important; transition: none !important`), el indicador del selector salta, las filas aparecen de golpe, `scrollIntoView` usa `auto`. Solo se conserva la posición del carril.
- Pausa automática: las animaciones del carril no corren cuando la pestaña está oculta (comportamiento del navegador).

## 8. Indicador de desplazamiento "carril" (elemento firma)

### 8.1 Concepto
Un carril de piscina visto desde arriba, fijo al borde derecho, de pared a pared. La corchera (línea de flotadores) corre por su lado izquierdo; el nadador avanza por el agua según el progreso de scroll y, al detenerse el scroll, se agarra de la corchera y flota. Es el único "indicador de progreso" de la página; **los datos no cambian**.

### 8.2 Geometría
- `--lane-w: clamp(28px, 7.5vw, 48px)` → 320: 28 · 360: 28 · 390: 29 · 414: 31 · 768: 48 · escritorio: 48. Altura `100vh` con respaldo `100dvh` (la barra del navegador móvil se expande y encoge); ancho extra por `env(safe-area-inset-right)` ya reservado en el margen del `body`.
- Capas internas (de atrás a delante): fondo agua (`--agua`); pared superior y pared inferior (rectángulos de 6 px, `--brand`, en oscuro `--claro`); línea T del fondo (2 px, `--pervinca`, 45 % opacidad, en x = 62 % del ancho, de pared a pared); marcas de 5 m (segmentos horizontales de 1 px a 7 % y 93 % de la altura); corchera (cuerda de 1 px `--pervinca` en x = 4 px + flotadores círculo r = 3,2 px, paso 12 px, alternando `--float-a`/`--float-b`; el primer y último 7 % en `--end-float` ámbar con contorno 1 px `--brand`); nadador.
- Ancho de corchera fijo 8 px. Nadador: ancho `calc(var(--lane-w) * .9)` (25 px a 320, 43 px a 768), alto automático por `aspect-ratio: 52 / 64`.
- Recorrido: `pad = 10 px` (pared 6 + 4). `y = pad + progreso × (altoCarril − altoNadador − 2·pad)`, con `progreso = clamp(scrollY / (scrollHeight − innerHeight), 0, 1)` (se ignora el rebote elástico de iOS por el clamp). Si el documento no desplaza (`scrollHeight ≤ innerHeight + 1`), `progreso = 0`.

### 8.3 Marcado
```html
<div class="lane" aria-hidden="true" data-state="rest" data-dir="down" data-edge="start">
  <svg class="lane-bg" width="100%" height="100%" focusable="false">
    <defs>
      <pattern id="fl" width="8" height="24" patternUnits="userSpaceOnUse">
        <circle cx="4" cy="6"  r="3.2" class="f-a"/><circle cx="4" cy="18" r="3.2" class="f-b"/></pattern>
      <pattern id="fe" width="8" height="24" patternUnits="userSpaceOnUse">
        <circle cx="4" cy="6"  r="3.2" class="f-e"/><circle cx="4" cy="18" r="3.2" class="f-e"/></pattern>
    </defs>
    <line x1="4" x2="4" y1="0" y2="100%" class="rope"/>
    <line x1="62%" x2="62%" y1="8" y2="calc(100% - 8px)" class="tline"/>
    <rect x="0" y="0"   width="8" height="100%" fill="url(#fl)"/>
    <rect x="0" y="6"   width="8" height="7%"   fill="url(#fe)"/>
    <rect x="0" y="93%" width="8" height="calc(7% - 6px)" fill="url(#fe)"/>
  </svg>
  <div class="sw-y"><div class="sw-x">
    <svg class="sw" viewBox="0 0 52 64" focusable="false">
      <g class="sw-flip"><g class="sw-float">
        <g class="wake"><path d="M20 3c3-2 9-2 12 0M17 0c5-3 13-3 18 0"/></g>
        <g class="legs"><path class="leg-l" d="M23 44 22 60"/><path class="leg-r" d="M29 44 30 60"/></g>
        <path class="torso" d="M26 14c7 0 8 10 7 20-1 10-3 14-7 14s-6-4-7-14c-1-10 0-20 7-20z"/>
        <g class="arm arm-l"><path d="M19 24 17 6"/><circle cx="17" cy="5" r="2.2"/></g>
        <g class="arm arm-r"><path d="M33 24 35 6"/><circle cx="35" cy="5" r="2.2"/></g>
        <circle class="cap" cx="26" cy="10" r="6.5"/>
      </g></g>
    </svg>
  </div></div>
</div>
```
(Los `<line>`/`<rect>` con `calc()` en atributos no son válidos en SVG 1.1: usar porcentajes y `transform`, o fijar estos tramos con CSS en `.tline`/`.wall` o con 3 `div` posicionados. La implementación decide; el resultado visual es el descrito.)
Trazos del nadador: `stroke: var(--sw-body); stroke-width: 4; stroke-linecap: round; fill: none` (brazos y piernas); `torso`/manos `fill: var(--sw-body)`; `cap` `fill: var(--sw-cap); stroke: var(--sw-body); stroke-width: 1.6`; `wake` `stroke: var(--float-b); stroke-width: 1.6; fill: none`.

### 8.4 Poses y estados
- Orientación (`data-dir`): la cabeza apunta hacia donde se avanza. Al bajar la página `data-dir="down"` → `.sw-flip { transform: scaleY(-1) }` (reflejo vertical que, a diferencia de un giro de 180°, mantiene el brazo del gancho del lado de la corchera); al subir `up` → `scaleY(1)`. Transición 240 ms `--out` (se lee como un viraje). `transform-origin: 26px 32px`.
- **Nadando** (`data-state="swim"`): `.sw-x` en el centro del agua (`translateX(calc(var(--lane-w) * .05))`); brazos alternados: `.arm-l { transform-origin: 19px 24px; animation: braza-l .8s var(--io) infinite alternate }` con `braza-l` de `rotate(-8deg)` a `rotate(-165deg)`; `.arm-r { transform-origin: 33px 24px; ... }` de `rotate(165deg)` a `rotate(8deg)` (en contrafase); patada: `.leg-l/.leg-r { transform-origin: 26px 44px; animation: patada .22s linear infinite alternate }` ±10° opuestos; `.wake` visible (opacity .85, parpadeo 400 ms).
- **Descansando** (`data-state="rest"`, tras 380 ms sin eventos de scroll): `.sw-x` se desplaza (260 ms `--out`) a `translateX(3px)` para que la mano del brazo izquierdo quede sobre el centro de la corchera (x = 4 px); `.arm-l { animation: none; transform: rotate(-90deg) }` (brazo extendido hacia la cuerda); `.arm-r { animation: none; transform: rotate(172deg) }` (brazo a lo largo del cuerpo); piernas colgando `rotate(±6deg)` fijas; `.wake` oculta; `.sw-float { animation: flota 2.6s var(--io) infinite }` con `translateY(0) rotate(-2deg)` ↔ `translateY(1.6px) rotate(2deg)` (leve flotación). El cambio de brazos es un salto, disimulado por el desplazamiento horizontal.
- **Bordes** (`data-edge`, JS lo calcula a partir del progreso: `start` ≤ .005, `end` ≥ .995, si no `mid`): en `start` el nadador queda en reposo con la cabeza hacia abajo, junto a la pared de salida; en `end` y mientras se mueve, la cabeza toca la pared inferior (el recorrido llega a `y_max`) y se dispara UNA ondulación (anillo `<ellipse>` en la pared, `transform: scale(.4→1.6)` + `opacity .6→0`, 600 ms) al entrar en `end`. Al volver a subir desde `end` hace el viraje de dirección.
- Movimiento: más rápido el scroll no cambia la cadencia (se evita parecer un efecto de velocidad); extra opcional P2: si |velocidad| > 2000 px/s, `animation-duration` de brazos a .55 s.

### 8.5 Comportamiento no intrusivo
`.lane, .lane * { pointer-events: none; user-select: none; -webkit-user-select: none; -webkit-tap-highlight-color: transparent }`. Los eventos táctiles atraviesan el carril. Ningún `overflow:hidden` ni `overscroll-behavior` en `html`/`body`; el scroll nativo, la inercia, la barra de dirección y "tocar la barra de estado para subir" no se alteran. Los listeners son `{ passive: true }`. Sin `scroll-snap`, sin `scroll-behavior: smooth` global.

### 8.6 Rendimiento (rAF + transform)
```js
const lane = document.querySelector('.lane'), sy = lane.querySelector('.sw-y');
let docH = 0, laneH = 0, swH = 0, tick = false, rest = 0, lastY = scrollY;
const measure = () => { docH = document.documentElement.scrollHeight - innerHeight;
                        laneH = lane.clientHeight; swH = sy.offsetHeight; frame(); };
new ResizeObserver(measure).observe(document.body);   // contenido cambia al abrir Top 10
addEventListener('resize', measure); addEventListener('orientationchange', measure);
function frame() {
  tick = false;
  const p = docH > 1 ? Math.min(1, Math.max(0, scrollY / docH)) : 0;
  sy.style.transform = `translate3d(0,${(10 + p * (laneH - swH - 20)).toFixed(1)}px,0)`;
  const edge = p <= .005 ? 'start' : p >= .995 ? 'end' : 'mid';
  if (lane.dataset.edge !== edge) lane.dataset.edge = edge;
}
addEventListener('scroll', () => {
  if (!tick) { tick = true; requestAnimationFrame(frame); }
  const dir = scrollY >= lastY ? 'down' : 'up'; lastY = scrollY;
  if (lane.dataset.dir !== dir) lane.dataset.dir = dir;      // sólo escribe si cambia
  if (lane.dataset.state !== 'swim') lane.dataset.state = 'swim';
  clearTimeout(rest); rest = setTimeout(() => lane.dataset.state = 'rest', 380);
}, { passive: true });
measure();
```
Reglas: una sola lectura de layout por cambio de tamaño (nunca en el scroll); `will-change: transform` solo en `.sw-y`; `contain: layout paint` y `isolation: isolate` en `.lane`; ≤ 14 nodos SVG animados; sin `getBoundingClientRect` en el handler; sin imágenes. Costo esperado < 0,3 ms por frame.

### 8.7 Accesibilidad
`aria-hidden="true"` en `.lane` y sin elementos enfocables dentro; el progreso real lo siguen dando la barra nativa y la estructura (h2/h3). `prefers-reduced-motion: reduce`: el JS sigue actualizando solo `y`; el CSS fija `animation: none; transition: none` y una pose estática única (brazo izquierdo `rotate(-30deg)`, derecho `rotate(150deg)`, centro del agua, sin estela ni flotación, sin viraje). `forced-colors: active` y `@media print`: `.lane { display: none }` y `body { margin-inline-end: 0 }`.

### 8.8 Barra de desplazamiento nativa: decisión
- **Táctil (`pointer: coarse`)**: se oculta (`html { scrollbar-width: none } html::-webkit-scrollbar { display: none }`). Las barras móviles son superpuestas y desaparecen solas; el carril ocupa su lugar sin duplicar.
- **Ratón/trackpad (`pointer: fine`)**: se **conserva**, estilizada y delgada (`scrollbar-width: thin; scrollbar-color: var(--pervinca) transparent`), junto al carril. Razón: quien usa ratón arrastra la barra, y quien tiene movilidad reducida o tecnología asistiva depende de ella; teclado (Espacio, Re Pág, Fin) y lector de pantalla no se ven afectados en ningún caso porque el scroll nativo nunca se intercepta. El carril es complemento visual, no sustituto.

## 9. Responsive: matriz de comprobación
| Ancho | Qué cambia |
|---|---|
| 320 | Contenido 260 px (carril 28 + márgenes 16); selectores con botones de 2 líneas; título hero en 2 líneas; tiempos 22 px; `ol.team` 1 columna |
| 360 / 390 / 414 | Igual con más aire; carril 28–31 px |
| 480 | `.sub` y bajada hasta 62ch; separadores entre grupos 56 px |
| 768 vertical | Controles sticky de una fila; listas con radio 6 y borde; carril 48 px; `ol.team` 2 columnas; hero 320 px |
| Celular horizontal (< 500 alto) | Hero compacto sin bajada; sin controles sticky (la barra de contexto toma el papel si el ancho < 768; si ≥ 768 pero alto < 600 tampoco es sticky); safe-area izquierda/derecha respetadas |
| 1024 | Fila en tabla de 4 columnas; tablero en 3 columnas; arte de 5 carriles en el hero |
| 1280+ | Títulos de grupo en columna lateral sticky; contenedor 1120 px centrado |
Siempre: `scrollWidth ≤ clientWidth` (sin scroll horizontal), objetivos táctiles ≥ 44 px (botones 48–56, filas ≥ 64), datos secundarios ≥ 14 px, controles 16 px, `100dvh` con respaldo `100vh`, `env(safe-area-inset-*)` en hero, barra de contexto, pie y carril.

## 10. Impresión
`@media print`: oculta hero-arte, controles, `#ctx`, carril, `.go`, botón "Cerrar"; fondo blanco, texto negro 11 pt, `--board` pasa a blanco con texto negro y borde 1 px #999 (los Top 10 abiertos se imprimen legibles); `.item { break-inside: avoid }`; h1 en 24 pt negro; `a[href]::after` desactivado; `@page { margin: 12mm }`.

## 11. Contrato del DOM y "Cambios al contrato"
**Se mantiene sin cambios** (comprobado contra `herramientas/verificar.html`): `.seg[data-key=curso|genero]` con `button[data-v]` y `aria-pressed`; un solo `.seg` por clave (no duplicar en la barra de contexto); `#main`; `a.item.rowlink[data-prueba][aria-expanded]`; `div.top10[data-prueba]` como hermano siguiente de la fila, dentro de la misma `.card`; `.item.top` con texto que empieza por "N." y contiene tiempo y nombre; texto "Exhibición" solo en marcas `x`; "Récord" solo en el puesto 1 de aguas abiertas; `.item.relay` con "Mixto" y (E)(P)(M)(L); `.ev` dentro de `.item.relay` (la prueba lee su texto para ordenar); pie con "Actualizado al dd/mm/aaaa". No existen `#q`, `#sel-prueba`, `.seg[data-key=vista]`. La primera `.item` es la señal de carga: el esqueleto usa `.sk`. Sin "años" ni "undefined/null/NaN" en texto visible. Sin errores de JS.

**Cambios al contrato (solo adiciones, ninguna clase renombrada):**
1. `section.grp` envuelve `h3.group` + `.card` (necesario para la columna lateral ≥1280; `.card` conserva a sus hijos).
2. `.card.board` en aguas abiertas (variante visual).
3. `button.t10close` dentro de `div.top10` (después de las filas; no tiene clase `.item`).
4. `#ctx` fuera de `#main` y fuera de `.controls`.
5. `.go` deja de incluir ▾/▴ en el texto (queda "Ver Top 10"/"Ocultar Top 10"); el chevron es CSS.
6. `<link>` a Google Fonts, `viewport-fit=cover`, `theme-color` doble, favicon actualizado (cuadrado #22409A con tres flotadores blancos). `og:*`, `robots`, `<title>`, `lang`, rutas `data/*.json` y `assets/` sin cambios.

## 12. Checklist de aceptación (verificable)
**Contrato y datos**
- [ ] `herramientas/verificar.html` (marco 360 px) = 0 fallos.
- [ ] `<title>Récords Club Náutico</title>`, `lang="es"`, `robots noindex, nofollow`, `og:url` y `og:image` idénticos a los actuales; hash `#c=LC|SC|OW&g=M|F&p=<prueba>` abre y marca selectores y Top 10 (incluyendo hash inválido).
- [ ] Mismo conteo de filas/relevos/Top 10 que los JSON; Exhibición como hoy; sin edades; pie con "Actualizado al" y línea de fuente.
**Responsive**
- [ ] 320, 360, 390, 414, 768 (vertical y horizontal) y 1280+: `document.documentElement.scrollWidth <= clientWidth` en todas las vistas (LC/SC/OW × M/F, y con un Top 10 abierto).
- [ ] Todo objetivo táctil ≥ 44×44 px (medido); texto de datos ≥ 14 px; controles 16 px.
- [ ] Safe-area: con `viewport-fit=cover` simulado (inset 44/34 px), nada queda bajo el notch ni tras la barra de gestos; el carril no queda tapado.
- [ ] Ninguna interacción depende de hover (todo funciona con toque y teclado).
**Accesibilidad**
- [ ] Contrastes de la tabla 2.1 reproducidos (herramienta o cálculo); ningún texto bajo 4,5:1 (3:1 si ≥ 24 px o 19 px negrita).
- [ ] Foco visible en todos los controles, orden lógico; `Tab` no entra al carril ni a `#ctx` oculta (`inert`).
- [ ] `prefers-reduced-motion: reduce`: ninguna animación/transición activa (inspección de `getAnimations()` = 0 salvo el cambio de `transform` de posición del carril).
- [ ] `prefers-color-scheme: dark`: todo legible; hero conserva el azul.
- [ ] Lector de pantalla: `h1 > h2 > h3` correctos, `role=status` anuncia vista y apertura/cierre del Top 10; el carril no se anuncia.
**Carril**
- [ ] Posición proporcional: en `scrollY = 0` el nadador está en el extremo superior (edge `start`); en el final de la página, en el extremo inferior (`end`); a mitad, a mitad (±3 %).
- [ ] Mientras hay scroll: `data-state="swim"`, brazos y piernas animan; 380 ± 80 ms después de detenerse: `rest` con la mano sobre la corchera y leve flotación.
- [ ] Al invertir la dirección el nadador se voltea (viraje) sin saltar de posición.
- [ ] `pointer-events: none` verificado con `elementFromPoint` en el área del carril (devuelve el contenido o `html`, nunca `.lane`); el scroll táctil y por inercia empiezan sobre el carril sin interrupciones; el scroll por teclado y el clic de la rueda siguen funcionando.
- [ ] Rendimiento: perfil de 5 s de scroll en un móvil de gama media sin tareas > 8 ms atribuibles al handler; solo `transform`/`opacity` animados; sin layout forzado en `scroll`.
- [ ] Se oculta en impresión y en `forced-colors`; no hay scroll horizontal por su causa.
**Interacción y estados**
- [ ] El Top 10 aparece en el mismo frame que el clic (DOM) y se anima solo opacidad/transform; la fila tocada no se mueve de la pantalla.
- [ ] "Cerrar Top 10" cierra y devuelve el foco a la fila.
- [ ] La barra de contexto aparece solo en < 768 al salir de los selectores; "Cambiar" devuelve a los selectores y enfoca el primer botón.
- [ ] Estados: cargando (esqueleto), error con "Reintentar", vacío, sin JS.
**Rendimiento**
- [ ] Peso total HTML inicial < 45 KB sin gzip (sin contar fuentes y JSON); solo 2 familias de Google Fonts en una petición; sin imágenes de trama en la página (el `og.png` solo lo usan los previsualizadores); la página funciona si las fuentes no cargan.
**Visual (revisión de capturas a 390 y 1440, claro y oscuro)**
- [ ] Sin gradientes, sin sombras en reposo, sin emojis, sin etiquetas en mayúsculas espaciadas, sin bordes laterales de color, sin tarjetas anidadas.
- [ ] El tiempo es el elemento más prominente de cada fila; el nombre del nadador se lee en 1 línea o 2 máx.
- [ ] Impresión: vista previa legible en A4 sin controles ni carril.

## 13. Riesgos y decisiones abiertas
1. **Ancho del carril** (28–48 px) cuesta ~9 % del ancho en 320 px. Mitigación: contenido a 260 px sigue funcional. Decisión: ¿aceptar o reducir a 20 px (nadador más chico)?
2. **Barra nativa en escritorio**: se conserva (8.8). Si el usuario prefiere solo el carril, se puede ocultar también, pero perjudica a quien arrastra la barra. Se recomienda mantenerla.
3. **Ámbar #FFC93C** es el único color fuera de la paleta del escuela/club (justificado como "marcador"). Confirmar con el club; alternativa: usar `--claro` y perder legibilidad del puesto 1 en el tablero.
4. **Fuentes**: Josefin Slab 700 es fina a 22–26 px; se mitiga con peso 700 y tamaños ≥ 22 px. No se usa para cifras. Comprobar visualmente en Android de gama baja.
5. **Barra de contexto móvil** (4.3) y **botón "Cerrar Top 10"** son adiciones de UX no pedidas; son baratas y reversibles. Confirmar.
6. **Chips de salto por estilo** (Libre / Mariposa / Espalda / Pecho / Combinado / Relevos): beneficio alto en listas largas, pero añade una fila de 2×3 botones (96 px) bajo el h2. Quedan como mejora P2, no incluidas por defecto.
7. **Safari iOS**: `dvh` y `viewport-fit=cover` desde iOS 15.4/11; con versiones anteriores el carril usa `100vh` (puede quedar 50 px alto bajo la barra); degrada sin romper.
8. **`assets/og.png`** conserva URL y dimensiones, pero su imagen actual usa el azul antiguo (#0b3a5b): regenerarla con la marca nueva es tarea aparte (no se toca en este ciclo). Decisión: ¿regenerar?
9. **Carga de fuentes y CLS**: sin `size-adjust`, el cambio de fallback a Josefin Slab puede mover el hero unos píxeles; se acota con `min-height` en el titular. Verificar en el ciclo de revisión.
10. **Hero de 5 carriles ≥1024** es arte exclusivo de escritorio: si pesa en revisión, se elimina sin tocar el resto.
