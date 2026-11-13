"""Trae a la página las mejores marcas del club en travesías y otras competencias (no FENA).

Lee tv_records.json y tv_top.json (los escribe travesias.py), los valida, deja solo los campos que se
publican y escribe data/travesias_records.json y data/travesias_top.json (una línea, UTF-8 sin BOM,
mismo estilo que los JSON de aguas abiertas).

No se publican: edad, fecha de nacimiento, IDs internos (N-###, X-…), ni la categoría de la carrera
(en estas travesías la categoría suele ser la edad exacta: "M12 SPRINT", "F13 MEDIA CH", "14", "57"…).

Uso (Python estándar, sin dependencias):
  python -I herramientas/traer_travesias.py <tv_records.json> <tv_top.json> [carpeta data]
Termina con código 0 si escribió los archivos y 1 si encontró errores (en ese caso no escribe nada).
"""
import json
import os
import re
import sys

# Campos que se publican, en este orden (mismo estilo que records_aguas_abiertas.json)
CAMPOS = ['distancia', 'dist_km', 'rama', 'tiempo', 'segundos', 'nadador', 'fecha', 'torneo', 'puesto_carrera']
# Ortografía acordada de nombres (lista completa en CLAUDE.local.md, que no se publica)
ALIAS = {'Natali Fustillos': 'Natalí Fustillos'}
# Notas internas que vienen pegadas al nombre del evento y no deben publicarse
NOTAS_INTERNAS = [re.compile(r'\s*-\s*captura app\s*\(evento inferido\)', re.I)]
RE_ID = re.compile(r'\b(N|X)-\d{2,}\b')
RE_FECHA = re.compile(r'^(\d{4}-\d{2}-\d{2}|(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre) \d{4})?$')
RE_TIEMPO = re.compile(r'^(\d{1,2}:)?\d{1,2}:\d{2}(\.\d{2})?$')
PROHIBIDAS = re.compile(r'edad|nac|cedula|c[eé]dula|^id$|clave|telefono|correo', re.I)

errores, avisos = [], []


def seg(t):
    s = 0.0
    for x in t.split(':'):
        s = s * 60 + float(x)
    return s


def leer(ruta):
    try:
        with open(ruta, encoding='utf-8-sig') as f:
            d = json.load(f)
    except Exception as e:  # noqa: BLE001
        sys.exit(f'ERROR: no se pudo leer {ruta}: {e}')
    if not isinstance(d, list) or not d:
        sys.exit(f'ERROR: {ruta} debe ser una lista con filas')
    return d


