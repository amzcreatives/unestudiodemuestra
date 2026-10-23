import sys, os, shutil, subprocess
sys.path.insert(0,'/tmp/claude-0/-home-claude/2ce46cb0-e55c-53e0-b91e-84f646eac286/scratchpad/video'); sys.path.insert(0,'.')
from common import setup
import svgs
from playwright.sync_api import sync_playwright
K='CiCi-mascota'; shutil.rmtree(K, ignore_errors=True)
ST=list(svgs.STATES)
NUM={s:f'{i+1}-{s}' for i,s in enumerate(ST)}
def w(path, txt): os.makedirs(os.path.dirname(path), exist_ok=True); open(path,'w').write(txt)
# 1 · SVG
for s in ST:
    w(f'{K}/1-vector-SVG/cici-{NUM[s]}.svg', svgs.svg(s))
    w(f'{K}/1-vector-SVG/para-fondos-claros/cici-{NUM[s]}-fondo-claro.svg', svgs.svg(s, light=True))
    w(f'{K}/5-extra-version-con-brazos/vector-SVG/cici-brazos-{NUM[s]}.svg', svgs.svg(s, arms=True))
# 2 · PNG (mismo lienzo 1400×1600 para todos los estados)
PW,PH=1400,1600
jobs=[]
for s in ST:
    jobs+= [(svgs.svg(s,w=PW,h=PH), f'{K}/2-PNG-transparente/con-sombra/cici-{NUM[s]}.png'),
            (svgs.svg(s,shadow=False,w=PW,h=PH), f'{K}/2-PNG-transparente/sin-sombra/cici-{NUM[s]}.png'),
            (svgs.svg(s,light=True,w=PW,h=PH), f'{K}/2-PNG-transparente/para-fondos-claros/cici-{NUM[s]}-fondo-claro.png'),
            (svgs.svg(s,arms=True,w=PW,h=PH), f'{K}/5-extra-version-con-brazos/PNG-transparente/cici-brazos-{NUM[s]}.png')]
FONT_CSS='<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;800&family=JetBrains+Mono:wght@500&display=swap">'
with sync_playwright() as p:
    b=p.chromium.launch()
    c=b.new_context(viewport={'width':PW,'height':PH}); setup(c,None); pg=c.new_page()
    for svg,out in jobs:
        os.makedirs(os.path.dirname(out), exist_ok=True)
        pg.set_content(f'<html><body style="margin:0;background:transparent">{svg}</body></html>')
        pg.locator('svg').screenshot(path=out, omit_background=True)
    # 4 · avatar
    for name,bg,light in [('avatar-fondo-tinta',"#141A24",False),('avatar-fondo-papel',"#F6F7F4",True)]:
        c2=b.new_context(viewport={'width':1080,'height':1080}); setup(c2,None); q=c2.new_page()
        q.set_content(f'<html><body style="margin:0;width:1080px;height:1080px;background:{bg};display:grid;place-items:center">{svgs.svg("reposo",light=light,shadow=True,w=860,h=983)}</body></html>')
        os.makedirs(f'{K}/4-avatar', exist_ok=True); q.screenshot(path=f'{K}/4-avatar/cici-{name}-1080.png')
    # hoja de estados
    LBL={'reposo':('Reposo','Por defecto. Presenta, espera.'),'escuchando':('Escuchando','Mientras alguien pregunta o escribe.'),
         'pensando':('Pensando','Busca en los estudios: los datos suben.'),'escribiendo':('Escribiendo','Da la respuesta: la boca se mueve, el 1 brilla.'),
         'contenta':('Contenta','Ha encontrado la respuesta. Celebra.'),'sin-evidencia':('Sin evidencia','No hay estudios que lo respalden: el 1 pasa a ?.')}
    cells=''.join(f'<div class=c><div class=a>{svgs.svg(s,w=280,h=320)}</div><b>{i+1} · {LBL[s][0]}</b><span>{LBL[s][1]}</span></div>' for i,s in enumerate(ST))
    cells2=''.join(f'<div class=c><div class=a>{svgs.svg(s,arms=True,w=160,h=183)}</div><b>{LBL[s][0]}</b></div>' for s in ST)
    html=f'''<html><head>{FONT_CSS}<style>body{{margin:0;background:#0E1219;color:#F6F7F4;font-family:"Public Sans";width:1800px;padding:64px 72px;box-sizing:border-box}}
    h1{{font-weight:800;font-size:54px;margin:0}} .k{{font-family:"JetBrains Mono";font-size:16px;letter-spacing:.16em;color:#F4E35A}} p.s{{color:#A3ACBB;font-size:20px;margin:10px 0 36px}}
    .g{{display:grid;grid-template-columns:repeat(3,1fr);gap:20px}} .c{{background:#1A2130;border:1px solid #2C3546;border-radius:22px;padding:22px;display:grid;justify-items:center;gap:6px;text-align:center}}
    .c b{{font-size:24px}} .c span{{color:#A3ACBB;font-size:16px}} .g2{{display:grid;grid-template-columns:repeat(6,1fr);gap:12px;margin-top:14px}} .g2 .c b{{font-size:16px}}
    .pal{{display:flex;gap:14px;margin-top:36px}} .pal div{{flex:1;border:1px solid #2C3546;border-radius:14px;padding:12px;font-family:"JetBrains Mono";font-size:14px}} .pal i{{display:block;height:46px;border-radius:9px;margin-bottom:8px}}</style></head><body>
    <span class=k>UN ESTUDIO DEMUESTRA · CICI (CIENCIA CITADA)</span><h1>CiCi · hoja de estados</h1><p class=s>La hoja de estudio con vida. La nota al pie «1» es la del logo UED.</p>
    <div class=g>{cells}</div>
    <p class=s style="margin:40px 0 0"><b style="color:#F6F7F4">Extra · versión con brazos</b> (guardada: úsala solo si te la piden)</p><div class=g2>{cells2}</div>
    <div class=pal><div><i style="background:#F6F7F4"></i>Papel #F6F7F4</div><div><i style="background:#D9DDE3"></i>Pliegue y líneas #D9DDE3</div><div><i style="background:#141A24;border:1px solid #2C3546"></i>Tinta (ojos) #141A24</div><div><i style="background:#F4E35A"></i>Subrayador #F4E35A</div><div><i style="background:#5B6472"></i>«?» borde #5B6472</div><div><i style="background:#A3ACBB"></i>«?» #A3ACBB</div></div>
    </body></html>'''
    c3=b.new_context(viewport={'width':1800,'height':1200}); setup(c3,None); q=c3.new_page(); q.set_content(html); q.wait_for_timeout(500)
    q.screenshot(path=f'{K}/0-hoja-de-estados.png', full_page=True)
    # fondo con etiquetas para el vídeo de previsualización (3×2)
    tiles=''.join(f'<div class=t><b>{i+1} · {LBL[s][0]}</b></div>' for i,s in enumerate(ST))
    c4=b.new_context(viewport={'width':1920,'height':1080}); setup(c4,None); q=c4.new_page()
    q.set_content(f'<html><head>{FONT_CSS}<style>body{{margin:0;width:1920px;height:1080px;background:#0E1219;font-family:"Public Sans";display:grid;grid-template-columns:repeat(3,1fr);grid-template-rows:repeat(2,1fr)}} .t{{border:1px solid #1E2636;display:flex;align-items:flex-end;justify-content:center;padding-bottom:22px}} b{{color:#F6F7F4;font-size:28px}}</style></head><body>{tiles}</body></html>')
    q.wait_for_timeout(400); q.screenshot(path='work/preview-bg.png')
print('static done')
