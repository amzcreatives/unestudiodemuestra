# Un Estudio Demuestra · web

Tácticas de marketing respaldadas por estudios científicos.

- `public/`: la web que publica Vercel (`index.html` = landing, `biblioteca.html` = biblioteca).
- `fuentes/`: todos los estudios citados, con lo que encontraron y dónde se comprobó. No se publica en la web.
- `supabase/`: base de datos de usuarios y contenido PRO. Instrucciones en `supabase/README.md`.
- `public/config.js`: conexión con Supabase (URL y clave pública).
- `public/admin.html`: panel para dar o quitar el PRO (`/admin`).
- `vercel.json`: indica a Vercel que solo publique la carpeta `public/`.

Cada cambio que se sube a la rama `main` se publica solo en Vercel.
