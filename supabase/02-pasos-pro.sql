-- Pasos de las tácticas PRO. Pegar en SQL Editor → Run (después de 01-esquema.sql).
-- Se puede volver a ejecutar: actualiza los textos.
insert into public.pasos_pro (tactica, orden, texto, formato, refs, nota, imagen) values
('t05', 1, 'Añade a la galería una imagen con el producto separado en capas.', 'foto', '{1}', 'Frente a la imagen normal, la imagen por capas aumentó la valoración del producto en varios experimentos.', null),
('t05', 2, 'Deja aire entre capas y respeta el orden real, para que se pueda montar con la vista.', 'foto', '{1}', 'El efecto viene de reconstruir mentalmente el producto a partir de sus partes.', null),
('t05', 3, 'Acompaña cada capa con un texto concreto: material, medida, función. «Espuma de 8 mm», no «máximo confort».', 'copy', '{2}', 'La vista despiezada mejoró la comprensión y la intención de compra con descripciones concretas. Con descripciones abstractas, funcionó mejor la foto normal.', null),
('t06', 1, 'Si el peso es una virtud (snacks, chocolate, comida que llena), coloca el producto abajo o a la derecha.', 'foto', '{1}', 'Con snacks, los envases con la imagen en posición pesada se evaluaron mejor.', null),
('t06', 2, 'Si el peso es un defecto (electrónica, accesorios de viaje), colócalo arriba o a la izquierda.', 'foto', '{1}', 'En productos no alimentarios donde el peso perjudica, se prefirieron las posiciones ligeras.', null),
('t06', 3, 'Busca el contraste con la competencia: el efecto aparece cuando tu envase se diferencia de los que tiene al lado.', 'foto', '{1}', 'El efecto apareció cuando el envase contrastaba con los de su alrededor y desapareció cuando era igual que ellos.', null),
('t06', 4, 'Si vendes una versión saludable junto a otra que no lo es, ponla a la izquierda.', 'foto', '{2}', 'Colocar lo sano a la izquierda hace que se procese con más facilidad, refuerza el autocontrol y aumenta la elección saludable.', null),
('t07', 1, 'Si vendes potencia o eficacia (limpieza, desinfección), sube la saturación del envase y de la imagen.', 'foto', '{1}', 'Los colores saturados hicieron que los productos se percibieran más potentes y eficaces.', null),
('t07', 2, 'Si vendes algo natural, sostenible o duradero, baja la saturación.', 'foto', '{2}', 'En cinco experimentos, los colores poco saturados aumentaron la percepción de sostenibilidad, la intención de compra y la disposición a pagar más.', null),
('t07', 3, 'Si el color dice «potente», que el texto diga cuánto usar.', 'copy', '{1}', 'Percibir más potencia puede llevar a usar menos producto del necesario. Los autores recomiendan instrucciones de uso claras.', null)
on conflict (tactica, orden) do update set texto = excluded.texto, formato = excluded.formato, refs = excluded.refs, nota = excluded.nota, imagen = excluded.imagen;
