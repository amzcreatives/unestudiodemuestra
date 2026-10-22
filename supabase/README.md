# Supabase · base de datos de Un Estudio Demuestra

Proyecto: **unestudiodemuestra** (región París) · `https://kbzwzbnobmrelmyjyhno.supabase.co`

## Puesta en marcha (una vez)

1. Supabase → **SQL Editor** → New query → pega **`TODO-EN-UNO.sql`** entero → **Run**.
   (Es lo mismo que ejecutar `01-usuarios.sql`, `02-tacticas-calendario-imagenes.sql` y `03-datos-tacticas.sql` en orden.)
2. **Authentication → URL Configuration**:
   - Site URL: `https://unestudiodemuestra.vercel.app`
   - Redirect URLs: añade `https://unestudiodemuestra.vercel.app/**`
3. Regístrate en la biblioteca (Entrar → Crear cuenta) y confirma el email.
4. SQL Editor → pega **`04-hacerme-admin.sql`** → Run. Ya puedes entrar en `/admin`.

## Qué hay en la base de datos

- `perfiles`: un registro por usuario con su `plan` (free/pro), su `rol` (usuario/admin) y, opcional, `pro_hasta`.
- `tacticas`: todas las tácticas, publicadas o no, con su `estado` (idea, preparacion, video_listo, programada, publicada), `fecha_publicacion`, `url_reel` y el contenido público (`contenido`).
  - La web solo recibe las **publicadas** y las **programadas cuya fecha ya ha llegado**.
  - De las demás (en preparación, vídeo listo, programadas) solo llega el aviso de «Próximamente»: título, tema y fecha. Nunca el contenido.
  - No puede haber dos tácticas con el mismo título.
- `pasos_pro`: el «Cómo aplicarlo» de cada táctica. Solo lo leen usuarios PRO (y admins), y solo de tácticas publicadas.
- Almacén de imágenes:
  - `publico`: portadas y figuras (cualquiera puede verlas).
  - `pro`: imágenes de los pasos. Privado: la web pide un enlace temporal solo para usuarios PRO.

Todo lo protege la base de datos (Row Level Security), no la página.

## Usuario de prueba

Authentication → Users → Add user → Create new user, con «Auto Confirm User» marcado. Luego, en `/admin` → Usuarios y accesos, ponle PRO.

## Volver a cargar los textos de las tácticas

`03-datos-tacticas.sql` se puede ejecutar otra vez: actualiza títulos y textos, pero no toca el estado ni la fecha de publicación.