def limpiar(r, i, nombre_archivo, con_puesto):
    id_ = f'{nombre_archivo}[{i}] {r.get("distancia")} {r.get("rama")} {r.get("tiempo")}'
    for k in r:
        if PROHIBIDAS.search(k):
            avisos.append(f'{id_}: se quita el campo "{k}"')
    for k in ('nadador', 'rama', 'dist_m', 'distancia', 'segundos', 'tiempo', 'evento'):
        if r.get(k) in (None, ''):
            errores.append(f'{id_}: falta "{k}"')
    if errores and errores[-1].startswith(id_):
        return None
    if r['rama'] not in ('M', 'F'):
        errores.append(f'{id_}: rama inválida "{r["rama"]}"')
    try:
        dm = int(r['dist_m'])
        sg = float(r['segundos'])
    except (TypeError, ValueError):
        errores.append(f'{id_}: dist_m o segundos no son números')
        return None
    if dm <= 0 or sg <= 0:
        errores.append(f'{id_}: distancia o tiempo no positivos')
    t = str(r['tiempo'])
    if not RE_TIEMPO.match(t):
        errores.append(f'{id_}: tiempo con formato raro "{t}"')
    elif abs(seg(t) - sg) > 0.6:
        errores.append(f'{id_}: "segundos" ({sg}) no coincide con "tiempo" ({t})')
    nadador = ALIAS.get(str(r['nadador']).strip(), str(r['nadador']).strip())
    torneo = str(r['evento']).strip()
    for rx in NOTAS_INTERNAS:
        if rx.search(torneo):
            avisos.append(f'{id_}: se quita una nota interna del evento ("{rx.search(torneo).group(0).strip()}")')
            torneo = rx.sub('', torneo).strip()
    fecha = str(r.get('fecha') or '').strip()
    if not RE_FECHA.match(fecha):
        errores.append(f'{id_}: fecha con formato raro "{fecha}"')
    elif not fecha:
        avisos.append(f'{id_}: sin fecha (se mostrará solo el evento)')
    out = {
        'distancia': str(r['distancia']), 'dist_km': round(dm / 1000, 3), 'rama': r['rama'],
        'tiempo': t, 'segundos': sg, 'nadador': nadador, 'fecha': fecha, 'torneo': torneo,
        'puesto_carrera': str(r.get('puesto_carrera') or ''),
    }
    if con_puesto:
        try:
            out['puesto'] = int(r['puesto'])
        except (KeyError, TypeError, ValueError):
            errores.append(f'{id_}: sin puesto válido')
    for v in out.values():
        if isinstance(v, str) and RE_ID.search(v):
            errores.append(f'{id_}: contiene un ID interno ({RE_ID.search(v).group(0)})')
    return out


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    ruta_rec, ruta_top = sys.argv[1], sys.argv[2]
    data = sys.argv[3] if len(sys.argv) > 3 else os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')
    rec = [limpiar(r, i, 'tv_records', False) for i, r in enumerate(leer(ruta_rec), 1)]
    top = [limpiar(r, i, 'tv_top', True) for i, r in enumerate(leer(ruta_top), 1)]
    rec = [r for r in rec if r]
    top = [r for r in top if r]

    # Top: por distancia y rama, puestos 1..n consecutivos, ordenados por tiempo, máx. 10, sin repetidos
    grupos = {}
    for t in top:
        grupos.setdefault((t['dist_km'], t['rama']), []).append(t)
    for (d, g), f in grupos.items():
        f.sort(key=lambda x: x.get('puesto', 0))
        nm = f'Top {f[0]["distancia"]} {g}'
        if len(f) > 10:
            errores.append(f'{nm}: {len(f)} filas (máximo 10)')
        for k, x in enumerate(f):
            if x.get('puesto') != k + 1:
                errores.append(f'{nm}: puestos no consecutivos')
                break
            if k and x['segundos'] < f[k - 1]['segundos']:
                errores.append(f'{nm}: el puesto {k + 1} es más rápido que el {k}')
        noms = [x['nadador'] for x in f]
        for n in set(noms):
            if noms.count(n) > 1:
                errores.append(f'{nm}: nadador repetido {n}')
        if len({x['distancia'] for x in f}) > 1:
            errores.append(f'{nm}: la misma distancia escrita de dos formas')
    # Récord = puesto 1 de su grupo, uno por distancia y rama
    vistos = set()
    for r in rec:
        k = (r['dist_km'], r['rama'])
        nm = f'Récord {r["distancia"]} {r["rama"]}'
        if k in vistos:
            errores.append(f'{nm}: repetido')
        vistos.add(k)
        f = grupos.get(k)
        if not f:
            errores.append(f'{nm}: no tiene Top')
        elif (f[0]['nadador'], f[0]['tiempo']) != (r['nadador'], r['tiempo']):
            errores.append(f'{nm}: no coincide con el puesto 1 del Top')
    for k in grupos:
        if k not in vistos:
            errores.append(f'Top {grupos[k][0]["distancia"]} {k[1]}: sin récord')

    for a in avisos:
        print('AVISO', a)
    if errores:
        for e in errores:
            print('ERROR', e)
        print(f'\n{len(errores)} error(es): no se escribió nada.')
        sys.exit(1)

    rec.sort(key=lambda x: (x['dist_km'], x['rama']))
    top.sort(key=lambda x: (x['dist_km'], x['rama'], x['puesto']))
    os.makedirs(data, exist_ok=True)
    for nombre, filas in (('travesias_records.json', rec), ('travesias_top.json', top)):
        ruta = os.path.join(data, nombre)
        with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
            f.write(json.dumps(filas, ensure_ascii=False))
        print(f'escrito {os.path.normpath(ruta)}: {len(filas)} filas')
    print(f'Distancias: {len(rec)} récords · eventos: {len({t["torneo"] for t in top})} · nadadores: {len({t["nadador"] for t in top})}')


if __name__ == '__main__':
    main()
