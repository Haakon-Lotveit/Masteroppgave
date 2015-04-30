 -- Selects out all the menu items without eggs in them.
 -- Does this by finding all menu items that have eggs in them in a subquery.
 -- This is correct, but not exactly optimal.
 -- However, since this is just for a demonstration, I do not care.
SELECT meny_nummer, navn, pris, info 
FROM matretter
where matretter.navn not in 
  (SELECT DISTINCT matretter.navn as navn
   FROM       allergener 
   INNER JOIN allergener_matretter on allergener.id = allergener_matretter.allergen_id
   INNER JOIN matretter on matretter.navn = allergener_matretter.matrett_navn 
   WHERE allergener.id in ('egg', 'skalldyr'))
ORDER BY meny_nummer;