-- 05 · Lista de espera de la biblioteca
-- Guarda los emails que se apuntan desde la landing. Nadie puede leerlos salvo un admin.
-- Las altas solo entran por la función unirse_lista(), que valida el email y no revela si ya estaba.

create table if not exists public.lista_espera (
  id bigint generated always as identity primary key,
  email text not null check (char_length(email) between 5 and 254),
  interes text check (interes is null or char_length(interes) <= 60),
  origen text check (origen is null or char_length(origen) <= 120),
  creado timestamptz not null default now()
);
create unique index if not exists lista_espera_email_uk on public.lista_espera (lower(email));

alter table public.lista_espera enable row level security;
revoke all on public.lista_espera from anon, authenticated;
grant select, delete on public.lista_espera to authenticated;

drop policy if exists "admin lee lista" on public.lista_espera;
create policy "admin lee lista" on public.lista_espera for select to authenticated using (public.es_admin());
drop policy if exists "admin borra lista" on public.lista_espera;
create policy "admin borra lista" on public.lista_espera for delete to authenticated using (public.es_admin());

-- Alta. Devuelve cuántos sois en la lista (para «eres el nº…»). Mismo resultado si el email ya estaba.
create or replace function public.unirse_lista(p_email text, p_interes text default null, p_origen text default null)
returns integer language plpgsql security definer set search_path = public as $$
declare v text := lower(trim(coalesce(p_email, '')));
begin
  if char_length(v) > 254 or v !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then
    raise exception 'email_invalido';
  end if;
  insert into public.lista_espera (email, interes, origen)
  values (v, left(nullif(trim(p_interes), ''), 60), left(nullif(trim(p_origen), ''), 120))
  on conflict ((lower(email))) do nothing;
  return (select count(*) from public.lista_espera);
end $$;

-- Segundo paso opcional tras apuntarse: qué quiere mejorar primero (solo en la primera hora y si estaba vacío).
create or replace function public.lista_interes(p_email text, p_interes text)
returns void language sql security definer set search_path = public as $$
  update public.lista_espera set interes = left(nullif(trim(p_interes), ''), 60)
  where lower(email) = lower(trim(p_email)) and interes is null and creado > now() - interval '1 hour';
$$;

-- Total público (solo el número), para mostrarlo en la landing cuando ya sea alto.
create or replace function public.lista_espera_total()
returns integer language sql stable security definer set search_path = public as $$
  select count(*)::int from public.lista_espera;
$$;

revoke all on function public.unirse_lista(text, text, text) from public;
revoke all on function public.lista_interes(text, text) from public;
revoke all on function public.lista_espera_total() from public;
grant execute on function public.unirse_lista(text, text, text) to anon, authenticated;
grant execute on function public.lista_interes(text, text) to anon, authenticated;
grant execute on function public.lista_espera_total() to anon, authenticated;
