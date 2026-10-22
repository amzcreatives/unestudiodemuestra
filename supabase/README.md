# Supabase · cómo activar el acceso (una sola vez, ~10 minutos)

1. **Crea el proyecto.** En supabase.com → New project. Nombre: `unestudiodemuestra`. Región: Europe (Frankfurt o París). Guarda la contraseña de la base de datos en un sitio seguro.
2. **Crea las tablas.** Supabase → SQL Editor → New query → pega el contenido de `01-esquema.sql` → Run. Después, lo mismo con `02-pasos-pro.sql`.
3. **Dirección de la web.** Authentication → URL Configuration:
   - Site URL: `https://unestudiodemuestra.vercel.app` (o tu dominio cuando lo tengas)
   - Redirect URLs: añade `https://unestudiodemuestra.vercel.app/**`
4. **Conecta la web.** Project Settings → API (o el botón «Connect»): copia **Project URL** y la clave **anon public**. Pégalas en `public/config.js` (o pásaselas a Claude). La clave `service_role` no se pone nunca en la web.
5. **Regístrate tú.** En la biblioteca: Entrar → Crear cuenta, con tu email. Confirma el email.
6. **Hazte administrador.** SQL Editor → pega `03-hacerme-admin.sql` → Run.
7. Entra en `/admin` para dar o quitar el PRO a cualquier usuario.

## Qué hace cada cosa

- `perfiles`: un registro por usuario con su `plan` (free/pro), su `rol` (usuario/admin) y, opcional, `pro_hasta` (caducidad del PRO).
- `pasos_pro`: el «Cómo aplicarlo» de las tácticas PRO. Ya no está en el código de la web: solo lo descarga quien tiene PRO o es admin. Lo garantiza la base de datos (Row Level Security), no la página.
- Nadie puede darse PRO a sí mismo: solo un admin puede cambiar el plan o el rol.

## Usuario de prueba

Authentication → Users → Add user → Create new user, con «Auto Confirm User» marcado. Luego, en `/admin`, ponle PRO.

## Cuando llegue el cobro

Stripe avisará a Supabase (webhook) y pondrá `plan = 'pro'` automáticamente. La estructura ya está preparada para eso.
