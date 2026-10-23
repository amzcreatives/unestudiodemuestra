import sys, os, json, shutil, subprocess
sys.path.insert(0,'/tmp/claude-0/-home-claude/2ce46cb0-e55c-53e0-b91e-84f646eac286/scratchpad/video'); sys.path.insert(0,'.')
from common import setup
import svgs
from playwright.sync_api import sync_playwright
OUT=sys.argv[1]; MODE=sys.argv[2]  # static | anim
os.makedirs(OUT, exist_ok=True)
MOOD={'reposo':'idle','escuchando':'listen','pensando':'think','escribiendo':'talk','contenta':'answer','sin-evidencia':'none'}
LOOP={'reposo':4.2,'escuchando':3.6,'pensando':3.2,'escribiendo':2.6,'contenta':2.8,'sin-evidencia':4.2}
MASC=open('/home/claude/ued-web/src/cici-mascota.js').read()
W,H=1050,1200
def override(state):
    L=LOOP[state]
    css=f".cici .cc-body{{animation-duration:{L}s!important}} .cici .cc-eye{{animation-duration:{L}s!important}}"
    if state=='pensando':
        css+=" .cici[data-mood=think] .cc-body{animation-duration:1.6s!important} .cici .cc-dots circle{animation-duration:1.6s!important;animation-delay:0s!important} .cici .cc-dots circle:nth-child(2){animation-delay:-1.38s!important} .cici .cc-dots circle:nth-child(3){animation-delay:-1.16s!important}"
    if state=='escribiendo':
        css+=" .cici .cc-glow{animation-duration:1.3s!important} .cici[data-mood=talk] .cc-mouth{animation-duration:.325s!important}"
    if state=='contenta':
        css+=" .cici .cc-glow{animation-duration:1.4s!important}"
    if state=='escuchando':
        css+=" .cici .cc-badge{animation-duration:.9s!important}"
    return css
PAGE="""<!doctype html><html><head><meta charset=utf-8><style>html,body{margin:0;background:transparent}#s{width:%dpx;height:%dpx}</style></head><body><div id=s></div><script>%s</script></body></html>"""%(W,H,MASC)
BUILD="""([state,mood,arms,light,ONE,Q,VB,armsD,css])=>{
  const st=document.createElement('style'); st.textContent=css; document.head.appendChild(st);
  const box=document.getElementById('s'); box.innerHTML=CiciMascota.svg(120,mood);
  const s=box.querySelector('svg'); s.setAttribute('viewBox',VB); s.setAttribute('width',%d); s.setAttribute('height',%d);
  const NS='http://www.w3.org/2000/svg';
  s.querySelectorAll('text').forEach(t=>{const p=document.createElementNS(NS,'path');p.setAttribute('d',t.textContent.trim()==='1'?ONE:Q);p.setAttribute('fill',t.getAttribute('fill'));t.replaceWith(p);});
  const body=s.querySelector('.cc-body');
  if(light){const ps=body.querySelectorAll(':scope > path');[ps[0],ps[1]].forEach(p=>{p.setAttribute('stroke','#141A24');p.setAttribute('stroke-width','2.5');p.setAttribute('stroke-linejoin','round')});}
  if(arms){const g=document.createElementNS(NS,'g');g.setAttribute('fill','none');g.setAttribute('stroke',light?'#141A24':'#F6F7F4');g.setAttribute('stroke-width','5');g.setAttribute('stroke-linecap','round');
    armsD.forEach(d=>{const p=document.createElementNS(NS,'path');p.setAttribute('d',d);g.appendChild(p)});body.insertBefore(g,body.firstChild);}
  return document.getAnimations().length;
}"""%(W,H)
with sync_playwright() as p:
    b=p.chromium.launch()
    c=b.new_context(viewport={'width':W,'height':H}); setup(c,None)
    pg=c.new_page()
    variants=[('',False,False),('con-brazos',True,False)] if MODE=='anim' else []
    ONLY=sys.argv[3].split(',') if len(sys.argv)>3 else None
    for sub,arms,light in variants:
        for state in MOOD:
            if ONLY and state not in ONLY: continue
            pg.set_content(PAGE); pg.wait_for_timeout(100)
            n=pg.evaluate(BUILD,[state,MOOD[state],arms,light,svgs.ONE,svgs.Q,svgs.VB,svgs.ARMS[state],override(state)])
            pg.evaluate("document.getAnimations().forEach(a=>a.pause())")
            fd=f'{OUT}/frames/{sub or "c"}/{state}'; shutil.rmtree(fd,ignore_errors=True); os.makedirs(fd)
            N=round(LOOP[state]*30)
            for i in range(N):
                t=i*1000/30
                pg.evaluate(f"document.getAnimations().forEach(a=>{{a.currentTime={t}}})")
                pg.locator('#s').screenshot(path=f'{fd}/f{i:04d}.png', omit_background=True)
            print(sub or 'c', state, 'anims', n, 'frames', N, flush=True)
