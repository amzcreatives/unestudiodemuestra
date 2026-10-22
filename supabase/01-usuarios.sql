-- ============================================================
-- Un Estudio Demuestra · 1/3 · usuarios, planes y roles
-- Pegar entero en Supabase → SQL Editor → Run. Se puede ejecutar más de una vez.
-- ============================================================

-- 1) Perfiles: uno por usuario, con su plan y su rol
create table if not exists public.perfiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  plan        text not null default 'free'    check (plan in ('free','pro')),
  rol         text not null default 'usuario' check (rol  in ('usuario','admin')),
  creado_en   timestamptz not null default now(),
  pro_hasta   timestamptz            -- opcional: fecha de caducidad del PRO (null = sin caducidad)
);

-- Cada vez que alguien se registra, se crea su perfil (free, usuario)
create or replace function public.crear_perfil()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.perfiles (id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists al_registrarse on auth.users;
create trigger al_registrarse after insert on auth.users
  for each row execute function public.crear_perfil();

-- Funciones de ayuda (security definer para no chocar con las propias reglas)
create or replace function public.es_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from perfiles where id = auth.uid() and rol = 'admin');
$$;

create or replace function public.tiene_pro()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from perfiles
    where id = auth.uid()
      and (rol = 'admin' or (plan = 'pro' and (pro_hasta is null or pro_hasta > now())))
  );
$$;

-- Nadie puede cambiarse a sí mismo el plan o el rol: solo un admin
create or replace function public.proteger_perfil()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (new.plan is distinct from old.plan or new.rol is distinct from old.rol or new.pro_hasta is distinct from old.pro_hasta)
     and coalesce(auth.role(), '') in ('authenticated', 'anon') and not public.es_admin() then
    raise exception 'Solo un administrador puede cambiar el plan o el rol';
  end if;
  return new;
end $$;

drop trigger if exists proteger_perfil on public.perfiles;
create trigger proteger_perfil before update on public.perfiles
  for each row execute function public.proteger_perfil();

alter table public.perfiles enable row level security;

drop policy if exists "ver mi perfil o todos si admin" on public.perfiles;
create policy "ver mi perfil o todos si admin" on public.perfiles
  for select using (id = auth.uid() or public.es_admin());

drop policy if exists "admin edita perfiles" on public.perfiles;
create policy "admin edita perfiles" on public.perfiles
  for update using (public.es_admin()) with check (public.es_admin());

-- Perfiles de usuarios que ya existieran antes de crear la tabla
insert into public.perfiles (id, email)
select id, email from auth.users on conflict (id) do nothing;
