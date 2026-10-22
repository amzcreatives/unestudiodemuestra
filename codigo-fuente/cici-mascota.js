/* ===== CiCi · mascota animada (versión C) =====
   CiciMascota.svg(size, mood) → HTML de la mascota.
   CiciMascota.mood(el, mood)   → cambia el estado de una o varias mascotas.
   Estados: idle (reposo), listen (te escucha mientras escribes), think (piensa), talk (escribe la respuesta),
            answer (contenta al terminar), none (sin evidencia).
   En reposo parpadea, flota, mira de vez en cuando a los lados y sigue el cursor con los ojos. */
(function(){
  const css = `
.cici{overflow:visible;display:block;flex:none}
.cici .cc-body{animation:cc-float 4.2s ease-in-out infinite;transform-origin:60px 128px}
@keyframes cc-float{0%,100%{transform:translateY(0)}50%{transform:translateY(-2.5px)}}
.cici .cc-eyes{transform:translate(var(--gx,0px),var(--gy,0px));transition:transform .28s cubic-bezier(.3,.7,.3,1)}
.cici .cc-eye{transform-box:fill-box;transform-origin:center;animation:cc-blink 5.2s infinite}
.cici .cc-eye.r{animation-delay:.04s}
@keyframes cc-blink{0%,93%,100%{transform:scaleY(1)}95.5%{transform:scaleY(.12)}}
.cici .cc-mouth{transform-box:fill-box;transform-origin:center;transition:transform .25s}
.cici .cc-happy,.cici .cc-smile,.cici .cc-flat,.cici .cc-dots,.cici .cc-glow,.cici .cc-bq{display:none}
.cici .cc-badge{transform-box:fill-box;transform-origin:center}
/* te escucha mientras escribes: mira hacia abajo, boca pequeña, la nota al pie asiente */
.cici[data-mood=listen] .cc-eyes{transform:translate(-2px,4px)}
.cici[data-mood=listen] .cc-mouth{transform:scaleX(.55)}
.cici[data-mood=listen] .cc-badge{animation:cc-nod .9s ease-in-out infinite}
@keyframes cc-nod{0%,100%{transform:translateY(0)}50%{transform:translateY(2px)}}
/* piensa: mira arriba, los datos suben, se balancea */
.cici[data-mood=think] .cc-eyes{transform:translate(3px,-5px)}
.cici[data-mood=think] .cc-mouth{transform:scaleX(.45) translateX(8px)}
.cici[data-mood=think] .cc-dots{display:inline}
.cici[data-mood=think] .cc-body{animation:cc-wobble 1.6s ease-in-out infinite}
@keyframes cc-wobble{0%,100%{transform:rotate(-2deg)}50%{transform:rotate(2deg)}}
.cici .cc-dots circle{animation:cc-rise 1.4s ease-in-out infinite;transform-box:fill-box}
.cici .cc-dots circle:nth-child(2){animation-delay:.22s}.cici .cc-dots circle:nth-child(3){animation-delay:.44s}
@keyframes cc-rise{0%{opacity:0;transform:translateY(6px)}50%{opacity:1}100%{opacity:0;transform:translateY(-6px)}}
/* escribe la respuesta: la boca (el subrayador) se mueve y el «1» brilla */
.cici[data-mood=talk] .cc-mouth{animation:cc-talk .32s ease-in-out infinite alternate}
@keyframes cc-talk{from{transform:scaleX(.55) scaleY(1)}to{transform:scaleX(1.05) scaleY(1.5)}}
.cici[data-mood=talk] .cc-glow,.cici[data-mood=answer] .cc-glow{display:inline}
.cici .cc-glow{animation:cc-pulse 1.4s ease-in-out infinite;transform-box:fill-box;transform-origin:center}
@keyframes cc-pulse{0%,100%{transform:scale(.8);opacity:.15}50%{transform:scale(1.15);opacity:.4}}
/* contenta al terminar */
.cici[data-mood=answer] .cc-eyes,.cici[data-mood=answer] .cc-mouth{display:none}
.cici[data-mood=answer] .cc-happy,.cici[data-mood=answer] .cc-smile{display:inline}
.cici[data-mood=answer] .cc-body{animation:cc-hop .5s ease-out 1}
@keyframes cc-hop{0%{transform:translateY(0)}40%{transform:translateY(-6px)}100%{transform:translateY(0)}}
/* sin evidencia: mira abajo, boca gris, el «1» pasa a «?» */
.cici[data-mood=none] .cc-eyes{transform:translate(0,3px)}
.cici[data-mood=none] .cc-mouth{display:none}
.cici[data-mood=none] .cc-flat,.cici[data-mood=none] .cc-bq{display:inline}
.cici[data-mood=none] .cc-b1{display:none}
@media (prefers-reduced-motion:reduce){.cici *{animation:none!important;transition:none!important}}
`;
  if (!document.getElementById('cc-style')){ const st = document.createElement('style'); st.id = 'cc-style'; st.textContent = css; document.head.appendChild(st); }

  function svg(size, mood, label){
    const h = Math.round(size * 140 / 120);
    return `<svg class="cici" data-mood="${mood || 'idle'}" width="${size}" height="${h}" viewBox="0 0 120 140" ${label ? `role="img" aria-label="${label}"` : 'aria-hidden="true"'}>
<ellipse cx="60" cy="134" rx="32" ry="4" fill="#000" opacity="0.28"/>
<g class="cc-body">
<path d="M30 14 H78 L98 34 V120 Q98 128 90 128 H30 Q22 128 22 120 V22 Q22 14 30 14 Z" fill="#F6F7F4"/>
<path d="M78 14 V28 Q78 34 84 34 H98 Z" fill="#D9DDE3"/>
<path d="M34 100 H86 M34 108 H78 M34 116 H68" stroke="#D9DDE3" stroke-width="3" stroke-linecap="round" fill="none"/>
<g class="cc-dots"><circle cx="66" cy="90" r="2.5" fill="#F4E35A"/><circle cx="78" cy="80" r="3.5" fill="#F4E35A"/><circle cx="90" cy="68" r="4.5" fill="#F4E35A"/></g>
<g class="cc-eyes"><circle class="cc-eye l" cx="46" cy="56" r="4.8" fill="#141A24"/><circle class="cc-eye r" cx="74" cy="56" r="4.8" fill="#141A24"/></g>
<path class="cc-happy" d="M40 58 Q46 50 52 58 M68 58 Q74 50 80 58" stroke="#141A24" stroke-width="4.2" stroke-linecap="round" fill="none"/>
<rect class="cc-mouth" x="47" y="68" width="26" height="7" rx="1.5" fill="#F4E35A"/>
<path class="cc-smile" d="M46 69 Q60 79 74 69" stroke="#F4E35A" stroke-width="7" stroke-linecap="round" fill="none"/>
<rect class="cc-flat" x="50" y="71" width="20" height="5" rx="1.5" fill="#D9DDE3"/>
<circle class="cc-glow" cx="98" cy="17" r="19" fill="#F4E35A"/>
<g class="cc-badge"><g class="cc-b1"><circle cx="98" cy="17" r="13" fill="#F4E35A"/><text x="98" y="22.5" text-anchor="middle" font-family="JetBrains Mono, monospace" font-size="15" font-weight="700" fill="#141A24">1</text></g>
<g class="cc-bq"><circle cx="98" cy="17" r="12" fill="#141A24" stroke="#5B6472" stroke-width="2"/><text x="98" y="22.5" text-anchor="middle" font-family="JetBrains Mono, monospace" font-size="15" font-weight="700" fill="#A3ACBB">?</text></g></g>
</g></svg>`;
  }
  function mood(target, m){
    const els = typeof target === 'string' ? document.querySelectorAll(target) : (target instanceof Element ? [target] : target);
    (els || []).forEach(el => { const s = el.matches && el.matches('svg.cici') ? el : el.querySelector && el.querySelector('svg.cici'); if (s) s.setAttribute('data-mood', m); });
  }
  /* los ojos siguen el cursor (solo en reposo) */
  let raf = null, px = 0, py = 0;
  window.addEventListener('pointermove', (e) => { px = e.clientX; py = e.clientY; if (!raf) raf = requestAnimationFrame(gaze); }, { passive: true });
  function gaze(){
    raf = null;
    document.querySelectorAll('svg.cici[data-mood=idle]').forEach(s => {
      const r = s.getBoundingClientRect(); if (!r.width) return;
      const dx = px - (r.left + r.width / 2), dy = py - (r.top + r.height * 0.4);
      const d = Math.hypot(dx, dy) || 1, k = Math.min(1, d / 260);
      s.style.setProperty('--gx', (dx / d * 3.2 * k).toFixed(2) + 'px');
      s.style.setProperty('--gy', (dy / d * 3.2 * k).toFixed(2) + 'px');
    });
  }
  /* de vez en cuando mira a un lado (si el cursor está quieto) */
  let lastMove = Date.now();
  window.addEventListener('pointermove', () => { lastMove = Date.now(); }, { passive: true });
  setInterval(() => {
    if (Date.now() - lastMove < 4000) return;
    document.querySelectorAll('svg.cici[data-mood=idle]').forEach(s => {
      const side = Math.random() < 0.5 ? -1 : 1;
      s.style.setProperty('--gx', (side * 3) + 'px'); s.style.setProperty('--gy', '0px');
      setTimeout(() => { s.style.setProperty('--gx', '0px'); }, 1100);
    });
  }, 6500);
  window.CiciMascota = { svg, mood };
})();
