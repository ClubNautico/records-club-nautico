# Cómo actualizar la página de récords

La página lee todo de la carpeta `data/`. Para actualizar **no hace falta tocar código**.

## Pasos

1. Pide a Claude (proyecto "Club - Reportes y tests") que regenere los JSON.
   Recuérdale que **las marcas de exhibición (x) cuentan para los récords** si son las más rápidas, y que
   los nuevos JSON deben conservar estas correcciones (18/10/2026):
   - Incluir las marcas del **Excel oficial de Cali 2023** (`Resultados XL Torneo Interclubes de Natación - Ciudad de Cali 2023 NAUE.xlsx`, piscina de 50 m).
   - La nadadora se escribe **"Fustillos, Natalí"** (no Nataly).
2. Reemplaza los archivos de `data/` por los nuevos, con los mismos nombres:
   - `records_piscina.json`
   - `top10_piscina.json`
   - `relevos_records.json`
   - `records_aguas_abiertas.json`
   - `top_aguas_abiertas.json`
   - `historico_records.json` y `historico_top10.json` (página aparte `historico.html`, 2002–2009; cambian solo si aparecen resultados viejos)
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

## Qué hace la página con los datos

- No recalcula nada: muestra los JSON tal como vienen.
- Marcas con `marca = "x"` (exhibición): cuentan igual para el Top 10 y para los récords del club;
  se muestran con la etiqueta "Exhibición" solo como información.
- No se muestran edades.
- Si `lugar` viene vacío, se muestra "Ecuador" (como en la tabla impresa).
- La página tiene `noindex`: no aparece en Google; se comparte por enlace.
