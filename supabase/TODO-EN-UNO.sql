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

-- Las funciones de los disparadores no se pueden llamar desde la API
revoke execute on function public.crear_perfil() from public, anon, authenticated;
revoke execute on function public.proteger_perfil() from public, anon, authenticated;
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
-- Un Estudio Demuestra · 3/3 · contenido de las tácticas y su «Cómo aplicarlo»
-- Se puede volver a ejecutar: actualiza textos, pero NO toca el estado ni la fecha de publicación.
insert into public.tacticas (id, numero, titulo, categoria, tema, estudio_principal, estado, fecha_publicacion, contenido) values
('t01', 1, 'Sugiere a las personas, no las muestres', 'ecommerce/imagenes', 'Personas', 'Lu, Jung & Peck (2024)', 'preparacion', null, '{"n":1,"ev":"md","sesgo":"Propiedad psicológica","cover":"El rastro, <i class=\"m\">no la persona</i>","by":["Lu, Jung & Peck","2024","Journal of Consumer Research"],"quote":"Una persona en la foto puede hacer que el producto parezca de otro. Una pista de que alguien lo usa, como una mano o una taza a medio beber, aporta calidez sin ese efecto.","cap":"Mismo producto, dos fotos: la persona compite con el producto; el rastro de uso lo hace deseable sin robar atención.","why":[["Lo que parece de otro, lo queremos menos","Cuando una foto de un viaje o de un lugar especial sale con otra persona, gusta menos que la misma foto vacía. El motivo: el sitio parece «suyo», no tuyo. Los autores lo vieron en 14.725 fotos de Instagram y en cinco experimentos.",[3]],["Las huellas ajenas restan valor","En productos de segunda mano, las señales visibles del dueño anterior bajan la valoración. Pasa en el laboratorio y también en ventas reales de eBay. Y si otros compradores ya han tocado un producto, también se valora peor: da cierto rechazo.",[1,2]],["Pero la presencia humana también suma","En fotos de producto para redes sociales, la sensación de que hay alguien detrás mejoró las emociones y la utilidad percibida de la foto. Y con ellas subió la intención de compra.",[4]]],"mejor":[["Productos ligados a la identidad: experiencias, viajes y objetos que dicen quién eres.",[3]],["Productos de segunda mano o reacondicionados.",[2]]],"ojo":[["En moda la persona ayuda, no resta.",[5]],["No quites toda presencia humana: sin nadie, la foto también pierde emoción.",[4]],["Ningún estudio comparó directamente «sugerir» frente a «mostrar». La táctica une varios hallazgos.",[]]],"ex":"Una batidora junto a fruta recién cortada y un vaso a medio llenar: alguien la está usando, pero no hay nadie que se la quede.","evtxt":"Cada pieza está bien estudiada. La combinación es nuestra: ningún estudio la probó tal cual.","src":[["Argo, J. J., Dahl, D. W. & Morales, A. C. (2006). Consumer contamination: How consumers react to products touched by others. Journal of Marketing, 70(2), 81–94.","10.1509/jmkg.70.2.081"],["Kim, J. (2017). The ownership distance effect: The impact of traces left by previous owners on the evaluation of used goods. Marketing Letters, 28(4), 591–605.","10.1007/s11002-017-9432-7"],["Lu, Z. Y., Jung, S. & Peck, J. (2024). It looks like \"theirs\": When and why human presence in the photo lowers viewers'' liking and preference for an experience venue. Journal of Consumer Research, 51(2), 321–341.",null],["Poirier, S.-M., Cosby, S., Sénécal, S., Coursaris, C. K., Fredette, M. & Léger, P.-M. (2024). The impact of social presence cues in social media product photos on consumers'' purchase intentions. Journal of Business Research, 185, 114932.","10.1016/j.jbusres.2024.114932"],["Bagatini, F. Z., Rech, E., Pacheco, N. A. & Nicolao, L. (2023). Can you imagine yourself wearing this product? Embodied mental simulation and attractiveness in e-commerce product pictures. Journal of Research in Interactive Marketing, 17(3), 470–490.","10.1108/JRIM-11-2021-0280"]],"fmts":["foto","foto","foto","foto"],"img":"ill:t01","cap2":null,"img2":null}'::jsonb),
('t02', 2, 'Ordena la galería: el producto solo y, justo después, en uso', 'ecommerce/imagenes', 'Composición', 'Lee, Shin & Kincade (2024)', 'preparacion', null, '{"n":2,"ev":"md","sesgo":"Simulación mental","cover":"Primero <i class=\"m\">solo</i>, luego en uso","by":["Lee, Shin & Kincade","2024","Journal of Product & Brand Management"],"quote":"La foto que te ayuda a imaginarte usando el producto es la que empuja la compra. Y el lugar que ocupa en la galería cambia cuánto ayuda.","cap":"Primero la foto limpia, que facilita comparar; después la foto en uso, que ayuda a imaginarse con el producto.","why":[["Comprar en dos tiempos","Primero comparamos opciones y después decidimos. En un estudio con camisetas, la foto que más ayudaba a imaginarse con el producto cambiaba según la fase. Para comparar, los autores recomiendan maniquí. Para decidir en la ficha, modelo.",[2]],["Imaginarse es medio comprar","Cuanto más se imaginaban los participantes usando la prenda, más intención de compra tenían. Pasó en los dos estudios.",[1]],["El orden cambia lo que pesa","Con solo dos fotos, la del modelo funcionó mejor después de la del producto solo: pesa más lo último que ves. En una galería de cinco, funcionó mejor al principio: pesa más lo primero.",[1]]],"mejor":[["Ropa y productos que se llevan puestos: con ellos se hicieron los estudios.",[1,2]],["Productos que a primera vista no enamoran: ahí la foto con modelo ayuda más.",[2]]],"ojo":[["Los dos estudios usaron ropa. En otras categorías está por confirmar.",[]],["Amazon exige fondo blanco en la imagen principal: la foto en uso va en la galería.",[]]],"ex":"Camiseta sobre fondo blanco como principal. Segunda foto: la misma camiseta puesta, paseando por la calle. Después, los detalles: tejido, costuras, etiqueta.","evtxt":"Estudios recientes y coherentes entre sí, pero hechos con ropa.","src":[["Lee, J. E., Shin, E. & Kincade, D. H. (2024). Presentation-order effect of product images on consumers'' mental imagery processing and purchase intentions. Journal of Product & Brand Management, 33(5), 604–617.",null],["Bagatini, F. Z., Rech, E., Pacheco, N. A. & Nicolao, L. (2023). Can you imagine yourself wearing this product? Embodied mental simulation and attractiveness in e-commerce product pictures. Journal of Research in Interactive Marketing, 17(3), 470–490.","10.1108/JRIM-11-2021-0280"]],"fmts":["foto","foto","foto","foto"],"img":"ill:t02","cap2":null,"img2":null}'::jsonb),
('t05', 3, 'Enseña las capas del producto por dentro', 'ecommerce/imagenes', 'Composición', 'Kang, Kim & Lakshmanan (2024)', 'preparacion', null, '{"n":3,"ev":"hi","sesgo":"Montaje mental","cover":"Enseña las <i class=\"m\">capas</i>","by":["Kang, Kim & Lakshmanan","2024","Journal of Marketing"],"quote":"Enseñar el producto despiezado, con sus capas separadas, hace que valga más para el cliente: al montarlo con la vista, confía más en que funcionará.","cap":"Con las capas separadas, el cliente monta el producto con la vista y entiende por qué funciona.","why":[["Lo montamos con la vista","Al ver las piezas separadas, las juntamos mentalmente y formamos una imagen completa del producto.",[1]],["Montarlo da confianza","Ese montaje mental aumenta la confianza en que el producto rinde bien. Esa confianza sube lo que vale para el cliente.",[1]],["Funciona fuera del laboratorio","En dos experimentos de campo, en venta entre particulares y en anuncios en redes, las imágenes despiezadas generaron más interacción.",[1]]],"mejor":[["Productos que se compran por lo que hacen, más que por placer.",[1]],["Anuncios en redes y marketplaces.",[1]]],"ojo":[["Si la compra es por placer, el efecto se debilita.",[1]],["Con clientes a los que la tecnología les genera ansiedad, también se debilita.",[1]],["Demasiadas piezas pueden abrumar.",[2]]],"ex":"Una zapatilla con la suela, la amortiguación y la plantilla separadas en vertical. Junto a cada capa: «goma antideslizante», «espuma de 8 mm», «plantilla extraíble».","evtxt":"Nueve experimentos en el trabajo principal, dos de ellos de campo, y un segundo estudio que lo matiza.","src":[["Kang, S. Y., Kim, J. & Lakshmanan, A. (2024). Anatomical depiction: How showing a product''s inner structure shapes product valuations. Journal of Marketing.",null],["Cheng, P. & Zhang, C. (2023). Show me insides: Investigating the influences of product exploded view on consumers'' mental imagery, comprehension, attitude, and purchase intention. Journal of Retailing and Consumer Services, 70, 103168.",null]],"fmts":["foto","foto","copy"],"img":"ill:t05","cap2":null,"img2":null}'::jsonb),
('t06', 4, 'Coloca la imagen abajo a la derecha para dar peso', 'ecommerce/imagenes', 'Composición', 'Deng & Kahn (2009)', 'preparacion', null, '{"n":4,"ev":"hi","sesgo":"Peso visual","cover":"Abajo a la derecha <i class=\"m\">pesa más</i>","by":["Deng & Kahn","2009","Journal of Marketing Research"],"quote":"En un envase, la imagen del producto colocada abajo o a la derecha lo hace parecer más pesado. Si el peso es una virtud, suma. Si no, resta.","cap":"La misma tableta: con la onza arriba a la izquierda parece ligera; abajo a la derecha, contundente.","why":[["Lo pesado cae","Abajo, a la derecha y abajo a la derecha son posiciones «pesadas». Arriba, a la izquierda y arriba a la izquierda, «ligeras». Los participantes juzgaron más pesadas las imágenes situadas en las posiciones pesadas.",[1]],["El peso es bueno o malo según el producto","En snacks, donde el peso sugiere más cantidad o más sabor, se prefirieron los envases con la imagen en posición pesada. En productos donde el peso estorba, como una bombilla o una webcam, se prefirieron las posiciones ligeras.",[1]],["Izquierda sana, derecha no","Colocar la opción saludable a la izquierda de la no saludable aumentó las elecciones sanas en siete estudios. Encaja con cómo ordenamos mentalmente la comida.",[2]]],"mejor":[["Envases y lineales donde tu producto compite al lado de otros.",[1]],["Menús y surtidos con opciones sanas y menos sanas.",[2]]],"ojo":[["Si el cliente tiene en mente cuidarse, la preferencia por lo pesado se debilita.",[1]],["Si todos los envases de alrededor hacen lo mismo, el efecto desaparece.",[1]],["Se estudió en envases: llevarlo a la foto de producto es una extrapolación.",[]]],"ex":"Una tableta de chocolate intenso con la onza dibujada abajo a la derecha. Su versión sin azúcar, en la misma página, colocada a la izquierda.","evtxt":"Un efecto clásico, con muchos experimentos y estudios relacionados posteriores.","src":[["Deng, X. & Kahn, B. E. (2009). Is your product on the right side? The \"location effect\" on perceived product heaviness and package evaluation. Journal of Marketing Research, 46(6), 725–738.","10.1509/jmkr.46.6.725"],["Romero, M. & Biswas, D. (2016). Healthy-left, unhealthy-right: Can displaying healthy items to the left (versus right) of unhealthy items nudge healthier choices? Journal of Consumer Research, 43(1), 103–112.",null]],"fmts":["foto","foto","foto","foto"],"img":"ill:t06","cap2":null,"img2":null}'::jsonb),
('t03', 5, 'Fotografía el producto desde un poco más abajo', 'ecommerce/imagenes', 'Encuadre', 'Xuan, Chen, Lin & Huang (2024)', 'preparacion', null, '{"n":5,"ev":"md","sesgo":"Verticalidad","cover":"Desde abajo, <i class=\"m\">superior</i>","by":["Xuan, Chen, Lin & Huang","2024","Journal of Advertising"],"quote":"Visto desde abajo, un producto parece superior y más lujoso. La excepción son los productos con cara, que gustan más vistos desde arriba.","cap":"La misma bolsa de café: vista desde abajo gana presencia; vista desde arriba parece más cercana.","why":[["Arriba es mejor","Usamos el espacio como metáfora: lo que está arriba es superior. En cuatro experimentos, uno de ellos de campo, los productos fotografiados con la cámara mirando hacia arriba se valoraron mejor que con la cámara mirando hacia abajo.",[2]],["Arriba es lujo","El ángulo de cámara y la orientación vertical del fondo aumentaron la sensación de lujo del producto en tres experimentos.",[1]],["Con cara, al revés","Si el producto tiene rasgos humanos, verlo desde arriba da sensación de control sobre él, y así gusta más. Esperamos que algo «con personalidad» nos trate bien.",[2]]],"mejor":[["Cuando quieres transmitir superioridad o lujo.",[1,2]],["Con clientes de perfil dominante: en ellos el efecto fue mayor.",[1]]],"ojo":[["El efecto sobre el precio que la gente espera pagar cambió según el tipo de producto.",[1]],["En productos con cara, el efecto del ángulo apareció sobre todo en consumidores de nivel socioeconómico alto.",[2]],["Ningún estudio midió cuánto ángulo es demasiado: empieza con algo sutil.",[]]],"ex":"Un frasco de perfume con la cámara ligeramente por debajo; la mascota de una marca de cereales, fotografiada desde arriba.","evtxt":"Dos trabajos con siete experimentos en total, uno de ellos de campo.","src":[["Van Rompay, T. J. L., De Vries, P. W., Bontekoe, F. & Tanja-Dijkstra, K. (2012). Embodied product perception: Effects of verticality cues in advertising and packaging design on consumer impressions and price expectations. Psychology & Marketing, 29(12), 919–928.","10.1002/mar.20574"],["Xuan, C., Chen, R., Lin, S. & Huang, H. (2024). Looking up or down? The effects of camera angle on evaluations of anthropomorphized products in advertisements. Journal of Advertising, 53(4), 530–548.","10.1080/00913367.2023.2282998"]],"fmts":["foto","foto","foto"],"img":"ill:t03","cap2":null,"img2":null}'::jsonb),
('t04', 6, 'Haz que den ganas de tocar el producto', 'ecommerce/imagenes', 'Tacto', 'Peck & Shu (2009)', 'preparacion', null, '{"n":6,"ev":"hi","sesgo":"Propiedad por el tacto","cover":"El asa, <i class=\"m\">a la derecha</i>","by":["Peck & Shu","2009","Journal of Consumer Research"],"quote":"Tocar algo nos hace sentirlo nuestro. Online no se puede tocar, pero verlo tocar, tenerlo orientado hacia tu mano o leer cómo se siente produce un efecto parecido.","cap":"Con el asa hacia la mano dominante, el cliente se imagina cogiendo la taza sin esfuerzo.","why":[["Tocar es empezar a poseer","Basta con tocar un objeto para sentirlo más nuestro. Y para quien aún no lo tiene, imaginar que lo toca también aumenta esa sensación de propiedad.",[1]],["El cerebro ensaya el gesto","Al ver un producto orientado hacia nuestra mano dominante, simulamos mentalmente cogerlo. En cuatro estudios, esa simulación aumentó la intención de compra.",[2]],["Una mano ajena se siente propia","Ver una mano tocando el producto en una imagen, un GIF o en realidad virtual aumentó la sensación de propiedad y lo que valía el producto. Sentimos esa mano casi como nuestra.",[3]]],"mejor":[["Productos que se usan con las manos.",[2,3]],["Vídeos inmersivos que emocionan: el efecto fue mayor en quien más se activaba.",[3]]],"ojo":[["Si el producto despierta rechazo, ayudar a imaginarlo en la mano reduce la compra.",[2]],["Si la página está saturada de estímulos, el efecto de la orientación se debilita.",[2]],["Un tacto desagradable resta: el valor depende de que la experiencia sea positiva.",[1]]],"ex":"Una taza con el asa a la derecha. En el vídeo, una mano la levanta y pasa el pulgar por el esmalte. En el texto: «cerámica gruesa que mantiene el calor».","evtxt":"Línea de investigación sólida, con trabajos en las revistas de referencia y muchos experimentos.","src":[["Peck, J. & Shu, S. B. (2009). The effect of mere touch on perceived ownership. Journal of Consumer Research, 36(3), 434–447.","10.1086/598614"],["Elder, R. S. & Krishna, A. (2012). The \"visual depiction effect\" in advertising: Facilitating embodied mental simulation through product orientation. Journal of Consumer Research, 38(6), 988–1003.","10.1086/661531"],["Luangrath, A. W., Peck, J., Hedgcock, W. & Xu, Y. (2022). Observing product touch: The vicarious haptic effect in digital marketing and virtual reality. Journal of Marketing Research, 59(2), 306–326.",null],["Silva, S. C., Rocha, T. V., De Cicco, R., Galhanone, R. F. & Mattos, L. T. M. F. (2021). Need for touch and haptic imagery: An investigation in online fashion shopping. Journal of Retailing and Consumer Services, 59, 102378.","10.1016/j.jretconser.2020.102378"]],"fmts":["foto","video","video","copy"],"img":"ill:t04","cap2":null,"img2":null}'::jsonb),
('t07', 7, 'Sube la saturación para transmitir potencia', 'ecommerce/imagenes', 'Color', 'Labrecque et al. (2025)', 'preparacion', null, '{"n":7,"ev":"hi","sesgo":"Intensidad del color","cover":"Más saturado, <i class=\"m\">más potente</i>","by":["Labrecque et al.","2025","Journal of Marketing"],"quote":"Los colores muy saturados hacen que un producto parezca más fuerte y eficaz. Los apagados, más natural y sostenible.","cap":"El mismo envase: saturado transmite potencia; apagado, suavidad y origen natural.","why":[["Color intenso, producto intenso","Los envases con colores muy saturados se perciben más potentes y eficaces que los de tonos apagados. El efecto es más fuerte en limpieza y desinfección.",[1]],["Color apagado, producto natural","Los colores poco saturados hacen que un producto parezca más respetuoso con el medio ambiente: más natural, más auténtico y más duradero. Eso aumenta la confianza en la marca, la intención de compra y la disposición a pagar más.",[2]]],"mejor":[["Limpieza y desinfección.",[1]],["Productos ecológicos, naturales o duraderos (en tonos apagados).",[2]]],"ojo":[["En medicamentos, un envase muy saturado puede parecer demasiado fuerte y generar dudas.",[1]],["En productos de salud o seguridad, dosificar mal tiene consecuencias.",[1]]],"ex":"Un desinfectante en rojo intenso con «Basta con un tapón por litro» bien visible. Un detergente ecológico, en verde apagado.","evtxt":"Dos trabajos recientes y complementarios, en revistas sólidas.","src":[["Labrecque, L. I., Sohn, S., Seegebarth, B. & Ashley, C. (2025). Color me effective: The impact of color saturation on perceptions of potency and product efficacy. Journal of Marketing.",null],["Pichierri, M. & Pino, G. (2023). Less saturated, more eco-friendly: Color saturation and consumer perception of product sustainability. Psychology & Marketing, 40(9), 1830–1849.","10.1002/mar.21858"]],"fmts":["foto","foto","copy"],"img":"ill:t07","cap2":null,"img2":null}'::jsonb),
('t08', 8, 'Haz que tus fotos se puedan oler, oír y tocar', 'ecommerce/imagenes', 'Sentidos', 'Sharma & Estes (2024)', 'preparacion', null, '{"n":8,"ev":"md","sesgo":"Imaginería sensorial","cover":"Que la foto <i class=\"m\">huela</i>","by":["Sharma & Estes","2024","International Journal of Research in Marketing"],"quote":"De 957 detergentes y limpiadores con aroma, solo el 27 % enseñaba en el envase aquello a lo que huele. Y esos tenían mejor nota de los clientes: 4,66 frente a 4,46 estrellas.","cap":"Misma caja, mismo bombón. Cerrado, solo se ve. Abierto y con el relleno cayendo, casi se saborea.","why":[["El cerebro guarda sensaciones, no palabras","Tu cerebro no guarda «vino» como una palabra, sino como un paquete de sensaciones: el color, el aroma, el sonido al servirlo, el frescor en la boca. Cuando algo despierta una de ellas, se activa el resto.",[1]],["Ver es oler","Las imágenes de la fuente del aroma hacen que se imagine el olor sin olerlo. Eso mejoró la valoración y la elección del producto en siete estudios. Elegir entre dos jabones de manos dependió más de que hubiera foto de la fruta que de si olían a mandarina o a pera.",[2,3]],["Oír es sentir la potencia","Cuanto más fuerte suena un producto al funcionar, más potente parece, y más se está dispuesto a pagar por él. Funciona sobre todo cuando se muestra el producto en uso.",[4]],["Leer es tocar","En moda online, describir el tacto con palabras generó imaginación táctil, y las fotos no. En publicaciones patrocinadas, el lenguaje sensorial aumentó la interacción y la intención de compra, porque hace creíble que el influencer usa el producto.",[6,7]]],"mejor":[["Productos donde el aroma es parte de lo que compras.",[2]],["Clientes que necesitan oler o tocar antes de comprar.",[2,5]],["Vídeos que enseñan el producto en uso.",[4]]],"ojo":[["Si el aroma no importa en tu producto, la imagen no aporta.",[2]],["En ambientadores y desodorantes, no enseñes el mal olor: resta.",[2]],["El sonido ayudó con cuchillos, pero no con jerséis.",[5]],["Las 11.000 interacciones son de TikTok, donde la media por vídeo es enorme. No esperes lo mismo en otras redes.",[7]]],"ex":"Una vela de canela con un puñado de canela junto al tarro. En el texto, «canela recién molida» en lugar de «aroma a canela».","evtxt":"Varios estudios recientes apuntan en la misma dirección, y la base teórica sobre cómo guarda el cerebro los conceptos es sólida.","src":[["Barsalou, L. W. (1999). Perceptual symbol systems. Behavioral and Brain Sciences, 22(4), 577–660.","10.1017/S0140525X99002149"],["Sharma, V. & Estes, Z. (2024). Seeing is smelling: Pictures improve product evaluations by evoking olfactory imagery. International Journal of Research in Marketing, 41(2), 282–307.","10.1016/j.ijresmar.2024.02.001"],["Lyu, M. & Huang, Q. (2024). Visual elements in advertising enhance odor perception and purchase intention: The role of mental imagery in multi-sensory marketing. Journal of Retailing and Consumer Services, 78, 103752.","10.1016/j.jretconser.2024.103752"],["Ringler, C., Sirianni, N. J. & Christenson, B. (2021). The power of consequential product sounds. Journal of Retailing, 97(2), 288–300.","10.1016/j.jretai.2020.09.002"],["Løkke-Andersen, C. B., Wang, Q. J. & Giacalone, D. (2022). User experience design approaches for accommodating high \"need for touch\" consumers in ecommerce. Journal of Sensory Studies, 37(2), e12727.","10.1111/joss.12727"],["Silva, S. C., Rocha, T. V., De Cicco, R., Galhanone, R. F. & Mattos, L. T. M. F. (2021). Need for touch and haptic imagery: An investigation in online fashion shopping. Journal of Retailing and Consumer Services, 59, 102378.","10.1016/j.jretconser.2020.102378"],["Cascio Rizzo, G. L., Berger, J., De Angelis, M. & Pozharliev, R. (2023). How sensory language shapes influencer''s impact. Journal of Consumer Research, 50(4), 810–825.","10.1093/jcr/ucad017"]],"fmts":["foto","foto","video","copy"],"img":"img/t08-portada.jpg","cap2":"Misma vela, mismo aroma. Con la canela a la vista, el cliente ya sabe a qué va a oler.","img2":"img/t08-canela.jpg","imgAlt":"Caja de bombones con un bombón entero frente al mismo bombón abierto con el relleno cayendo","img2Alt":"Vela de canela con canela en rama frente a la misma vela con canela molida y la etiqueta aroma más intenso"}'::jsonb)
on conflict (id) do update set numero = excluded.numero, titulo = excluded.titulo, categoria = excluded.categoria, tema = excluded.tema,
  estudio_principal = excluded.estudio_principal, contenido = excluded.contenido;

