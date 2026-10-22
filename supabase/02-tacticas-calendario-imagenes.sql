-- ============================================================
-- Un Estudio Demuestra · 2/3 · tácticas con calendario, «Cómo aplicarlo» (PRO) e imágenes
-- Ejecutar después de 01-usuarios.sql. Se puede ejecutar más de una vez.
-- ============================================================

-- 1) Tácticas: contenido público + estado de publicación
create table if not exists public.tacticas (
  id                text primary key check (id ~ '^t[0-9]{2,3}$'),
  numero            int  not null unique,
  titulo            text not null,
  categoria         text not null default 'ecommerce/imagenes',
  tema              text not null,
  estudio_principal text not null,
  estado            text not null default 'idea'
                    check (estado in ('idea','preparacion','video_listo','programada','publicada')),
  fecha_publicacion timestamptz,
  url_reel          text,
  contenido         jsonb not null default '{}'::jsonb,
  creado_en         timestamptz not null default now(),
  actualizado_en    timestamptz not null default now()
);
-- Dos tácticas no pueden tener el mismo título
create unique index if not exists tacticas_titulo_unico on public.tacticas (lower(titulo));

create or replace function public.tocar_actualizado()
returns trigger language plpgsql set search_path = public as $$
begin new.actualizado_en = now(); return new; end $$;
drop trigger if exists tacticas_actualizado on public.tacticas;
create trigger tacticas_actualizado before update on public.tacticas
  for each row execute function public.tocar_actualizado();

-- Publicada = marcada como publicada, o programada y ya ha llegado su fecha
create or replace function public.esta_publicada(p_estado text, p_fecha timestamptz)
returns boolean language sql stable set search_path = public as $$
  select p_estado = 'publicada' or (p_estado = 'programada' and p_fecha is not null and p_fecha <= now());
$$;

alter table public.tacticas enable row level security;
drop policy if exists "leer tácticas publicadas" on public.tacticas;
create policy "leer tácticas publicadas" on public.tacticas
  for select using (public.esta_publicada(estado, fecha_publicacion) or public.es_admin());
drop policy if exists "admin gestiona tácticas" on public.tacticas;
create policy "admin gestiona tácticas" on public.tacticas
  for all using (public.es_admin()) with check (public.es_admin());

-- «Próximamente»: solo el aviso (título, tema y fecha), nunca el contenido
create or replace function public.tacticas_proximas()
returns table (id text, numero int, titulo text, categoria text, tema text, fecha_publicacion timestamptz, gancho text)
language sql stable security definer set search_path = public as $$
  select id, numero, titulo, categoria, tema, fecha_publicacion, contenido->>'cover'
  from tacticas
  where estado in ('preparacion','video_listo','programada') and not esta_publicada(estado, fecha_publicacion)
  order by fecha_publicacion nulls last, numero;
$$;
grant execute on function public.tacticas_proximas() to anon, authenticated;

-- 2) «Cómo aplicarlo» (PRO): solo de tácticas ya publicadas
create table if not exists public.pasos_pro (
  tactica   text    not null references public.tacticas(id) on delete cascade,
  orden     int     not null,
  texto     text    not null,
  formato   text    not null check (formato in ('foto','video','copy')),
  refs      int[]   not null default '{}',
  nota      text    not null default '',
  imagen    text,              -- ruta dentro del almacén privado «pro», p. ej. t01/paso-1.jpg
  primary key (tactica, orden)
);
alter table public.pasos_pro enable row level security;
drop policy if exists "solo PRO lee pasos" on public.pasos_pro;
create policy "solo PRO lee pasos" on public.pasos_pro
  for select using (
    public.es_admin() or (public.tiene_pro() and exists (
      select 1 from public.tacticas t where t.id = tactica and public.esta_publicada(t.estado, t.fecha_publicacion)))
  );
drop policy if exists "admin gestiona pasos" on public.pasos_pro;
create policy "admin gestiona pasos" on public.pasos_pro
  for all using (public.es_admin()) with check (public.es_admin());

-- 3) Imágenes: «publico» (portadas y figuras) y «pro» (imágenes de los pasos, privado)
insert into storage.buckets (id, name, public) values ('publico', 'publico', true)
  on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('pro', 'pro', false)
  on conflict (id) do nothing;

drop policy if exists "PRO ve imágenes de pasos" on storage.objects;
create policy "PRO ve imágenes de pasos" on storage.objects
  for select to authenticated using (bucket_id = 'pro' and public.tiene_pro());
drop policy if exists "admin sube imágenes" on storage.objects;
create policy "admin sube imágenes" on storage.objects
  for insert to authenticated with check (bucket_id in ('publico','pro') and public.es_admin());
drop policy if exists "admin cambia imágenes" on storage.objects;
create policy "admin cambia imágenes" on storage.objects
  for update to authenticated using (bucket_id in ('publico','pro') and public.es_admin());
drop policy if exists "admin borra imágenes" on storage.objects;
create policy "admin borra imágenes" on storage.objects
  for delete to authenticated using (bucket_id in ('publico','pro') and public.es_admin());
