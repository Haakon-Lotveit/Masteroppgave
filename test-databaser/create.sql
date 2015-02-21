drop table if exists allergener_matretter;
drop table if exists matretter;
drop table if exists allergener;

create table matretter (
       navn varchar(255) CONSTRAINT pk_matretter PRIMARY KEY,
       pris integer not null,
       dato_opprettet date not null,
       dato_oppdatert date not null,
       info text not null,
       meny_nummer integer not null
);

       
create table allergener (
       id varchar(63) CONSTRAINT pk_allergener PRIMARY KEY,
       fullt_navn varchar(127)	
);

create table allergener_matretter (
      matrett_navn varchar(255) references matretter(navn),
      allergen_id varchar(63)   references allergener(id)
);

insert into matretter (meny_nummer, navn, pris, dato_opprettet, dato_oppdatert, info) values
       (14, 'Pizza Franco',     22900, '2013-09-13', '2014-12-15', 'Biff, bernaise, sjampinjong, Provencalsk urteblanding, ost, tomatsaus'),
       (9,  'Pizza Jæger',      23900, '2013-08-13', '2014-06-15', 'Tomatsaus, ost, marinert biff, pepperoni, kjøttdeig, bacon, løk, paprika'),
       (3,  'Pizza Marinara',   21900, '2013-07-13', '2014-08-14', 'Blåskjell, tomatsaus, ost'),
       (2,  'Pizza Pepperoni',  20900, '2013-07-12', '2014-08-15', 'Pepperoni, ost, tomatsaus'),
       (1,  'Pizza Margherita', 19900, '2013-07-11', '2013-12-15', 'Ost, tomatsaus, basilikum');


insert into allergener (id, fullt_navn) values
       ('melk', 'Melk og melkeprodukter'),
       ('egg', 'Egg og eggprodukter'),
       ('fisk', 'Fisk og fiskeprodukter'),
       ('skalldyr', 'Skalldyr og produkter av disse'),
       ('nøtter', 'Nøtter og produkter av disse'),
       ('belg', 'Belgfrukter: Soyabønner, peanøtter (jordnøtter), erter og produkter av disse'),
       ('gluten', 'Glutenholdige kornslag: Hvete, rug, bygg, havre og produkter av disse');
 

insert into allergener_matretter (matrett_navn, allergen_id) values
       ('Pizza Franco', 'melk'),
       ('Pizza Franco', 'egg'),
       ('Pizza Marinara', 'skalldyr'),
       ('Pizza Jæger', 'melk'),
       ('Pizza Pepperoni', 'melk'),
       ('Pizza Margherita', 'melk');
