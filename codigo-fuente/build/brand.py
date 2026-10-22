"""Geometría y utilidades de la marca Un Estudio Demuestra.
Todo el texto se convierte a trazados para que los SVG no dependan de fuentes instaladas."""
import io
from functools import lru_cache
import uharfbuzz as hb
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.boundsPen import BoundsPen

FONTDIR = '/tmp/claude-0/-home-claude/2ce46cb0-e55c-53e0-b91e-84f646eac286/scratchpad/kitfonts/'

INK = '#141A24'
MARK = '#F4E35A'
PAPER = '#F6F7F4'
WHITE = '#FFFFFF'
SLATE = '#5B6472'
RULE = '#D9DDE3'
LAB = '#2346C9'


@lru_cache(None)
def font(name, **axes):
    files = {'serif': 'newsreader__Newsreader[opsz,wght].ttf',
             'serif-it': 'newsreader__Newsreader-Italic[opsz,wght].ttf',
             'mono': 'jetbrainsmono__JetBrainsMono[wght].ttf',
             'sans': 'publicsans__PublicSans[wght].ttf'}
    f = TTFont(FONTDIR + files[name])
    inst = instancer.instantiateVariableFont(f, axes)
    buf = io.BytesIO()
    inst.save(buf)
    data = buf.getvalue()
    return TTFont(io.BytesIO(data)), data


def text_path(text, fname, size, x=0, y=0, anchor='start', tracking=0.0, **axes):
    """Devuelve (d, bbox) del texto convertido a trazado. tracking en em."""
    tt, data = font(fname, **axes)
    upm = tt['head'].unitsPerEm
    face = hb.Face(data)
    hbf = hb.Font(face)
    buf = hb.Buffer()
    buf.add_str(text)
    buf.guess_segment_properties()
    hb.shape(hbf, buf, {'kern': True, 'liga': True})
    gs = tt.getGlyphSet()
    order = tt.getGlyphOrder()
    s = size / upm
    track = tracking * upm
    # ancho total
    adv = sum(p.x_advance + track for p in buf.glyph_positions) - track
    if anchor == 'middle':
        x0 = x - adv * s / 2
    elif anchor == 'end':
        x0 = x - adv * s
    else:
        x0 = x
    pen = SVGPathPen(gs)
    bpen = BoundsPen(gs)
    cx = 0
    for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
        g = order[info.codepoint]
        t = (s, 0, 0, -s, x0 + (cx + pos.x_offset) * s, y - pos.y_offset * s)
        gs[g].draw(TransformPen(pen, t))
        gs[g].draw(TransformPen(bpen, t))
        cx += pos.x_advance + track
    return pen.getCommands(), bpen.bounds, adv * s


# ---------- símbolo (viewBox 0 0 100 100) ----------
BRACKETS = ('M37 16 H15 V84 H37 V76 H23 V24 H37 Z '
            'M63 16 H85 V84 H63 V76 H77 V24 H63 Z')
BRACKETS_SMALL = ('M39 14 H12 V86 H39 V75 H24 V25 H39 Z '
                  'M61 14 H88 V86 H61 V75 H76 V25 H61 Z')


def circle_d(cx, cy, r):
    return f'M{cx - r} {cy} a{r} {r} 0 1 0 {2 * r} 0 a{r} {r} 0 1 0 {-2 * r} 0 Z'


def one_glyph(cx, cy, size):
    d, b, _ = text_path('1', 'mono', size, cx, 0, 'middle', wght=500)
    # centrar ópticamente por la caja del glifo
    gh = b[3] - b[1]
    base = cy + gh / 2 - 0.0
    d, b, _ = text_path('1', 'mono', size, cx, base, 'middle', wght=500)
    # corrección horizontal por la caja real
    gx = (b[0] + b[2]) / 2
    d, b, _ = text_path('1', 'mono', size, cx + (cx - gx), base, 'middle', wght=500)
    return d


