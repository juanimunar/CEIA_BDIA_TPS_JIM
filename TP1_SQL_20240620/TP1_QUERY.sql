-- Selecciona todos los registros de la tabla Albums.
select * from album;

-- Selecciona todos los géneros únicos de la tabla Genres.
select name from genre;

-- Cuenta el número de pistas por género.
select genre.name, count(track.track_id)
from track
join genre on track.genre_id = genre.genre_id
group by genre.name;

-- Versión con alias
select g.name as genero, count(t.track_id) as n_pistas
from track t
join genre g on t.genre_id = g.genre_id
group by g.name;

-- Encuentra la longitud total (en milisegundos) de todas las pistas para cada álbum.
select album_id, sum(milliseconds) as long_miliseg
from track
group by album_id;

-- Lista los 10 álbumes con más pistas.
select album.title, count(track.album_id) as track_count
from track
join album on track.album_id = album.album_id
group by album.title
order by track_count desc
limit 10;

-- Encuentra la longitud promedio de la pista para cada género.
select genre.name as genero, avg(track.milliseconds) as long_prom
from track
join genre on track.genre_id = genre.genre_id
group by genre.name;

-- Para cada cliente, encuentra la cantidad total que han gastado.
select concat(c.first_name, ' ', c.last_name) as cliente, sum(i.total) as total
from invoice i
join customer c on i.customer_id  = c.customer_id
group by c.customer_id;

-- Para cada país, encuentra la cantidad total gastada por los clientes.
select billing_country, sum(total) as cantidad_total
from invoice
group by billing_country;

-- Clasifica a los clientes en cada país por la cantidad total que han gastado.
select concat(c.first_name, ' ', c.last_name) as cliente, 
	i.billing_country as pais, 
	sum(i.total) AS total
from invoice i
join customer c on i.customer_id = c.customer_id
group by cliente, i.billing_country
order by i.billing_country;

-- Para cada artista, encuentra el álbum con más pistas y clasifica a los artistas por este número.
with TrackCounts as (
    select album_id, count(*) as track_count
    from track
    group by album_id
),
AlbumTrackCounts as (
    select a.artist_id, a.album_id, tc.track_count
    from album a
    join TrackCounts tc on a.album_id = tc.album_id
),
MaxTrackAlbums as (
    select artist_id, max(track_count) AS max_track_count
    from AlbumTrackCounts
    group by artist_id
)
select ar.name as artist_name, atc.album_id, atc.track_count as max_track_count
from MaxTrackAlbums mta
join AlbumTrackCounts atc on mta.artist_id = atc.artist_id and mta.max_track_count = atc.track_count
join artist ar on mta.artist_id = ar.artist_id
order by max_track_count desc, artist_name;

-- Selecciona todas las pistas que tienen la palabra "love" en su título.
select * 
from track 
where name ~* '\mlove\M';

-- Selecciona a todos los clientes cuyo primer nombre comienza con 'A'.
select * 
from customer 
where first_name ilike 'a%';

-- Calcula el porcentaje del total de la factura que representa cada factura.
select 
    invoice_id, 
    total, 
    round((total / sum(total) over ()) * 100, 2) as porcentaje
from invoice;

-- Para cada cliente, compara su gasto total con el del cliente que gastó más.
with ClienteGasto as (
	select customer_id, sum(total) as gasto
	from invoice i
	group by customer_id)
select 
	concat(c.first_name, ' ', c.last_name) as cliente,
	cg.gasto,
	round((cg.gasto / max(cg.gasto) over ()) * 100, 2) as porcentaje
from ClienteGasto cg
join customer c on cg.customer_id = c.customer_id;

-- Calcula el porcentaje de pistas que representa cada género.
with PistaGenero as (
	select genre_id, count(track_id) as pistas
	from track t
	group by genre_id)
select
	g.name as genero,
	round((pg.pistas / sum(pg.pistas) over ()) * 100, 2) as porcentaje
from PistaGenero pg
join genre g on pg.genre_id = g.genre_id
order by porcentaje desc;

-- Para cada factura, calcula la diferencia en el gasto total entre ella y la factura anterior.
select 
    invoice_id as n_factura, 
    total, 
    total - lag(total) over (order by invoice_id) as diferencia
from invoice
order by invoice_id;

-- Para cada factura, calcula la diferencia en el gasto total entre ella y la próxima factura.
select 
    invoice_id as n_factura, 
    total, 
    total - lead(total) over (order by invoice_id) as diferencia
from invoice
order by invoice_id;

-- Encuentra al artista con el mayor número de pistas para cada género.
with CompositorGenero as (
	select
		genre_id,
		composer,
		count(*) as track_count
	from track
	where composer is not null
	group by genre_id, composer
),
MaxTrackGenero as (
	select
		genre_id,
		max(track_count) as max_track_count
	from CompositorGenero
	group by genre_id
)
select 
	g.name as genero,
	cg.composer as artista,
	cg.track_count as max_pistas
from CompositorGenero cg
join MaxTrackGenero mtg 
	on 
		cg.genre_id = mtg.genre_id
		and cg.track_count = mtg.max_track_count
join genre g on g.genre_id = cg.genre_id

-- Compara el total de la última factura de cada cliente con el total de su factura anterior.
with ClienteFactura as (
	select 
		invoice_id, 
		customer_id, 
		total,
		row_number() over (partition by customer_id order by invoice_id desc) as indice
	from 
		invoice
	group by 
		invoice_id
),
FacturaAnterior as (
	select
		invoice_id,
		customer_id,
		total,
		lead(total) over (partition by customer_id order by invoice_id desc) as factura_previa
    from
    	invoice
)
select
	r1.customer_id,
    r1.total as monto_factura_previa,
    r2.factura_previa,
    r1.total - r2.factura_previa as diferencia
from
    ClienteFactura r1
join
    FacturaAnterior r2
on
    r1.invoice_id = r2.invoice_id
where
    r1.indice = 1;
    	
-- Encuentra cuántas pistas de más de 3 minutos tiene cada álbum.
select
    a.title AS album,
    count(*) AS pistas_3_mas
from
    track t
join
    album a
on
    t.album_id = a.album_id
where
    t.milliseconds > 180000
group by
    t.album_id, a.title;

  




    
    