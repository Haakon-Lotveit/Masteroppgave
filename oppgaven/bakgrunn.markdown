# Bakgrunn #

## Hvorfor lage Rapgen? ##
En må per i dag lage rapporter som bygger på data.
Datamaskinen din vet hva dataene er, den kan sannsynligvis lage ting utav dataene, og alt du egentlig har lyst til er å trykke på knappen, og få en pdf-fil, eller et annet format. (Docbook, docx, postscript, html eller annet.)

Dette er egentlig mulig å lage fra før av. Alt som kreves er kunnskap til:
Shell-scripting, uthenting av dataene dine, GNU Make, Pandoc, og minst et markup-språk til å skrive i, kompilatoren til nevnte språk, og kommandolinjer.

Dette er tungvint og burde ikke være nødvendig. En bedre løsning ville vært å kunne spesifisere datakilder, rekkefølgen de skulle brukes i, og deretter utdataformatet. Da må du vite om et fornatet for å spesifisere inndatakildene, et format for markup (Markdown er valgt) til å kunne skrive brødtekst med, og nok kunnskap til databasene til å kunne hente ut dataene. Dersom du i tillegg kan skripte uthenting av data, er det gjort. Du kan da "trykke på knappen" så å si, og deretter få en rapport raskt og enkelt. Så kan du finskrive den etterpå. Da må du gjøre mindre unødvendig jobb, og kan få gjort mer med tiden din.

Et annet poeng med et slikt format er at formatet er veldig enkelt, og dermed lett for verktøy å operere med. En kan dermed skrive verktøy som lager denne type filer, og kjøre dem, og en kan lage dem med gode brukervennlige grensesnitt. Da blir programmet mer brukbart for flere mennesker, uten at det går på bekostning av de som kjenner programmet, og vil skrive selv. En kan også skrive verktøy som gjør den prosessen enklere.

## Hva finnes fra før? ##
NASA sin autogenerator for rapporter bør nevnes.
Proprietære systemer (Super 5.0, den motbydelige bøtten av dårlig kode den er.)
Andre?

Per i dag kan du selvsagt skripte handlinger som å hente data ut fra en server, du kan skripte numerisk analyse vha. statistiskkprogrammer som til dømes R, og du kan lime sammen mange filer til en stor fil og sende det til et program, som for eksempel en LaTeX kompilator, som kan lage pdf-en din.

Men du må altså gjøre det for hånd. Og selv om du kan sette opp make til å kjøre skriptene som henter ut og behandle dataene, og deretter lime det sammen via cat til en enhetlig fil som kan kompileres, er du begrenset til et format som du kan evt. kompilere vha. programmer som for eksempel Pandoc.

Problemet med dette systemet er at det er særdeles tungrodd, og er sveiset fast til Unix. Det er gjørbart om du er en datakyndig person på en Mac eller Linux boks, men ikke så enkelt for et vanlig menneske som ikke er vant til kommandolinjen.



## Inspirasjoner ##
Kjedelige rapporter som må lages for hånd hver gang.

## Hva er nytt? ##

## Hva er ikke nytt? ##
Automatisering av gjentatte handlinger er selvsagt ikke nytt som sådan, og det er flere andre programmer og systemer som har hatt innflytelse på prosjektet.

GNU Make er et eksempel på automatisering av bygging av programmer, og kunne nesten bli brukt som en del av programmet.
Ant er også et automatisert byggesystem som har noe innflytelse. 
Den store forskjellen her er at i GNU Make og Ant, definerer en forskjellige mål (av type bygg systemet, installer det, lag en jar-fil, lag en jar fil med avhengigheter inkludert, slett midlertidige filer, slett alle filer som ikke er kildekode, etc.

I rapport generatoren derimot, peker du på en fil som definerer prosjektet, og sier hvilket format som skal benyttes. Det er bare ett mål.
Make er veldig fint til å kjøre kommandoer før rapporten bygges, da kan en sikre seg ferske data, slik at en alltid bruker oppdaterte tall.
Dette kunne blitt bygget inn i systemet, men tidsbegrensinger og tilstedeværelsen av make gjorde det unødvendig.

Plugin-systemet er mye likt Emacs sitt system, som er enkelt å drifte, selv om det ikke er ferdig artikulert. Det har manuell håndtering av avhengigheter, og hver plugin antas å kun avhenge av hovedsystemet, eller komme med avhengighetene selv.

