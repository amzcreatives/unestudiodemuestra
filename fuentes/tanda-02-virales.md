# Tanda 2 · 10 tácticas virales

Las 10 tácticas elegidas para los vídeos de Instagram y TikTok que llevan a la lista de espera. Para cada una: de qué táctica de Nick Kolenda sale, qué estudio la respalda (comprobado por nosotros), qué demuestra de verdad, el gancho del vídeo y qué **no** decir.

Comprobado el 2026-10-24 contra el resumen publicado de cada estudio. Las cifras finas (tamaños de efecto, porcentajes exactos) hay que sacarlas del texto completo antes de escribir la ficha larga de la web.

**Regla de la casa:** si el estudio no lo dice, no lo ponemos. Los textos se escriben de cero: no se traduce ni se copia a Kolenda.

## Cómo usar este archivo con Claude Code

**Para la web (ficha de cada táctica):**
- Cada táctica nueva necesita su ficha con el mismo formato que las de `codigo-fuente/tactics-data.js`: `t` (título), `cat` (tema), `ev`, `sesgo`, `cover`, `by` (autores, año, revista del estudio principal), `quote` (lo que demuestra), `why` (por qué funciona, 2-3 bloques), `how` (pasos de «Cómo aplicarlo», PRO), `mejor`, `ojo`, `ex` (ejemplo), `evtxt` y `src` (citas con DOI). Cada frase de `why`, `how`, `mejor` y `ojo` lleva la referencia `[n]` del estudio que la respalda.
- En Supabase va una fila en `tacticas` (estado `idea` hasta tener vídeo) y sus pasos en `pasos_pro`. La categoría de la biblioteca está en el campo `categoria` de este archivo.
- Usa solo lo que pone «Qué demuestra» y «Qué encontró». Para todo lo demás, leer el estudio completo primero.
- La columna «Lo que cita Kolenda» es orientativa: esos estudios **no** están verificados por nosotros.

**Para el vídeo (Reel / TikTok, 9:16, 30–45 s, subtítulos siempre):**
1. Gancho (0–2 s): el de cada táctica.
2. El estudio (2–8 s): autores, año y revista en pantalla.
3. Antes / después (8–20 s): pantalla partida con ✕ y ✓.
4. Por qué funciona (20–30 s): una frase.
5. Cierre: «La táctica completa, con el estudio, en la biblioteca. Abre el 2 de noviembre, solo para la lista. Comenta ESTUDIO y te paso el enlace.»
- Identidad: tinta #141A24, papel #F6F7F4, subrayador #F4E35A. Newsreader (titulares), Public Sans (texto), JetBrains Mono (datos y citas). Mascota CiCi: kit en `diseno/cici/kit-mascota`.
- Ningún dato fuera de este archivo. Sin logos ni productos de marcas reales.

## Resumen

