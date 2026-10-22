# Código fuente de la web

Las páginas de `public/` se generan desde aquí con `build/build_web.py`, que:
- sustituye el logo y el favicon (`{{SYMBOL}}`, `{{FAVICON}}`) usando `build/brand.py` y las fuentes del kit de marca;
- mete la mascota animada (`cici-mascota.js`) en `biblioteca.html` y `cici.html`;
- añade la cabecera HTML completa.

`tactics-data.js` es una copia de trabajo del contenido de las tácticas. La fuente de verdad es la base de datos (Supabase, tabla `tacticas` y `pasos_pro`).
