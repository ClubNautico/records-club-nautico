# Cómo actualizar la página de récords

La página lee todo de la carpeta `data/`. Para actualizar **no hace falta tocar código**.

## Pasos

1. Pide a Claude (proyecto "Club - Reportes y tests") que regenere los JSON.
   Recuérdale que **las marcas de exhibición (x) cuentan para los récords** si son las más rápidas, y que
   los nuevos JSON deben conservar estas correcciones (18/10/2026):
   - Incluir las marcas del **Excel oficial de Cali 2023** (`Resultados XL Torneo Interclubes de Natación - Ciudad de Cali 2023 NAUE.xlsx`, piscina de 50 m).
   - Respetar la ortografía acordada de los nombres (la lista está en las notas internas de Claude, `CLAUDE.local.md`, que no se publica).
   - **Sin edades**: ningún archivo puede traer la clave `edad` (hay menores). El verificador lo marca como error.
2. Reemplaza los archivos de `data/` por los nuevos, con los mismos nombres:
   - `records_piscina.json`
   - `top10_piscina.json`
   - `relevos_records.json`
   - `records_aguas_abiertas.json`
   - `top_aguas_abiertas.json`
   - `historico_records.json` y `historico_top10.json` (página aparte `historico.html`, 2002–2009; cambian solo si aparecen resultados viejos)
   - `travesias_records.json` y `travesias_top.json` (travesías y otras competencias que no son de la FENA; ver abajo)
3. En `index.html`, cambia la fecha del pie: busca `Actualizado al` y escribe la fecha nueva.
4. Verifica los datos. Debe terminar con **"OK: datos verificados, sin errores."**
   Si sale **ERRORES**, no publiques: corrige o pide a Claude que lo revise.

   ```bash
   powershell -ExecutionPolicy Bypass -File herramientas\verificar_datos.ps1
   ```

5. Sube los cambios:

   ```bash
   git add -A
   git commit -m "Actualizar récords"
   git push
   ```

6. Espera 1–2 minutos y abre la verificación de la página publicada. Debe decir **"✓ Todo bien"**:
   `https://clubnautico.github.io/records-club-nautico/herramientas/verificar.html`

   Si cambiaste el diseño (`index.html`), abre también la prueba de celulares, que debe decir **"OK"**:
   `https://clubnautico.github.io/records-club-nautico/herramientas/dispositivos.html`
   (y `herramientas/vista.html?w=360,390` para mirar la página en tamaños de teléfono).

   Recarga en el celular. GitHub guarda la página en caché unos 10 minutos: si no ves el cambio, espera y recarga.

## Travesías y otras competencias (no FENA)

Van en **Aguas abiertas → Travesías**, aparte de las competencias FENA, con la aclaración de que no son récords oficiales FENA.
1. Claude corre `travesias.py` (proyecto "Club - Reportes y tests"), que escribe `tv_records.json` y `tv_top.json`.
2. Desde esta carpeta, se pasan a la página (valida y quita lo que no se publica: edad, categoría, IDs internos):

   ```bash
   python -I herramientas\traer_travesias.py "<carpeta de travesias.py>\tv_records.json" "<carpeta de travesias.py>\tv_top.json" data
   ```

   Debe terminar con "escrito data\travesias_records.json" y "escrito data\travesias_top.json". Si dice ERROR, no escribe nada.
3. Sigue con los pasos 3 a 6 de arriba.

## Qué hace la página con los datos

- No recalcula nada: muestra los JSON tal como vienen.
- Marcas con `marca = "x"` (exhibición): cuentan igual para el Top 10 y para los récords del club;
  se muestran con la etiqueta "Exhibición" solo como información.
- No se muestran edades (y los archivos no las traen).
- Si `lugar` viene vacío, se muestra "Ecuador" (como en la tabla impresa). En travesías se muestra la fecha y el evento.
- La página tiene `noindex`: no aparece en Google; se comparte por enlace.
- Se puede "Añadir a pantalla de inicio" en el celular (icono azul con la R); el enlace del QR es el mismo.
