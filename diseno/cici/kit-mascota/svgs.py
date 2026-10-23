# Genera los SVG estáticos de CiCi (versión C y C con brazos), un archivo por estado, con capas con nombre.
ONE='M94.76 22.5V20.85H97.61V13.21L94.75 15.35V13.37L97.27 11.55H99.48V20.85H101.78V22.5Z'
Q='M96.39 19.25 96.36 16.25H97.55Q98.3 16.25 98.75 15.84Q99.2 15.44 99.2 14.78Q99.2 14.1 98.75 13.7Q98.3 13.3 97.53 13.3H95.3V11.55H97.44Q98.56 11.55 99.37 11.95Q100.17 12.35 100.62 13.07Q101.08 13.79 101.08 14.78Q101.08 15.69 100.69 16.38Q100.31 17.07 99.63 17.48Q98.96 17.88 98.06 17.89V19.25ZM97.01 22.57Q96.55 22.57 96.26 22.3Q95.97 22.02 95.97 21.59Q95.97 21.15 96.26 20.87Q96.55 20.59 97.01 20.59H97.46Q97.92 20.59 98.2 20.87Q98.48 21.14 98.48 21.59Q98.48 22.02 98.19 22.3Q97.91 22.57 97.44 22.57Z'
VB='-10 -12 140 160'   # mismo lienzo para todos los estados (cabe el brillo y el salto)
STATES={
 'reposo':      dict(eyes=(0,0), mouth=('rect',47,68,26,7)),
 'escuchando':  dict(eyes=(-2,4), mouth=('rect',52.85,68,14.3,7)),
 'pensando':    dict(eyes=(3,-5), mouth=('rect',57.75,68,11.7,7), dots=True),
 'escribiendo': dict(eyes=(0,0), mouth=('rect',46.35,66.25,27.3,10.5), glow=True),
 'contenta':    dict(happy=True, glow=True),
 'sin-evidencia': dict(eyes=(0,3), flat=True, q=True),
}
ARMS={  # brazos de la versión guardada (C + brazos de la B)
 'reposo':['M24 86 Q14 92 12 102','M96 86 Q106 92 108 102'],
 'escuchando':['M24 86 Q14 92 12 102','M96 86 Q106 92 108 102'],
 'pensando':['M24 86 Q14 92 12 102','M96 86 Q104 80 100 72'],
 'escribiendo':['M24 86 Q14 92 12 102','M96 86 Q106 92 108 102'],
 'contenta':['M24 86 Q14 92 12 102','M96 84 Q108 76 108 62'],
 'sin-evidencia':['M24 86 Q14 82 10 72','M96 86 Q106 82 110 72'],
}
def svg(state, arms=False, shadow=True, w=None, h=None, light=False):
    s=STATES[state]; o=[]
    size=f' width="{w}" height="{h}"' if w else ''
    o.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{VB}"{size}>')
    o.append(f'<title>CiCi · {state}</title>')
    if shadow: o.append('<g id="sombra"><ellipse cx="60" cy="134" rx="32" ry="4" fill="#000000" opacity="0.28"/></g>')
    o.append('<g id="cici">')
    if arms:
        a,b=ARMS[state]
        o.append(f'<g id="brazos" fill="none" stroke="{"#141A24" if light else "#F6F7F4"}" stroke-width="5" stroke-linecap="round"><path d="{a}"/><path d="{b}"/></g>')
    st=' stroke="#141A24" stroke-width="2.5" stroke-linejoin="round"' if light else ''
    o.append(f'<g id="hoja"><path d="M30 14 H78 L98 34 V120 Q98 128 90 128 H30 Q22 128 22 120 V22 Q22 14 30 14 Z" fill="#F6F7F4"{st}/>'
             f'<path d="M78 14 V28 Q78 34 84 34 H98 Z" fill="#D9DDE3"{st}/>'
             '<path d="M34 100 H86 M34 108 H78 M34 116 H68" stroke="#D9DDE3" stroke-width="3" stroke-linecap="round" fill="none"/></g>')
    if s.get('dots'):
        o.append('<g id="datos" fill="#F4E35A"><circle cx="66" cy="90" r="2.5" opacity="0.45"/><circle cx="78" cy="80" r="3.5" opacity="0.7"/><circle cx="90" cy="68" r="4.5"/></g>')
    if s.get('happy'):
        o.append('<g id="ojos"><path d="M40 58 Q46 50 52 58 M68 58 Q74 50 80 58" stroke="#141A24" stroke-width="4.2" stroke-linecap="round" fill="none"/></g>')
        o.append('<g id="boca"><path d="M46 69 Q60 79 74 69" stroke="#F4E35A" stroke-width="7" stroke-linecap="round" fill="none"/></g>')
    else:
        dx,dy=s['eyes']
        o.append(f'<g id="ojos" fill="#141A24"><circle cx="{46+dx}" cy="{56+dy}" r="4.8"/><circle cx="{74+dx}" cy="{56+dy}" r="4.8"/></g>')
        if s.get('flat'):
            o.append('<g id="boca"><rect x="50" y="71" width="20" height="5" rx="1.5" fill="#D9DDE3"/></g>')
        else:
            _,x,y,ww,hh=s['mouth']
            o.append(f'<g id="boca"><rect x="{x:g}" y="{y:g}" width="{ww:g}" height="{hh:g}" rx="1.5" fill="#F4E35A"/></g>')
    if s.get('glow'):
        o.append('<g id="brillo"><circle cx="98" cy="17" r="19" fill="#F4E35A" opacity="0.3"/></g>')
    if s.get('q'):
        o.append(f'<g id="nota-al-pie"><circle cx="98" cy="17" r="12" fill="#141A24" stroke="#5B6472" stroke-width="2"/><path d="{Q}" fill="#A3ACBB"/></g>')
    else:
        o.append(f'<g id="nota-al-pie"><circle cx="98" cy="17" r="13" fill="#F4E35A"/><path d="{ONE}" fill="#141A24"/></g>')
    o.append('</g></svg>')
    return '\n'.join(o)+'\n'