| # | Nº | Táctica | Gancho | Estudio principal | Viene de (Kolenda) |
|---|---|---|---|---|---|
| 1 | 009 (provisional) | Si vendes lujo, que tu modelo no sonría | ¿Por qué los modelos de lujo nunca sonríen? Un experimento con 233.000 personas lo explica. | Essiz, O., Senyuz, A. & Yurteri, S. (2025) | [Luxury Brands Should Act Cold and Distant](https://kolenda.io/tactics/luxury-brands-unfriendly) |
| 2 | 010 (provisional) | Añade una opción peor para vender la que quieres | Añade una opción que nadie va a comprar y venderás más la que tú quieres. | Huber, J., Payne, J. W. & Puto, C. (1982) | [Offer a Similar (Yet Worse) Product](https://www.kolenda.io/tactics/prices-similar-version) |
| 3 | 011 (provisional) | Cuidado con los porcentajes de más del 100 % | ¿Qué es más: 125 % más o el doble? | Fisher, M. & Mormann, M. (2022) | [125% More Feels Like 25% More](https://kolenda.io/tactics/off-by-100-percent) |
| 4 | 012 (provisional) | El precio en rojo parece más ahorro… para los hombres | Hombres: el mismo precio en rojo os parece más barato. | Puccinelli, N. M., Chandrashekaran, R., Grewal, D. & Suri, R. (2013) | [Display Red Prices to Men](https://www.kolenda.io/tactics/red-prices) |
| 5 | 013 (provisional) | Quita el símbolo de moneda de la carta | Quita el € de tu carta y tus clientes gastarán más. | Yang, S. S., Kimes, S. E. & Sessarego, M. M. (2009) | [Reduce the Size of Currency Symbols](https://kolenda.io/tactics/prices-currency-symbol) |
| 6 | 014 (provisional) | Sortea la compra en vez de descontarla | Regalar 1 de cada 10 pedidos vende más que un 10 % de descuento. | Mazar, N., Shampanier, K. & Ariely, D. (2017) | [Let Customers Win Their Discount](https://assets.ctfassets.net/sm4pjcjvw1eb/44yZ8GLMqqK5313lQ60I8l/b299ed03bff49633ab7412d4694f7f05/Pricing.pdf) |
| 7 | 015 (provisional) | Presenta el precio como un gasto diario | «Menos que un café al día»: por qué esta frase te convence. | Gourville, J. T. (1998) | [Reframe Prices Into Smaller Base Values](https://www.kolenda.io/tactics/prices-daily-equivalence) |
| 8 | 016 (provisional) | En caprichos, precio redondo; en lo práctico, precio exacto | El truco del ,99 no siempre funciona: en caprichos, el precio redondo vende más. | Wadhwa, M. & Zhang, K. (2015) | [Reduce the Left Digit By One + Use Round Prices in the Right Context](https://www.kolenda.io/tactics/charm-prices) |
| 9 | 005 (ya publicada) | Fotografía el producto desde un poco más abajo | Mueve la cámara 20 cm y tu producto parece más caro. | Van Rompay, T. J. L., De Vries, P. W., Bontekoe, F. & Tanja-Dijkstra, K. (2012) | [Choose the Best Vertical Angle for Product Images](https://www.kolenda.io/tactics/vertical-angles-products) |
| 10 | 017 (provisional) | Tras una oferta, calla tres segundos | Cuando te hagan una oferta, cuenta hasta 3 en silencio. | Curhan, J. R., Overbeck, J. R., Cho, Y., Zhang, T. & Yang, Y. (2022) | [Pause After Your Counterpart Makes an Offer](https://www.kolenda.io/tactics/pause-after-offer) |

## 1 · Si vendes lujo, que tu modelo no sonría

- **Nº en la biblioteca:** 009 (provisional) · **Tema:** Lujo · **Categoría:** `sector/lujo` · **Evidencia (propuesta):** Alta
- **Viene de Kolenda:** Luxury Brands Should Act Cold and Distant (sub-táctica «Avoid Smiling») — <https://kolenda.io/tactics/luxury-brands-unfriendly>
- **Gancho del vídeo:** «¿Por qué los modelos de lujo nunca sonríen? Un experimento con 233.000 personas lo explica.»

**Qué demuestra:** En anuncios de productos de lujo, una cara neutra consigue más interacción, más clics, mejor actitud hacia el anuncio y más compras que una sonrisa leve o amplia. La cara seria hace que la marca parezca más competente y el anuncio más creíble.

**Estudios que la respaldan (verificados):**

- *(principal)* Essiz, O., Senyuz, A. & Yurteri, S. (2025). The dark side of a big smile: Detrimental effects of smile intensity on luxury brand advertising effectiveness. Psychology & Marketing. [doi.org/10.1002/mar.22189](https://doi.org/10.1002/mar.22189)
  - Qué encontró: Seis estudios preregistrados: datos de 435 anuncios de Instagram, dos experimentos de campo en Meta (233.301 personas) y tres experimentos online (940). Cara neutra > sonrisa leve o amplia en engagement, CTR, actitud y compra, solo en lujo. Mecanismo: más competencia percibida → más credibilidad. Mejor con mirada directa.
  - Comprobado el 2026-10-24 en: https://e-space.mmu.ac.uk/638394/

**Ojo · qué no decir:**

- Solo se probó con productos de lujo; en productos normales no apliques esta regla.
- La cara neutra funcionó mejor mirando a cámara que con la mirada apartada (Kolenda recomienda lo contrario: aquí manda el estudio).
- El efecto es más débil en gente que decide más por emoción que por razón.

**Lo que cita Kolenda (sin verificar por nosotros):** Chu, Chang & Lee (2021); Li & Shin (2022); Park & Hadi (2020); Park, Im & Kim (2020); Zhu, Zhou, Wu & Wang (2022)

## 2 · Añade una opción peor para vender la que quieres

- **Nº en la biblioteca:** 010 (provisional) · **Tema:** Señuelo · **Categoría:** `precios/psicologia` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Offer a Similar (Yet Worse) Product — <https://www.kolenda.io/tactics/prices-similar-version>
- **Gancho del vídeo:** «Añade una opción que nadie va a comprar y venderás más la que tú quieres.»

**Qué demuestra:** Si añades una opción claramente peor que la que quieres vender (pero no peor que las demás), más gente elige la que quieres. Es el «efecto señuelo»: la opción mala sirve de comparación y hace brillar a la buena.

**Estudios que la respaldan (verificados):**

- *(principal)* Huber, J., Payne, J. W. & Puto, C. (1982). Adding asymmetrically dominated alternatives: Violations of regularity and the similarity hypothesis. Journal of Consumer Research, 9(1), 90–98. [doi.org/10.1086/208899](https://doi.org/10.1086/208899)
  - Qué encontró: Añadir una alternativa dominada solo por una de las opciones aumenta la elección de la opción que la domina. El señuelo casi no se elige (≈2 %). En su revisión de 2014 los autores señalan cuándo falla.
  - Comprobado el 2026-10-24 en: https://people.duke.edu/~jch8/bio/Papers/HuberPaynePutoJMR%202014.pdf

**Ojo · qué no decir:**

- No uses el ejemplo de las palomitas del cine: no sale de ningún estudio.
- Los propios autores avisan: el efecto se debilita cuando el cliente ya tiene claro lo que quiere, cuando la diferencia no se ve a simple vista o cuando el señuelo también resulta atractivo.
- Funciona mejor con opciones fáciles de comparar (precio, tamaño, cantidad).

**Lo que cita Kolenda (sin verificar por nosotros):** Rooderkerk, Van Heerde & Bijmolt (2011), Journal of Marketing Research; Ariely (2008), Predictably Irrational (libro)

## 3 · Cuidado con los porcentajes de más del 100 %

- **Nº en la biblioteca:** 011 (provisional) · **Tema:** Porcentajes · **Categoría:** `copywriting/fechas-numeros` · **Evidencia (propuesta):** Alta
- **Viene de Kolenda:** 125% More Feels Like 25% More — <https://kolenda.io/tactics/off-by-100-percent>
- **Gancho del vídeo:** «¿Qué es más: 125 % más o el doble?»

**Qué demuestra:** Muchos leen «125 % más» como «el 125 % de lo anterior», es decir, solo un 25 % más. Error: justo 100 puntos. Lo correcto es 2,25 veces, más que el doble. Pasó en seis estudios con 2.395 personas (y once complementarios con 3.249 más), también con incentivos reales.

**Estudios que la respaldan (verificados):**

- *(principal)* Fisher, M. & Mormann, M. (2022). The off by 100% bias: The effects of percentage changes greater than 100% on magnitude judgments and consumer choice. Journal of Consumer Research, 49(4), 561–573. [doi.org/10.1093/jcr/ucac006](https://doi.org/10.1093/jcr/ucac006)
  - Qué encontró: La gente subestima los aumentos de más del 100 %: lee «X % más» como «X % de». 6 estudios (2.395 participantes) + 11 complementarios (3.249). Afecta a intenciones y a elecciones con incentivos reales; se reduce si se hace visible la diferencia entre lecturas.
  - Comprobado el 2026-10-24 en: https://academic.oup.com/jcr/article/49/4/561/6519315
- *(relacionado)* Chen, H., Marmorstein, H., Tsiros, M. & Rao, A. R. (2012). When more is less: The impact of base value neglect on consumer preferences for bonus packs over price discounts. Journal of Marketing, 76(4), 64–77. [doi.org/10.1509/jm.10.0443](https://doi.org/10.1509/jm.10.0443)
  - Qué encontró: Los consumidores ignoran la base sobre la que se calcula un porcentaje. En una tienda real, un pack con producto extra vendió bastante más que un descuento económicamente equivalente.
  - Comprobado el 2026-10-24 en: https://journals.sagepub.com/doi/10.1509/jm.10.0443

**Ojo · qué no decir:**

- El sesgo baja si muestras las dos lecturas juntas: si quieres que se entienda, di «más del doble» o «2,25 veces».
- Para el vídeo: plantea la pregunta, deja que comenten y da la respuesta al final.

**Lo que cita Kolenda (sin verificar por nosotros):** Fisher & Mormann (2022) · el mismo que usamos

## 4 · El precio en rojo parece más ahorro… para los hombres

- **Nº en la biblioteca:** 012 (provisional) · **Tema:** Color del precio · **Categoría:** `precios/diseno-precio` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Display Red Prices to Men — <https://www.kolenda.io/tactics/red-prices>
- **Gancho del vídeo:** «Hombres: el mismo precio en rojo os parece más barato.»

**Qué demuestra:** Los hombres perciben más ahorro cuando el precio está en rojo que en negro, aunque sea el mismo. En las mujeres no apareció: leían el anuncio con más detenimiento y recordaban mejor el precio.

**Estudios que la respaldan (verificados):**

- *(principal)* Puccinelli, N. M., Chandrashekaran, R., Grewal, D. & Suri, R. (2013). Are men seduced by red? The effect of red versus black prices on price perceptions. Journal of Retailing, 89(2), 115–125. [doi.org/10.1016/j.jretai.2013.01.002](https://doi.org/10.1016/j.jretai.2013.01.002)
  - Qué encontró: Cuatro estudios. Hombres: más ahorro percibido con precios en rojo. Mujeres: más elaboración del anuncio y mejor recuerdo del precio. El efecto se mantiene con varios anuncios y se debilita con alta implicación.
  - Comprobado el 2026-10-24 en: https://researchportal.bath.ac.uk/en/publications/are-men-seduced-by-red-the-effect-of-red-versus-black-prices-on-p/

**Ojo · qué no decir:**

- El efecto se debilita cuando la compra importa mucho (alta implicación).
- Cuéntalo sin burla ni estereotipo: es una diferencia en cómo se procesa el anuncio, no en inteligencia.
- Kolenda cita también estudios posteriores con matices (online, y uno titulado «Red price? Red flag!»): revisarlos antes de la ficha completa.

**Lo que cita Kolenda (sin verificar por nosotros):** Hagtvedt & Brasel (2017), JCR; Puccinelli et al. (2013) · el mismo que usamos; Kim & Jang (2022), Frontiers in Psychology; Van Droogenbroeck, Van Hove & Cordemans (2018), Color Research & Application; Ye, Bhatt, Jeong, Zhang & Suri (2020), Psychology & Marketing

## 5 · Quita el símbolo de moneda de la carta

- **Nº en la biblioteca:** 013 (provisional) · **Tema:** Símbolo de moneda · **Categoría:** `precios/diseno-precio` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Reduce the Size of Currency Symbols — <https://kolenda.io/tactics/prices-currency-symbol>
- **Gancho del vídeo:** «Quita el € de tu carta y tus clientes gastarán más.»

**Qué demuestra:** En un restaurante, quienes recibieron la carta sin símbolo de moneda gastaron de media 5,55 $ más (≈8 %). Escribir el precio en palabras («veinte dólares») no ayudó: gastaron igual que con el símbolo.

**Estudios que la respaldan (verificados):**

- *(principal)* Yang, S. S., Kimes, S. E. & Sessarego, M. M. (2009). Menu price presentation influences on consumer purchase behavior in restaurants. International Journal of Hospitality Management, 28(1), 157–160. [doi.org/10.1016/j.ijhm.2008.06.012](https://doi.org/10.1016/j.ijhm.2008.06.012)
  - Qué encontró: 201 comensales con una de tres cartas al azar: con $, sin $ o en palabras. Sin símbolo gastaron 5,55 $ más de media (≈8 %); entre $ y palabras no hubo diferencia.
  - Comprobado el 2026-10-24 en: https://news.cornell.edu/node/273666

**Ojo · qué no decir:**

- Es un solo estudio, en un restaurante (201 comensales). En tienda online es una hipótesis por probar.
- La explicación que dan (recordar el dinero «duele» al pagar) es una propuesta de los autores, no algo medido.

**Lo que cita Kolenda (sin verificar por nosotros):** Coulter & Coulter (2005), Journal of Consumer Psychology; Yang, Kimes & Sessarego (2009) · el mismo que usamos

## 6 · Sortea la compra en vez de descontarla

- **Nº en la biblioteca:** 014 (provisional) · **Tema:** Promociones · **Categoría:** `precios/promociones` · **Evidencia (propuesta):** Alta
- **Viene de Kolenda:** Let Customers Win Their Discount (táctica 37 de su guía de precios; no he localizado la URL de la ficha) — <https://assets.ctfassets.net/sm4pjcjvw1eb/44yZ8GLMqqK5313lQ60I8l/b299ed03bff49633ab7412d4694f7f05/Pricing.pdf>
- **Gancho del vídeo:** «Regalar 1 de cada 10 pedidos vende más que un 10 % de descuento.»

**Qué demuestra:** Ofrecer «tienes la oportunidad de llevártelo gratis» hizo comprar a más gente, y más unidades, que un descuento seguro con el mismo coste medio para la tienda.

**Estudios que la respaldan (verificados):**

- *(principal)* Mazar, N., Shampanier, K. & Ariely, D. (2017). When retailing and Las Vegas meet: Probabilistic free price promotions. Management Science, 63(1), 250–266. [doi.org/10.1287/mnsc.2015.2328](https://doi.org/10.1287/mnsc.2015.2328)
  - Qué encontró: Seis experimentos de campo y de laboratorio. Una promoción con probabilidad de llevarse la compra gratis aumentó la compra y las unidades frente a un descuento seguro del mismo valor esperado. Mecanismo: sensibilidad decreciente al precio. Descartan el efecto «gratis», los costes de transacción y la novedad.
  - Comprobado el 2026-10-24 en: https://ideas.repec.org/a/inm/ormnsc/v63y2017i1p250-266.html

**Ojo · qué no decir:**

- Probado en compras planificadas; en compras por impulso no se sabe.
- En España un sorteo necesita bases legales: no lo plantees sin ellas.
- El «1 de cada 10» del gancho es un ejemplo con el mismo coste medio que un 10 %; no es la cifra exacta del estudio.

**Lo que cita Kolenda (sin verificar por nosotros):** No consultado: no he encontrado la ficha

## 7 · Presenta el precio como un gasto diario

- **Nº en la biblioteca:** 015 (provisional) · **Tema:** Encuadre del precio · **Categoría:** `precios/psicologia` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Reframe Prices Into Smaller Base Values — <https://www.kolenda.io/tactics/prices-daily-equivalence>
- **Gancho del vídeo:** ««Menos que un café al día»: por qué esta frase te convence.»

**Qué demuestra:** Cuando el precio se presenta en céntimos al día, el cliente lo compara con sus gastos pequeños de cada día y le parece mejor compra. Si ve el total, lo compara con gastos grandes y poco frecuentes.

**Estudios que la respaldan (verificados):**

- *(principal)* Gourville, J. T. (1998). Pennies-a-day: The effect of temporal reframing on transaction evaluation. Journal of Consumer Research, 24(4), 395–408. [doi.org/10.1086/209517](https://doi.org/10.1086/209517)
  - Qué encontró: Estudios de laboratorio en varias categorías: el encuadre «céntimos al día» aumenta la aceptación porque hace recordar gastos pequeños y continuos como comparación; el total hace recordar gastos grandes e infrecuentes.
  - Comprobado el 2026-10-24 en: https://ideas.repec.org/a/oup/jconrs/v24y1998i4p395-408.html

**Ojo · qué no decir:**

- Gourville publicó después (1999, 2003) cuándo funciona peor, por ejemplo según la cantidad. Leerlos antes de escribir la ficha completa.
- El «café» es un ejemplo nuestro; el estudio habla de gastos pequeños y recurrentes en general.

**Lo que cita Kolenda (sin verificar por nosotros):** Allard, Hardisty & Griffin (2019), JMR; Bambauer-Sachse & Grewal (2011), Journal of Retailing; Bambauer-Sachse & Mangold (2009), JRCS; Basu & Ng (2021), JCP; Chung & Sheinin (2024), Journal of Consumer Behaviour; Gourville (1998) · el mismo que usamos; Gourville (1999), Marketing Letters; Gourville (2003), Marketing Letters; Wertenbroch, Soman & Chattopadhyay (2007), JCR

## 8 · En caprichos, precio redondo; en lo práctico, precio exacto

- **Nº en la biblioteca:** 016 (provisional) · **Tema:** Precios redondos · **Categoría:** `precios/digitos` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Reduce the Left Digit By One + Use Round Prices in the Right Context — <https://www.kolenda.io/tactics/charm-prices> · <https://nickkolenda.com/tactics/round-prices>
- **Gancho del vídeo:** «El truco del ,99 no siempre funciona: en caprichos, el precio redondo vende más.»

**Qué demuestra:** El ,99 hace que un precio parezca más bajo cuando cambia el primer dígito (2,99 frente a 3,00). Pero en compras emocionales —un capricho, un regalo, unas vacaciones— vende más el precio redondo, porque «se siente bien». En compras prácticas, el no redondo.

**Estudios que la respaldan (verificados):**

- *(principal)* Wadhwa, M. & Zhang, K. (2015). This number just feels right: The impact of roundedness of price numbers on product evaluations. Journal of Consumer Research, 41(5), 1172–1185. [doi.org/10.1086/678484](https://doi.org/10.1086/678484)
  - Qué encontró: Cinco estudios. Precio redondo → más compra en compras guiadas por sentimientos (cámara para unas vacaciones); precio no redondo → más compra en compras guiadas por la razón (la misma cámara para un trabajo de clase).
  - Comprobado el 2026-10-24 en: https://eurekalert.org/news-releases/620662
- *(base)* Thomas, M. & Morwitz, V. (2005). Penny wise and pound foolish: The left-digit effect in price cognition. Journal of Consumer Research, 32(1), 54–64. [doi.org/10.1086/429600](https://doi.org/10.1086/429600)
  - Qué encontró: Cinco experimentos: los precios acabados en 9 parecen menores que uno un céntimo más alto solo cuando cambia el dígito de la izquierda (2,99 frente a 3,00).
  - Comprobado el 2026-10-24 en: https://ideas.repec.org/a/oup/jconrs/v32y2005i1p54-64.html

**Ojo · qué no decir:**

- Lo de que las terminaciones en 95 funcionan mejor en productos caros no lo he podido confirmar: no lo digas.
- El ,99 solo funciona si cambia el primer dígito (9,99 frente a 10).

**Lo que cita Kolenda (sin verificar por nosotros):** Para el ,99: Anderson & Simester (2003), Manning & Sprott (2009), Sokolova, Seenivasan & Thomas (2020), Thomas & Morwitz (2005), Troll et al. (2023, metaanálisis) y 9 más; Precios redondos: ficha no consultada

## 9 · Fotografía el producto desde un poco más abajo

- **Nº en la biblioteca:** 005 (ya publicada) · **Tema:** Encuadre · **Categoría:** `ecommerce/imagenes` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Choose the Best Vertical Angle for Product Images — <https://www.kolenda.io/tactics/vertical-angles-products>
- **Gancho del vídeo:** «Mueve la cámara 20 cm y tu producto parece más caro.»

**Qué demuestra:** Visto desde abajo, un producto parece superior y más lujoso. La excepción son los productos con cara (mascotas de marca, juguetes), que gustan más vistos desde arriba.

**Estudios que la respaldan (verificados):**

- *(principal)* Van Rompay, T. J. L., De Vries, P. W., Bontekoe, F. & Tanja-Dijkstra, K. (2012). Embodied product perception: Effects of verticality cues in advertising and packaging design on consumer impressions and price expectations. Psychology & Marketing, 29(12), 919–928. [doi.org/10.1002/mar.20574](https://doi.org/10.1002/mar.20574)
  - Qué encontró: Ya verificado en la biblioteca (ver fuentes/README.md, Nº 005).
  - Comprobado el 2026-10-24 en: fuentes/README.md
- *(principal)* Xuan, C., Chen, R., Lin, S. & Huang, H. (2024). Looking up or down? The effects of camera angle on evaluations of anthropomorphized products in advertisements. Journal of Advertising, 53(4), 530–548. [doi.org/10.1080/00913367.2023.2282998](https://doi.org/10.1080/00913367.2023.2282998)
  - Qué encontró: Ya verificado en la biblioteca (ver fuentes/README.md, Nº 005).
  - Comprobado el 2026-10-24 en: fuentes/README.md

**Ojo · qué no decir:**

- Ya está en la biblioteca (Nº 005): no hay que crear la ficha.
- Los «20 cm» son un ejemplo del gancho: ningún estudio midió cuánto ángulo es el ideal. Empieza con algo sutil.

**Lo que cita Kolenda (sin verificar por nosotros):** Xuan et al. (2023, versión online) y Van Rompay et al. (2012) · los mismos que usamos

## 10 · Tras una oferta, calla tres segundos

- **Nº en la biblioteca:** 017 (provisional) · **Tema:** Negociación · **Categoría:** `ventas/negociacion` · **Evidencia (propuesta):** Media
- **Viene de Kolenda:** Pause After Your Counterpart Makes an Offer — <https://www.kolenda.io/tactics/pause-after-offer>
- **Gancho del vídeo:** «Cuando te hagan una oferta, cuenta hasta 3 en silencio.»

**Qué demuestra:** Callarse 3 segundos o más en una negociación hace que salga un acuerdo mejor para los dos: rompe la idea de «lo que tú ganas, yo lo pierdo» y hace pensar con más calma.

**Estudios que la respaldan (verificados):**

- *(principal)* Curhan, J. R., Overbeck, J. R., Cho, Y., Zhang, T. & Yang, Y. (2022). Silence is golden: Extended silence, deliberative mindset, and value creation in negotiation. Journal of Applied Psychology, 107(1), 78–94. [doi.org/10.1037/apl0000877](https://doi.org/10.1037/apl0000877)
  - Qué encontró: Cuatro estudios. Los silencios de 3 s o más se asocian con, y causan, más creación de valor conjunto; no con llevarse más parte. Mecanismo: mentalidad deliberativa y menos visión de «pastel fijo». Solo funciona si calla quien tiene más estatus.
  - Comprobado el 2026-10-24 en: https://dspace.mit.edu/handle/1721.1/144112

**Ojo · qué no decir:**

- No lo vendas como «ganarás más tú»: el estudio no encontró que el que calla se lleve más parte.
- Solo funcionó cuando calla quien tiene más poder o estatus; si eres la parte débil, no se vio el efecto.
- Kolenda se basa en otro trabajo (una ponencia de congreso); el nuestro es más sólido y dice algo distinto.

**Lo que cita Kolenda (sin verificar por nosotros):** Kwon & Weingart (2008), ponencia en el congreso IACM (no es artículo de revista)

