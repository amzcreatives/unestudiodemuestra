import base64, os, sys
sys.path.insert(0, '/tmp/claude-0/-home-claude/2ce46cb0-e55c-53e0-b91e-84f646eac286/scratchpad/kitbuild')
import brand as B
sym = f'<svg viewBox="15 8 71 87" aria-hidden="true" focusable="false">{B.symbol("dark")}</svg>'
fav = open('/tmp/claude-0/-home-claude/2ce46cb0-e55c-53e0-b91e-84f646eac286/scratchpad/UED-kit-de-marca/02-favicon/favicon.svg').read()
favuri = 'data:image/svg+xml;base64,' + base64.b64encode(fav.encode()).decode()
os.makedirs('/home/claude/ued-web/vercel', exist_ok=True)
for name, out, vout in [('landing','un-estudio-demuestra-landing.html','index.html'),('biblioteca','un-estudio-demuestra-biblioteca.html','biblioteca.html'),('admin','un-estudio-demuestra-admin.html','admin.html'),('cici','un-estudio-demuestra-cici.html','cici.html')]:
    s = open(f'/home/claude/ued-web/src/{name}.html').read()
    s = s.replace('/*{{CICI_MASCOTA}}*/', open('/home/claude/ued-web/src/cici-mascota.js').read())
    s = s.replace('{{SYMBOL_SMALL}}', sym.replace('\n',' ')).replace('{{SYMBOL}}', sym).replace('{{FAVICON}}', favuri)
    photos = {'{{PHOTO_T08A}}': 't08-portada.jpg', '{{PHOTO_T08B}}': 't08-canela.jpg'}
    art = s
    if name == 'biblioteca':
        art = art.replace('/*{{FALLBACK}}*/null', '(window.UED_PREVIEW = true, ' + open('/home/claude/ued-web/src/fallback-preview.json').read() + ')')
    for k, f in photos.items():
        art = art.replace(k, 'data:image/jpeg;base64,' + base64.b64encode(open('/home/claude/ued-web/img/' + f, 'rb').read()).decode())
        s = s.replace(k, 'img/' + f)
    open(f'/home/claude/ued-web/{out}', 'w').write(art)
    head_end = s.index('</style>') + len('</style>')
    head, body = s[:head_end], s[head_end:]
    head = head.replace('<meta name="claude:viewport-fit-sides" content="cover">\n','')
    doc = ('<!doctype html>\n<html lang="es">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
           + head + '\n</head>\n<body>' + body + '\n</body>\n</html>\n')
    open(f'/home/claude/ued-web/vercel/{vout}', 'w').write(doc)
    print(out, len(s))
