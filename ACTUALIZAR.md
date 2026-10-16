# Cómo actualizar la página de récords

La página lee todo de la carpeta `data/`. Para actualizar **no hace falta tocar código**.

## Pasos

1. Pide a Claude (proyecto "Club - Reportes y tests") que regenere los JSON.
2. Reemplaza los archivos de `data/` por los nuevos, con los mismos nombres:
   - `records_piscina.json`
   - `top10_piscina.json`
   - `relevos_records.json`
   - `records_aguas_abiertas.json`
   - `top_aguas_abiertas.json`
3. Si el nuevo `relevos_records.json` no trae las edades de los integrantes, agrégalas desde
   `relevos_club.csv` (está en `Resultados FENA historico\_records_club\`):

   ```bash
   powershell -ExecutionPolicy Bypass -File herramientas\agregar_edades_relevos.ps1 -Csv "C:\Users\secre\Dropbox\CLUB NAUTICO 2026 (1)\REPORTES NADADORES\Resultados FENA historico\_records_club\relevos_club.csv"
   ```

4. En `index.html`, cambia la fecha del pie: busca `Actualizado al` y escribe la fecha nueva.
5. Verifica los datos. Debe terminar con **"OK: datos verificados, sin errores."**
   Si sale **ERRORES**, no publiques: corrige o pide a Claude que lo revise.

   ```bash
   powershell -ExecutionPolicy Bypass -File herramientas\verificar_datos.ps1
   ```

6. Sube los cambios:

   ```bash
   git add -A
   git commit -m "Actualizar récords"
   git push
   ```

7. Espera 1–2 minutos y abre la verificación de la página publicada. Debe decir **"✓ Todo bien"**:
   `https://clubnautico.github.io/records-club-nautico/herramientas/verificar.html`

   Recarga en el celular. GitHub guarda la página en caché unos 10 minutos: si no ves el cambio, espera y recarga.

## Qué hace la página con los datos

- No recalcula nada: muestra los JSON tal como vienen.
- Marcas con `marca = "x"`: se muestran con la etiqueta "Exhibición" y nunca como récord.
- Edad: se muestra la edad con la que se nadó cada marca (`edad`; en relevos, `edades`).
  En aguas abiertas solo hay categoría (`categoria`), y se muestra así.
- Si `lugar` viene vacío, se muestra "Ecuador" (como en la tabla impresa).
- La página tiene `noindex`: no aparece en Google; se comparte por enlace.
