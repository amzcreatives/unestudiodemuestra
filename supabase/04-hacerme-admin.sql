-- Ejecutar DESPUÉS de haberte registrado en la web con tu email.
-- Te convierte en administrador (y con acceso PRO).
update public.perfiles set rol = 'admin', plan = 'pro'
where email = 'clientes@amzcreatives.es';

-- Comprobar:
select email, plan, rol from public.perfiles order by creado_en;
