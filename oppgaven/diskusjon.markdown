# Diskusjon #

## Hvilket forslag har vi endt opp med? ##

Prosjektet som det eksisterer nå er ikke en fullverdig løsning som det ble ønsket i innledningen. Til det mangler det for mange deler og biter.
Men det er nok til å kunne foreslå at dette designet er et godt utgangspunkt for et felles standardisert rapportgenereringsverktøy. Hovedgrunnene til dette er:

 - Det tar ikke over arbeidet med å samle sammen eller bearbeide informasjon, men spiller på lag med verktøy som allerede finnes. Det er dermed ingen grunn til å ikke støtte dette verktøyet.
 - Den enkle syntaksen gjør det lett for tredjepartsverktøy å støtte verktøyet. Det er enkelt å generere filene, og det er enkelt å parse dem.
 - Støtte for utformater er enkel å lage, og vil i praksis ikke kreve mye arbeid.
 - Inndata kan også utvides, så lenge inndata kan parses ned til dataformater som mellomformatet kjenner kan en legge til nye datakilder uten å måtte endre backend-kompilatorene. Legger man ved en måte å hente ut data fra Microsoft® Excel™, må en definere det en gang, og en får dem gratis til alle utdatakildene.
 - Systemet støtter flere arbeidsmetoder, både store alt-i-ett pakker men også skripting og den klassiske sammenkoblingen av små verktøy som er kjent fra UNIX-verdenen.

Til sammen utgjør dette en måte å ikke bare integrere mot tunge industrielle programvarepakker, men også en måte å integrere mot mindre sammenhackede pakker, og gi dem en bedre kvalitet enn det som ellers ville vært mulig. Muligheten til å bruke et slikt system til å generere rapporter med data som er generert i eldre legacy-systemer lar en øke kvaliteten på rapportering som allerede blir gjort. Det gjør det også mulig å automatisere rapportering der dette tidligere ble gjort for hånd, til dømes ved klipping og liming. Denne automatiseringen kan spare mennesker for mye tid da de ikke lenger trenger å lage ting for hånd, men må nå enkelt sett opp en mal istedenfor. I tillegg til dette er det også en mulighet for tidsbesparelse for utviklere, da de ikke lenger trenger å generere rapporter programmatisk fra bar bakke, men kan bruke verktøy som AuRa til å la dem generere rapporter programmatisk som ser bra ut, og som passer til deres formål, uten å måtte gjøre alt selv. 

## Ting som forslaget ikke dekker ##