# ---------- símbolo E3 · "el dato sale del papel" (viewBox 0 0 100 100) ----------
# caja visible del símbolo completo (incluye el grosor del trazo)
SYM_BOX = (17.5, 10.0, 84.0, 92.5)
PAPER_PATH = 'M25 14 H58 M80 36 V85 Q80 90 75 90 H25 Q20 90 20 85 V19 Q20 14 25 14'
PAPER_PATH_SMALL = 'M25 14 H55 M80 39 V85 Q80 90 75 90 H25 Q20 90 20 85 V19 Q20 14 25 14'


@lru_cache(None)
def ued_letters(size, base):
    d, b, w = text_path('UED', 'serif', size, 50, base, 'middle', wght=600, opsz=24)
    return d


def symbol(variant='dark', small=False, favicon=False):
    """Grupo SVG del símbolo en un lienzo de 100x100.
    variant: dark (sobre fondo oscuro), light (sobre fondo claro), mono-ink, mono-white.
    small: versión reducida (24-48 px, sin el 1 ni la estela). favicon: sin letras (16-32 px)."""
    if favicon:
        stroke, path = 10, PAPER_PATH_SMALL
        dots = [(42, 50, 6.5, .75), (71, 23, 15, 1.0)]
        letters, one = None, None
    elif small:
        stroke, path = 8, PAPER_PATH_SMALL
        dots = [(72, 22, 14, 1.0)]
        letters, one = ued_letters(19.5, 79.5), None
    else:
        stroke, path = 5, PAPER_PATH
        dots = [(34, 52, 2.6, .4), (47, 40, 4.2, .7), (72, 22, 12, 1.0)]
        letters, one = ued_letters(19.5, 79), one_glyph(72, 22, 15)
    bigx, bigy, bigr, _ = dots[-1]
    if variant == 'dark':
        c_line, c_dot, c_trail = PAPER, MARK, MARK
    elif variant == 'light':
        c_line, c_dot, c_trail = INK, MARK, INK
    elif variant == 'mono-ink':
        c_line = c_dot = c_trail = INK
    else:
        c_line = c_dot = c_trail = WHITE
    out = [f'<path d="{path}" fill="none" stroke="{c_line}" stroke-width="{stroke}" stroke-linecap="round" stroke-linejoin="round"/>']
    if letters:
        out.append(f'<path d="{letters}" fill="{c_line}"/>')
    for (x, y, r, op) in dots[:-1]:
        o = op if variant != 'light' else (0.3 if r < 3 else 0.55)
        out.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c_trail}" fill-opacity="{o}"/>')
    if variant in ('dark', 'light'):
        out.append(f'<circle cx="{bigx}" cy="{bigy}" r="{bigr}" fill="{c_dot}"/>')
        if one:
            out.append(f'<path d="{one}" fill="{INK}"/>')
    else:
        # monocromo: el 1 queda calado dentro del círculo
        d = circle_d(bigx, bigy, bigr) + (' ' + one if one else '')
        out.append(f'<path d="{d}" fill="{c_dot}" fill-rule="evenodd"/>')
    return '\n'.join(out)


def svg_doc(w, h, body, bg=None, title='Un Estudio Demuestra'):
    bgr = f'<rect width="{w}" height="{h}" fill="{bg}"/>' if bg else ''
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w:g} {h:g}" width="{w:g}" height="{h:g}" '
            f'role="img" aria-label="{title}"><title>{title}</title>{bgr}{body}</svg>\n')


WORD = 'un estudio demuestra'


def wordmark(x, y_center, size, color, anchor='start'):
    """Logotipo en Newsreader 500 centrado verticalmente por la altura de x."""
    d, b, w = text_path(WORD, 'serif', size, 0, 0, 'start', tracking=-0.01, wght=500, opsz=36)
    # altura de x aprox. 0.47 em en Newsreader; centramos la x-height en y_center
    xh = 0.47 * size
    base = y_center + xh / 2
    x0 = x - w / 2 if anchor == 'middle' else x
    d, b, w = text_path(WORD, 'serif', size, x0, base, 'start', tracking=-0.01, wght=500, opsz=36)
    return f'<path d="{d}" fill="{color}"/>', b, w
