## Materialer ##

Systemet er for det meste skrevet i Common Lisp, med hjelp fra verktøy og biblioteker fra Quicklisp.
Alle programmene er åpen kildekode, lisensiert med frie lisenser som BSD eller GPL og tilgjengelige vederlagsfritt.

### Steel Banks Common Lisp ###

Implementasjonen av Common Lisp er SBCL, som er basert på Carnegie Mellon University Common Lisp (CMUCL) og deler bugfixer med hverandre.
Hovedforskjeller inkluderer støtte for native-tråding på Linux, som gir en økt mulighet for paralellisering av arbeidsmengder sammenlignet med CMUCL. [CMUCL FAQ](http://www.cons.org/cmucl/FAQ.html CMUCL's FAQ)
SBCL er ansett som en robust og rask implementasjon av Common Lisp, og er valget av Lispimplementasjon på Alioths "Computer Language Benchmarks Game". [Alioth's benchmark's game](http://benchmarksgame.alioth.debian.org/ Benchmark game), der den er et av de raskere språkene.

Common Lisp er et multiparadigmespråk, som tilbyr objektorientering, funksjonell programmering med høyere ordens funksjoner, og andre metodologier som ønskes. Språket tilbyr også makroer som gjør det mulig å legge til eller endre syntaxen for språket, eller gi språket nye operasjoner det ikke kunne før. 

Utgaven av Steel Banks Common Lisp som er brukt i systemet er SBCL 1.2.3.debian (for AMD64).

### Quicklisp ###
[Quicklisp beta](https://www.quicklisp.org/beta/ Quicklisp Beta)

Quicklisp er et system for å håndtere avhengigheter i Common Lisp. Det kan sammenlignes med Apache Ivy eller Apache Maven, med noen forskjeller.

 - Apache Maven er ment til å håndtere hele prosesser, mens Quicklisp er begrenset til å håndtere avhengigheter.
 - Apache Maven og Apache Ivy kjører ved bygging, mens Quicklisp er tilgjengelig mens programmet kjører.
 - Java og Common Lisp bygges på forskjellige måter, så mens Apache Maven har sitt eget byggesystem, og Apache Ivy er tett integrert med Apache Ant, er Quicklisp integrert mot ASDF, som er et byggeverktøy for Common Lisp.

Siden Quicklisp er tilgjengelig ved kjøretid kan en bruke verktøyet fra Read Eval Print Loop (REPL) promptet, og dermed bruke Quicklisp som et verktøy for utforskende programmering. [Exploratory programming](http://en.wikipedia.org/wiki/Exploratory_programming Exploratory programming). For å støtte denne bruken har quicklisp også funksjoner for å bla gjennom og søke opp i pakkebrønnene (Eng: repositories) sine etter pakker med spesifikke navn. 

Selv om prosjektet enda er i beta, håndterer det allerede over 1300 biblioteker i pakkebrønnen sin.
Det har også integrasjon mot SLIME, en vanlig Common Lisp IDE laget for GNU Emacs, skrevet i Emacs Lisp.

Fordi det er tilgjengelig ved oppstart kan en også be Quicklisp om å oppdatere alle evt. avhengigheter programmatisk, for eksempel ved oppstart, og å laste dem ned om de ikke er funnet i systemet.

Dette gjør bygging av lisp-prosjekter med eksterne avhengigheter enklere enn å laste ned tarballer og installere dem ved hjelp av ASDF. Merk at Quicklisp integrerer seg selv mot ASDF, og bruker dette systemet til å registrere og bruke eksterne biblioteker.

Da Quicklisp oppdaterer seg selv, er nyeste utgave gitt ut siden 28. mai testet.

### CL-PPCRE - Portable Perl-compatible revular expressions for Common Lisp ###

CL-PPCRE [CL-PPCRE](http://weitz.de/cl-ppcre/ CL-PPCRE) er en effektiv motor for tolking av perl-kompatible regulære uttrykk. Den benytter seg av Lispkompilatoren for effektivitet ved å kompilere mønstrene ned til maskinkode. Dermed istedenfor å bygge en regulær-tilstandsmaskin som en VM, vil den generere en tilstandsmaskin i maskinkode. Dermed vil den kunne kjøre raskere enn tilsvarende PERL-regexer. (Dersom det er interessant er Aho-Corasick algoritmen bak blant annet fgrep, og et sted å begynne.)

CL-PPCRE er brukt til å parse det regulære språket [Regular Language](http://en.wikipedia.org/wiki/Regular_language Regulære språket) Markdown i kompilatoren.

Versjonen brukt er den nyeste per 28. mai.

### Split-Sequence ###
Split-Sequence [Split Sequence](http://www.cliki.net/split-sequence Split sequence) er et enkelt bibliotek for å dele opp sekvenser i delsekvenser.
Brukes i parsingen av inndata i prosjektet.

Versjonen brukt er den nyeste per 28. mai.

### GNU Emacs ###

GNU Emacs er et skriveprogram gitt ut av GNU, med ekstensive utvidelsesmuligheter. Den har muligheter for å skrive tekst i mange formater, blant annet LaTeX, Bibtex, Markdown, Common Lisp, med mer. Den har også blitt utvidet til å ha integrerte utviklingsmiljøer, heriblant SLIME. GNU Emacs 24.1 ble brukt til å skrive oppgaven og til å programmere med (ved hjelp av SLIME).

Versjonen av GNU Emacs brukt er GNU Emacs 24.3.1

### SLIME ###

SLIME [Slime](https://common-lisp.net/project/slime/ SLIME) (Superior Interaction Mode for Emacs) er et integrert utviklingsmiljø for Common Lisp for Emacs. Den støtter både GNU Emacs og XEmacs. Den støtter også flere implementasjoner av Common Lisp, deriblant Steel Banks Common Lisp.

SLIME kan integreres med Quicklisp og Quickproject, selv om sistnevnte ikke ble brukt i dette prosjektet.
Som integrert utviklingsverktøy hjelper det til med det meste en skulle ønske et integrert utviklingsmiljø gjorde, inkludert REPL-spesifikke ting som snarveier, setting av nåværende navnerom, med mer.

### Ubuntu 14.10 ###

Programmet ble utviklet til å kjøre på GNU/Linux maskiner på AMD64 baserte prosessorer. I begynnelsen på Ubuntu 14.04LTS (Trusty Tahr), men senere Ubzuntu 14.10 (Utopic Unicorn). Da Steel Banks Common Lisp er et abstraksjonsnivå på toppen av operativsystemet, og ingen kall til systemet gikk utover standard POSIX-kall burde det ikke være noen problemer med å kjøre på andre systemer, men dette er ikke testet, og integrasjonstesting mot andre systemer ligger utenfor det som er tid til å gjøre på dette prosjektet.

### Git DVCS ###

Til håndtering av kildekode er Git brukt.
Git er et distribuert system for versjonshåndtering av kildekode, og blir brukt her til å holde orden på oppgave og kildekode.

Utgaven av Git som er brukt er git version 2.1.0

### Data brukt til testing av systemet ###

Det er to hovedkilder til testdata til systemet. I tillegg til enhetstester som kjøres ved oppstart av systemet (da Common Lisp ikke har separerte tidspunkt for kjøring og kompilering som til dømes C, Java eller Ada har), brukes masteroppgaven her som rådata til systemet. Dette hjelper på motivasjonen til å få alle deler av systemet til å kjøre. I tillegg til dette har jeg fått låne data fra Peter Ellison til å generere rapporter fra, som jeg er svært takknemlig for. [TODO: Husk å putte ham på listen over folk jeg skal takke]


## Metoder ##

### Rational Unified Process ###

Til å utvikle systemet ble Rational Unified Process som beskrevet hos §Larman2011§ valgt, med modifikasjoner innenfor det som er beskrevet som lovlig. For eksempel har prosjektet blitt delt opp i delprosjekter for å ha en bedre oversikt over hva som skal gjøres og når, og har begrenset bruken av diagrammer til å kommunisere intensjoner med, med den begrunnelse at det er et enmannsprosjekt. Rational Unified Process som beskrevet av §Larman2011§s muligheter for å modifisere utviklingsmetodologien mellom iterasjoner for å tilpasse prosjektets behov er blitt brukt flittig. Dette har gitt en bedre forståelse av forskjellige formelle behov. For eksempel har bruken av interaksjonsdiagrammer blitt sterkt begrenset, noe som gjorde at formgivingen av interaksjonen med systemet fikk en lavere prioritet enn den kanskje hadde trengt. På den annen side gjorde det økte fokuset på tekniske detaljer og integrasjonen av systemene at disse detaljene kom på plass på en effektiv og gjennomtenkt måte.

Skulle prosjektet blitt gjennomført på nytt igjen fra bar bakke, ville RUP blitt brukt igjen. Det var en overraskende smidig metodologi, med mange anbefalinger, og få absolutte regler. Metametodologien er en stor del av dette. Kravet om at metodologiske verktøy og virkemidler blir evaluert mellom iterasjoner med mulighet for å forkaste eller legge til slike verktøy er viktig. Den andre delen er det nøkterne iterative synet Rational Unified Process har på utvikling. 


### Objektorientert programmering ###

Objektorientering er en måte å innkapsulere data og funksjoner i objekter. Disse objektene representerer entiteter i systemdesignet ditt, og kan utføre handlinger (metoder) basert på hvilke funksjoner de har tilgjengelige. 

I de fleste språk er disse metodene meldinger som sendes til objektene. (Til dømes kan en streng i Java bli bedt om å gjøre alle tegn til store bokstaver slik: "Java Streng".toUpperCase(), dette anses da som å sende en melding til strengen) Common Lisps objektsystem CLOS (Common Lisp Object System) [CLOOS](http://www.dreamsongs.com/NewFiles/ECOOP.pdf CLOOS) er fundamentalt annerledes, da den baserer seg på et system med generiske funksjoner istedenfor å sende meldinger.

En vil dermed i CLOS definere klasser uavhengig av funksjonene som opererer på dem. For å benytte seg av polymorfisme definerer man en generisk klasse, som har en signatur, og en kan dermed *spesialisere* denne generiske klassen med en metode. Denne metoden vil da ta en spesifikk typesignatur til minst et av argumentene sine. Det er viktig å påpeke her at mens i andre objektorienterte språk som Java og C# vil en metode kun tilhøre en klasse (siden den mentale modellen er å sende en melding til en klasse), vil en metode i CLOS kunne tilhøre flere klasser samtidig. Derfor kan en definere metoder uavhengig av klasser.

Dette ser ikke særlig annerledes ut, en kan til dømes ha en klasse "Kjøretøy" med to underklasser "Motorsykkel" og "Lastebil". En kan deklarere en generisk metode ved hjelp av defgeneric slik:

        (defgeneric start-motor kjoretoy
		            (:documentation "Starter en motor til et kjoretoy. Vil kaste en error om kjoretoyet ikke har motor"))

Og en kan videre spesialisere en metode for Lastebil således:

        (defmethod start-motor ((kjoretoy lastebil))
		           (lag-lyd "vrom vrom!"))

På dette punktet kan generiske funksjoner minne om Interface i Java og C#, men for funksjoner istedenfor. Men en kan også tenke seg følgende generisk funksjon:

        (defgeneric kollider traffikant1 traffikant2
		            (:documentation "Kjorer over en myk traffikant med et kjoretoy"))

Og da kan vi spesialisere på for eksempel en lastebil og en fotgjenger slik (antagelsen er at kjøretøy arver fra traffikant):

        (defmethod kollider ((traffikant1 lastebil) (traffikant2 fotgjenger))
		           (if (skadet traffikant2))
					   (tilkall-ambulanse))

På dette tidspunktet tilhører metoden klassene *lastebil* og *fotgjenger*. De er dermed spesialiserte på begge to, og hører ikke konseptuelt hjemme hos noen av klassene. Det kan virke som om dette er lastebilen som kolliderer med fotgjengeren, men hva om det er to lastebiler som kolliderer? Eller to fotgjengere? I språk som Java og C# får en da et dilemma om hva som skal skje, og hvor koden skal ligge. (En mulig løsning er Visitor-mønsteret [Visitor Pattern](http://en.wikipedia.org/wiki/Visitor_pattern Wikipedia visitor pattern Visitor-pattern)) I CLOS er dette bygget inn i systemet og en unngår dilemmaet.

[Jeg er ikke helt sikker på hvor mye jeg bør ha her. På den ene siden så er CLOS veldig forskjellig fra andre systemer, og CLOS bryter veldig hardt med den vanlige måten å gjøre OOP på. Det er ikke gitt at folk har en akademisk bakgrunn i hvordan OOP fungerer. På den annen side kan det fort bli litt mye.]

### Design av systemet ###

Systemet er ment til å være enkelt å bruke. Men hvem er da brukeren tenkt å være?
Svaret er at brukere er ment til å være andre som integrerer systemet inn i sine egne verktøy og bygger videre på dem.
Derfor bør språket:

 - Være enkelt å skrive maskinelt.
 - Være lett å verifisere.
 - Om det skal kunne utvides, må det kunne utvides via godt dokumenterte grensesnitt.
 - Validering må kunne skje med gode tilbakemeldinger ved feil, slik at brukere kan varsles på en god måte.
 
Siden alt er tekst og språket er lingvistisk enkelt å beskrive, er det ikke vanskelig for verktøy å integrere mot systemet.
Hver linje beskriver en og bare en del av rapporten helt uavhengig av andre deler. Dette gjør at en kan tenke seg enkle klasser ala:

      public Interface RepGenEntity {
        public String repGenString();
      }
      
      public class MarkdownReport extends RepGenEntity {
        public file markdownFile;
        @Override
        public String repGenString() {
          return String.format("(markdown fil=\"%s\")", RepGenEntity.escapeString(markdownFile.getAbsolutePath()));
        }
      }

Og med dette kan du bruke Java sine innebygde GUI elementer til å generere hele greien. JFileChooser, JavaFX, hele pakken. Med denne type objekter enkelt og greit.


Du kan lage noe lignende et slikt system vha. standard UNIX-verktøy som Make og Bash. Disse programmene er standard vare, og har vært i bruk lenge og er relativt feilfri. Men det er likevel en forferdelig ide, fordi den jevne kontormedarbeider ikke sitter med en UNIX-maskin, og om de gjorde det (Mac, til dømes er da rimelig populært per i dag), så ville de ikke forventes å kunne bruke Make eller BASH. ¤Se: godkjente utdannelser
[Kontormedarbeider](https://www.ecademy.no/nettstudier/okonomi-og-administrasjon/kontormedarbeider kontormedarbeider) og [sekretær](http://www.treider.no/kontor-og-administrasjon/sekretaer/ sekretær) for lånekassengodkjente utdannelser innen faget. Se videre Navs kursbeskrivelse her: [navs kursbeskrivelse](https://www.nav.no/Forsiden/_attachment/353293?_ts=13fc24b8e78 navs kursbeskrivelse) eller evt. [studenttorget](http://www.studenttorget.no/index.php?show=5192&expand=4631,5192&yrkesid=110 studenttorget) har også ingenting om bruk av operativsystemer eller lignende i sin beskrivelse.) ¤  Det er også mye å be folk sette seg inn i.
I tillegg ville en slik løsning være porøs og vanskelig å sette opp for forskjellige systemer eller behov. Det er lite til ingen inkapsulering, og det er heller ikke enkelt å integrere mot andre verktøy som det burde vært. Uttrykk strekker seg over flere linjer, en har semantisk betydning i indenteringen, og andre anakronismer. (Lenke mot manualer her?)
Et eget subspråk for disse typer uttrykk hadde vært bedre. Da blir det enklere å generere uttrykk programmatisk, og det blir lettere for andre mennesker å lese og forstå det som står i uttrykkene, om ikke nødvendigvis skrive dem. (Domain spesific languages boken?)

Da blir spørsmålet hvilke datakilder som skal støttes, og på hvilket nivå dette skal skje. En kan tenke seg den enkleste muligheten kan være rik tekst i form av et Markdown-format, bilder i form av Portable Network Graphics (PNG) og tabeller i form av Comma Separated Values. Disse tre dekker et vidt spekter av datatyper. Spørsmålet blir så hvor en skal hente data fra. Den enkleste løsningen er å peke til eksterne småprogrammer som kan skrives ad-hoc. For eksempel kan en ha en to-tre markdownfiler et eksternt bilde, og en tabell. Tabellen blir generert av et script som snakker med en database, og bildet blir lagget av et statistikkprogram (R, SPSS eller andre) som skriver ut resultatene sine som en graf som lagres som et bilde. Med R kan dette gjøres via et standard script.

En kan da tenke seg følgende fil:
      ;; Erklær type
      (utdata format="LaTeX/PDF")
      
      ;; Hent data og marker for sletting
      (kjør fil="~/rapporter/testrapport/statistikk.r")
      (slett-etter-kjøring fil="~/rapporter/testrapport/graf-fig-1.png")
      
      (kjør fil="~/rapporter/testrapport/hent-database-informasjon.py")
      (slett-etter-kjøring fil="~/rapporter/testrapport/database-fig-2.csv")
      
      ;; Inkluder materiale
      (le(markdown fil="~/rapporter/testrapport/innledning.md")
      (bilde fil="~/rapporter/testrapport/graf-fig-1.png")
      (markdown fil="~/rapporter/testrapport/brodtekst.md")
      (tabell fil="~/rapporter/testrapport/database-fig-2.csv")
      (markdown fil="~/rapporter/testrapport/konklusjon.md")
      

Dersom en setter alle kilder og kall til dem som uavhengige uttrykk, og lar alle slike uttrykk være så enkle som mulig, så blir dette en beskrivelse av hva som skal inn i rapporten. Rapporten kan så genereres til et mellomformat som ikke ser så aller verst ut. Men hva med sluttresultatet? Skal den lages som HTML, ren tekst, PDF via LaTeX/DocBook, eller noe annet?

Dette kan da implementeres ved hjelp av back-ends til kompilatoren. Disse kan da lages etter behov, plugges inn og registreres, slik at de blir tilgjengelige for systemet. Dermed kan en utvide systemet til å møte nye utfordringer.

Det er selvsagt noen negative sider ved et slikt design som er holdt så enkelt som mulig. Dersom en skal sette inn et bilde må en klippe en tekstfil i to. Dersom en skriver for hånd kan dette bli noe irriterende i lengden. Men dersom en bruker verktøy til å generere med, kan en unnslippe problemet ved å verktøyet gjøre dette bak kulissene. Da vil en unngå en del av problematikken.

Dette designet ble ikke ferdig implementert, selv om dette var tanken bak. Det ville vært relativt enkelt å lage et verktøy som kunne satt opp den ovennevnte filen. Tilgjengelige utformater kunne blitt oppdaget ved å sende spørringer til systemet. Programmer som skal kjøres kunne blitt satt inn relativt enkelt gitt at brukerene visste hvilke filer en var interessert i. Det eneste som hadde vært igjen ville være å la brukere skrive tekst som skulle brukes, velge hvor filer skulle settes inn, og la dem redigere til de var fornøyd.

Flere mulige funksjoner ble overveid men til slutt forkastet:

 - Automatisk generering, til dømes hver dag, eller annenhver time ble forkastet til fordel for å bruke innebygde systemer for akkurat dette.
 - Flere datatyper som JPG, RTF eller lignende ble forkastet for å kunne fokusere på muligheter, og spare tid. Støtte kan evt. utvides senere.
 - Flere utdatatyper var en mulighet, men ville tatt for lang tid å fullføre.

[Blant flere muligheter. Dette er en trist liste.]