insert into public.pasos_pro (tactica, orden, texto, formato, refs, nota, imagen) values
('t01', 1, 'Fotografía el producto con huellas de uso que no tengan dueño: una taza a medio beber, una manta medio doblada, fruta recién cortada junto a la batidora.', 'foto', '{4}', 'Probaron fotos con una persona, con presencia insinuada y sin nadie. Cuanta más presencia social transmitía la foto, mejores emociones y más útil parecía para decidir. Y eso subía la intención de compra.', null),
('t01', 2, 'Si sale alguien, que no robe el foco: mejor una mano o un gesto que una cara reconocible.', 'foto', '{3}', 'El efecto «parece suyo» fue más fuerte cuando la persona de la foto era más llamativa o distintiva.', null),
('t01', 3, 'Evita cualquier señal de manoseo: envases abiertos sin motivo, arrugas, huellas.', 'foto', '{1,2}', 'Las señales de que otros han tocado o usado el producto bajan su valoración.', null),
('t01', 4, 'En moda, enseña a la persona. El cliente necesita imaginarse con la prenda puesta.', 'foto', '{5}', 'Con camisetas, la foto con modelo fue la que más ayudaba a imaginarse llevándola en la fase de decidir la compra.', null),
('t02', 1, 'Imagen principal: el producto solo, limpio. Es la que mejor sirve para comparar, y en Amazon además es obligatoria.', 'foto', '{2}', 'Para la fase de comparar entre opciones, los autores recomiendan imágenes sin persona, como el maniquí.', null),
('t02', 2, 'Si solo tienes dos fotos, la de uso va la segunda.', 'foto', '{1}', 'Con una imagen de cada tipo, la foto con modelo y fondo generó más imaginación cuando iba después de la del producto solo.', null),
('t02', 3, 'Si tienes una galería larga, pon las fotos en uso al principio y los detalles después.', 'foto', '{1}', 'En una serie de cinco imágenes, empezar por las fotos con modelo y fondo generó más imaginación que dejarlas para el final. Y más imaginación se tradujo en más intención de compra.', null),
('t02', 4, 'En la ficha de producto, donde se decide, usa fotos con modelo. En listados y categorías, el producto solo.', 'foto', '{2}', 'Los autores proponen maniquí para evaluar, por ejemplo en páginas de categoría, y modelo para la consideración profunda, en la ficha.', null),
('t05', 1, 'Añade a la galería una imagen con el producto separado en capas.', 'foto', '{1}', 'Frente a la imagen normal, la imagen por capas aumentó la valoración del producto en varios experimentos.', null),
('t05', 2, 'Deja aire entre capas y respeta el orden real, para que se pueda montar con la vista.', 'foto', '{1}', 'El efecto viene de reconstruir mentalmente el producto a partir de sus partes.', null),
('t05', 3, 'Acompaña cada capa con un texto concreto: material, medida, función. «Espuma de 8 mm», no «máximo confort».', 'copy', '{2}', 'La vista despiezada mejoró la comprensión y la intención de compra con descripciones concretas. Con descripciones abstractas, funcionó mejor la foto normal.', null),
('t06', 1, 'Si el peso es una virtud (snacks, chocolate, comida que llena), coloca el producto abajo o a la derecha.', 'foto', '{1}', 'Con snacks, los envases con la imagen en posición pesada se evaluaron mejor.', null),
('t06', 2, 'Si el peso es un defecto (electrónica, accesorios de viaje), colócalo arriba o a la izquierda.', 'foto', '{1}', 'En productos no alimentarios donde el peso perjudica, se prefirieron las posiciones ligeras.', null),
('t06', 3, 'Busca el contraste con la competencia: el efecto aparece cuando tu envase se diferencia de los que tiene al lado.', 'foto', '{1}', 'El efecto apareció cuando el envase contrastaba con los de su alrededor y desapareció cuando era igual que ellos.', null),
('t06', 4, 'Si vendes una versión saludable junto a otra que no lo es, ponla a la izquierda.', 'foto', '{2}', 'Colocar lo sano a la izquierda hace que se procese con más facilidad, refuerza el autocontrol y aumenta la elección saludable.', null),
('t03', 1, 'Baja la cámara: que el objetivo mire ligeramente hacia arriba al producto.', 'foto', '{2}', 'En productos sin rasgos humanos, los ángulos que miran hacia arriba se asociaron con superioridad y dieron mejores valoraciones.', null),
('t03', 2, 'Si vendes gama alta, refuerza la verticalidad: ángulo bajo y composición vertical.', 'foto', '{1}', 'El ángulo de cámara y un fondo de orientación vertical aumentaron la percepción de lujo.', null),
('t03', 3, 'Si tu producto tiene cara o personalidad (una mascota, un robot, un envase con ojos), hazlo al revés: desde arriba.', 'foto', '{2}', 'Con productos antropomorfizados, el ángulo desde arriba dio sensación de dominio y mejores valoraciones que el ángulo desde abajo.', null),
('t04', 1, 'Orienta asas y mangos hacia la derecha: la mayoría somos diestros.', 'foto', '{2}', 'Orientar el producto hacia la mano dominante de quien mira aumentó la intención de compra.', null),
('t04', 2, 'Enseña una mano tocando el producto, no solo cerca de él. Mejor en vídeo o GIF.', 'video', '{3}', 'En ocho estudios, que apareciera una mano no bastaba: tenía que estar tocando el producto.', null),
('t04', 3, 'Que el gesto enseñe algo: apretar para ver lo blando que es, levantarlo para ver lo que pesa, pasar el dedo por la textura.', 'video', '{3}', 'El efecto se debilitó cuando el movimiento de la mano no revelaba información del producto, como su textura o su peso.', null),
('t04', 4, 'Describe con palabras cómo se siente: «algodón grueso que no transparenta», «mango de goma que no resbala».', 'copy', '{4}', 'En moda online, las descripciones del tacto generaron imaginación táctil, y las fotos no. Esa imaginación mejoró la calidad percibida y la intención de compra.', null),
('t07', 1, 'Si vendes potencia o eficacia (limpieza, desinfección), sube la saturación del envase y de la imagen.', 'foto', '{1}', 'Los colores saturados hicieron que los productos se percibieran más potentes y eficaces.', null),
('t07', 2, 'Si vendes algo natural, sostenible o duradero, baja la saturación.', 'foto', '{2}', 'En cinco experimentos, los colores poco saturados aumentaron la percepción de sostenibilidad, la intención de compra y la disposición a pagar más.', null),
('t07', 3, 'Si el color dice «potente», que el texto diga cuánto usar.', 'copy', '{1}', 'Percibir más potencia puede llevar a usar menos producto del necesario. Los autores recomiendan instrucciones de uso claras.', null),
('t08', 1, 'Enseña de dónde sale el aroma: el limón junto al limpiador, la lavanda junto al ambientador.', 'foto', '{2}', 'Solo el 27 % de 957 detergentes y limpiadores con aroma enseñaba la fuente del olor, y esos tenían mejor valoración. En los experimentos, la foto de la fuente mejoró la evaluación y la elección.', null),
('t08', 2, 'Elige una fuente que huela de verdad: una rosa evoca más aroma que un girasol.', 'foto', '{2,3}', 'Las imágenes de rosas puntuaron mejor que las de girasoles, que apenas huelen. Los elementos visuales que evocan imágenes mentales aumentan lo agradable que parece el olor y la intención de compra.', null),
('t08', 3, 'Graba vídeo con el sonido real del producto funcionando: la batidora, el cuchillo.', 'video', '{4,5}', 'Los sonidos más fuertes hicieron percibir más potencia y aumentaron la disposición a pagar. En vídeos de cuchillos, el sonido natural mejoró la experiencia de quienes necesitan tocar antes de comprar.', null),
('t08', 4, 'Escribe con palabras que se sienten: crujiente, jugoso, recién hecho, suave.', 'copy', '{6,7}', 'En TikTok, cada palabra sensorial de más se asoció con unas 11.000 interacciones más (likes y comentarios); en Instagram, con unas 49. Y las descripciones del tacto generaron imaginación táctil que las fotos no lograron.', null)
on conflict (tactica, orden) do update set texto = excluded.texto, formato = excluded.formato, refs = excluded.refs, nota = excluded.nota;