Forslaget dekker en programvarepakke og hva den kan brukes til. Det forslaget ikke dekker i noen stor grad er hvordan det burde brukes.
Det er noen føringer på bruk, i form av markdown som ikke støttes, som for eksempel bildetaggen.
Dette er ikke noe som er gjort på måfå eller utelatt på grunn av tid, men en unnlatelse som er gjort med vitende og vilje. Selv om markdown§Markdown§ ikke er standardisert med en formell grammatikk er det dokumentert hvordan en kan lenke bilder. Dette er selvsagt nyttig når en vil bruke markdown til å generere html-kode med. Grunnen til at det ikke er støttet i AuRa er fordi bilder er informasjonskilder i seg selv, og det ønskes at alle kilder listes i AuRa-filen som kompilatoren jobber mot, for å gi best mulig oversikt til brukeren. Denne oversiktligheten er et bevisst valg mellom å gjøre et språk raskt å skrive mot å være raskt å feilrette. For eksempel er det raskere å legge en peker til en bildefil inn i et markdowndokument enn det er å legge det til som en egen kildelinje i AuRa dokumentet. På den annen side, i et tenkt system i framtiden der en kunne hatt støtte for ODT-dokumenter, markdown og HTML samtidig kan det fort bli vanskelig å finne igjen et bilde i kildekoden. Hvis den er i HTML-filen må du søke etter <img>-tagger, mens dersom det er i markdown må du søke etter \!\[\*\?\+\]\(\*\?\+\) for å finne bildet. Mens ODT er et binærformat du måtte åpnet manuelt. Flere formater også mulig med sine egne syntakser. ¤[Se doocbooks for et eksempel](http://www.docbook.org/tdg/en/html/imagedata.html)¤
Derfor ble valget tatt med å begrense syntaksen til å støtte tekstuelle elementer, og ikke bilder og/eller tabeller.

Men det er andre ting som forslaget ikke dekker: For eksempel, hvordan skal en organisere kall til eksterne programmer? Dersom de produserer kilder, burde en først kalle programmet, så bruke kilden, og så slette filen? Eller burde en først produsere alle kildene, så bruke dem, og så slette dem etterpå? Eller burde en ikke slette i det hele tatt. Dette er spørsmål som ikke er besvart. Det er gode argumenter fra flere sider, og det er heller ikke gitt at folk ønsker å bruke AuRaskript til å kalle eksterne programmer til å begynne med. En kan tenke seg noen som ønsker å bruke GNU eller BSDs Make programmer. En kan tenke seg at noen bruke shellskript, eller andre verktøy igjen. Dersom AuRa skal støtte flere bruksområder og dermed bruksmønstre, og disse forder ulik bruk av AuRa i seg selv (En kan tenke seg et automatiseringsverktøy som integrerer AuRa ikke ønsker å kalle programmer det kan kalle selv, med bedre finesse og flere muligheter. En kan også tenke seg at noen som bruker Unix ønsker å bruke Make-filer til å generere rapporter med, eller at andre bruker shellskript.) blir det derfor ikke betimelig å legge føringer på bruk. Et annet moment er at verktøy som AuRa er relativt nye, og det dermed ikke er tradisjoner å hente fra, slik som det ville vært dersom en lagde tekstverktøy for UNIX-maskiner eller grafiske programmer for OSX.

Derfor er dette et forslag på en type system som er nyttig i flere sammenhenger, med en solid kjerne som er åpen for utvidelser både foran og bak, så den kan håndtere både nye datakilder og nye utformater, men samtidig hjelpe folk på vei med å gi bedre rapporteringsmuligheter raskere og enklere.

## Igjen å gjøre ##

### Feilrette ###
Programmet har noen småfeil igjen per dags dato i programmet. Kildekode i mellomformatet får escapede spesialtegn, som ikke blir håndtert korrekt i pdflatex-backendkompilatoren.

### Refaktorering ###

Systemet per i dag bruker ikke navnerom, men bruker Emacs-Lisp idiomet med å prefikse funksjonsnavn med et pakkenavn¤Til dømes fec-compile for "frontend"-compile¤

### Egenskaper, utvidelser, med mer ###

Systemet inneholder per i dag en backend kompilator og støtte for 3 dataformater. I tillegg kan det være ønskelig å utvide mellomformatet til å håndtere skriftfonter, skriftstørrelse, med mer. Dette vil la en designe dokumenter med mer forseggjort tegnsetting. Videre er det liten mulighet til å sette standardfonter eller lignende. Dette er ting som med hell kan legges til i senere utvidelser.
For å utdype inndatakilder, kunne det vært ønskelig med løsninger som lot en ta i mot data i flere formater, som RTF, ODS, XLSX og lignende.
Hva angår backend er det lite med en mulig kompilator, det hadde vært ønskelig med flere formater som docbook, HTML eller evt. ODT. HTML hadde vært særs interessant med tanke på integrasjon mot Apache via mod-lisp. Da kunne Apache tatt seg av sikkerhetsaspectet, og servert rapporter direkte via html i en nettleser.

Det er altså flere direkte utvidelser en kunne tenke seg å gjøre på prosjektet, samt feilretting og noe refaktorering for å heve kvaliteten på koden enda høyere, men det er ingenting som endrer på det grunnleggende designet på prosjektet.
