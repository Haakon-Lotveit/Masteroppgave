## Valg av støttede formater ##

Det er valgt ut tre formater som skulle støttes, som ble ansett som et minstemål for å ha et levedyktig system som kunne være reelt nyttig for folk.

Disse tre er:

 - Markdown, som lar en skrive formattert tekst på en enkel måte
 - CSV, som lar en legge til tabulære data
 - PNG, som lar en bruke bilder i rapportene sine.

Tanken var å produsere rapporter basert på data fra disse tre kildene. Årsaken til at disse tre ble valgt var følgende:

### Markdown ###

Markdown ble valgt fordi det blir brukt på populære sider som [StackOverflow](http://stackoverflow.com/editing-help so-md) og [GitHub](https://help.github.com/articles/github-flavored-markdown/ gfmd) og enterpriseverktøy som tilbys av Atlassian som [Confluence, Stash og Jira](https://confluence.atlassian.com/display/STASH/Markdown+syntax+guide atlassian) (riktignok med egne utvidelser), og er dermed mer sannsynlig at folk har sett før. I tillegg er språket enkelt å begynne å bruke. En kunne ha argumentert for å bruke filer fra MS Word eller lignende, men dette ble ansett som for vanskelig å få til med tiden som var tilgjengelig. Markdown er dessuten et tekstbasert språk, og en kan dermed åpne og redigere det i en vanlig teksteditor som Notepad, gedit eller Text Edit. En kan også bruke mer avanserte editorer som GNU Emacs, Sublime Edit eller lignende dersom en ønsker det.

Utfordringen kom i at Markdown ikke har god dokumentasjon. Den har [en guide](http://daringfireball.net/projects/markdown/syntax syntax-md), men ingen formell syntaks tilgjengelig på hjemmesiden. Den tilbyr [en referanseimplementasjon](http://daringfireball.net/projects/markdown/ markdown-main) skrevet i perl, levert i en fil, med 1450 linjer kode. Selv om koden var god og idiomatisk perl, er det likevel noe meget for en person å sette seg ned å lese og forstå. Parsing og kompilering av markdown endte opp til slutt med å være den største tidstyven, og det tok flere måneder før en korrekt implementasjon var på plass. Når det er sagt, må det også sies at Markdown ikke ble et populært språk ved å være dårlig. I likhet med dette prosjektet tar det også sikte på å være så leselig som mulig[Markdown-referanse til lesbarhet](http://daringfireball.net/projects/markdown/ markdown-main), som er en av grunnene til at det ble valgt som første støttede tekstspråk.

### CSV ###
CSV ble valgt av flere grunner. For det første er det et lingua franca hva angår tabeller. En kan eksportere til CSV fra regneark som Excel[excel-csv](https://support.office.com/en-za/article/Import-or-export-text-txt-or-csv-files-5250ac4c-663c-47ce-937b-339e391393ba) eller Calc[calc-csv](https://help.libreoffice.org/Calc/Importing_and_Exporting_CSV_Files), samt fra SQL-verktøy som DBVisualiser[dbvis-csv](http://www.dbvis.com/doc/9.0/doc/ug/exportImport/exportImport.html), eller direkte fra programmeringsspråk som Java, Common Lisp, C#, C++, Haskell, m.fl. At formatet er så universelt gjør det til et selvsagt valg for håndtering av tabeller: En kan alltids gjøre om til CSV fra andre tabellformater, og dermed kan en for eksempel bruke MS Excel til datamanipulering, og så eksportere til CSV, og deretter bruke resultatet nesten direkte i AuRa. I tillegg tilbyr LibreOffice[lo-ask-odt-csv](http://ask.libreoffice.org/en/question/21916/cli-convert-ods-to-csv-with-semicolon-as-delimiter/ li-cli-conv) muligheter for å skripte konverteringen så en kan gjøre det via skript før en kjører AuRa.


### Bilder ###
Det er ikke noe offisielt bildeformat som støttes, selv om det eneste som er omstendelig testet er PNG (Portable Network Graphics). Behovet for bilder bygger på flere årsaker:

 - De fleste større tekststykker har bilder i seg for å bryte opp teksten.
 - Grafer og diagrammer er en naturlig del av rapportering.
 - LaTeX og andre formater støtter kompilering av matematiske formler ned til bildeformater

Dermed, for å støtte disse behovene, ikke bare for generelle bilder, men også diagrammer formler og grafer, ble det implementert støtte for bilder. Denne støtten er den programmatiske enkleste å støtte, og den første som ble gjennomtestet og ferdig.

## Prosjektfilen (.AuRa) ##

Prosjektfilen i seg selv er ganske enkel. Tomme linjer blir ignorert, og kommentarer begynner med semikolon (;) og går til slutten av linjen.
Hver spesifikasjon begynner med en åpen parantes, med type av inndata som en streng, og deretter blir opsjonenene gitt. Opsjoner begynner alltid med et kolon og blir umiddelbart etterfulgt av en strenginstans. For eksempel:

        (markdown :fil "~/git/Masteroppgave/oppgaven/bakgrunn.markdown")

(Dette eksempelet er tatt fra filen som ble brukt til å generere denne oppgaven.)

Mer formelt vil gyldige utsagn alltid ta formen (Utvidet Backus-Naur Form):
        ws = \[:whitespace:\]
        gyldig navn = :char:-ws;
        datakilde = gyldig navn ;
        opsjonsnavn = gyldig navn ;
        linje = \[ws\], \[datakilde\], \[ws\], \[kommentar\]
        kommentar = ";", [:character:] ;
        datakilde = "(", navn, {opsjonsgruppe}, \[ws\]")" ;
        escape hermetegn = "\\"" ;
        strengliteral = "\"" {:char:-"\"" | escape hermetegn} "\"" ;
        opsjonsgruppe = ws ":", gyldig navn, ws, strengliteral ;

Per dags dato kan en anse grammatikken som betydelig forenklet med bare følgende lovlige utsagn:
        escape hermetegn = "\\"" ;
        strengliteral    = "\"" {:char:-"\"" | escape hermetegn} "\"" ;
		kommentar        = ";", [:character:] ;
        markdown         = "(markdown :fil ", strengliteral, [:whitespace:], ")" ;
        bilde            = "(bilde :fil ", strengliteral, [:whitespace:], ")" ;
        tabell           = (tabell :fil ", strengliteral, [:whitespace:], [":første-linje-er-tabellnavn ", ("ja"|"nei")], ")" ;
		linje            = [:whitespace:], [tabell | bilde | markdown], [:whitespace:], [kommentar] ;
Men poenget forblir det samme: Grammatikken er svært enkel å forstå for tredjepersoner. Den er med vilje designet for å være lettere å lese enn for å være rask å skrive. 
Grunnen til at dette valget ble tatt tidlig i prosjektet er hentet fra The Mythical Man Month§MythicalManMonth§ der det blir hevdet at over 90% av alle kostnadene ved et programvareprosjekt kommer når en skal vedlikeholde det. Dermed er det mer økonomisk å gjøre det lett for programmerere å vedlikeholde et system, enn det er å gjøre det raskt å skrive. Som en konsekvens av dette blir alle kilder spesifisert spesifikt for seg en per linje, så det er enkelt å se hvor alle kildene kommer fra. Som en direkte konsekvens av dette er for eksempel bilder en egen datakilde, og spesifiseres for seg selv, selv om den kan spesifiseres internt i til dømes Markdown. Det har den uheldige konsekvensen at dersom en ønsker å putte et bilde i en tekstbolk må teksten splittes i to filer. En før og en etter teksten. Det finnes dog måter å komme rundt dette irritasjonsmomentet:

 - En kan utvide inndatafilen til å kunne ta i mot tekst som sitater, uten å referere til eksterne filer der teksten er enkel og relativt kort. Dette vil minimere bryet med å peke til filer. En siterer tekst, avslutter tekstbolken, setter inn et bilde, og fortsetter på en ny tekstbolk.
 - En kan også skrive verktøy som genererer AuRa filen automatisk mens du skriver for deg. Et slikt verktøy vil kunne splitte opp filer uten at du som produsent av rapporten må bry deg om de eksakte detaljene. En kan tenke seg standardiserte filnavn og undermapper som kan genereres maskinelt for å holde orden på teksten.

Slike irritasjonsmomenter er uheldige, men de er et valg som er tatt for å gjøre det enklere å senere gå igjennom en rapport for å plukke ut filer og oppdatere dem manuelt. Dersom for eksempel bilder ble spesifisert i et dokument blir det med ett mer komplisert å søke gjennom dem for å finne bildene og hvor de spesifiseres. Dette gjelder selvsagt også dersom en spesifiserer tabeller i et tekstformat for senere å finne dem.

Ved å holde slik informasjon i en sentral fil blir det enklere å søke igjennom dem, og holde orden på dem.

## Kompilering av AuRa filen, eller evt. Frontendkompilatoren ##

Frontendkompilatoren vil kompilere kildene beskrevet i .aura-filen ned til et mellomformat som er kalt "mfo"¤kort for *m*ellom*fo*rmat¤.

Dette mellomformatet er inspirert av Lisp og LaTeX-kommandoer. I all hovedsak blir tekst behandlet slik:

 - Backendkompilatoren behandler enten vanlig tekst eller en kommando.
 - Kommandoer blir behandlet for seg uten å vite om konteksten til resten av dokumentet.
 - Kommandoer blir begynt med en åpen parentes, og avsluttet med en lukket parentes.
 - Frontendparseren vil "escape" vanlige parenteser som ikke signaliserer en kommando med et '\' tegn.
 - Kommandoene kan ta i mot opsjonsgrupper som er grammatisk like AuRa, men etterfølges av tegn.

Merk at indentering ikke er meningsbærende i dette språket, og selv om det er ment til å være relativt lettlest for mennesker er det først og fremst et språk som er enkelt å parse ut og behandle maskinelt. Dette gjør det lettere å støtte nye utdataformater ved å lage nye plug-ins for backendkompilatoren. Siden det er bare et språk en må kunne parse, uavhengig av hvilke inndataformater som støttes, blir arbeidsbyrden mindre. En introduserer en ekstra byrde når en vil utvide mellomformatet, men denne byrden ville vært like stor uansett om en hadde et slikt format eller ikke.

Slik frontendkompilatoren er skrevet i dag vil den ta for seg AuRa-filen sekvensielt. Det vil si at den tar en og en datakilde, kompilerer den til mfo, og skriver til disk, før den går videre til neste. Dette er relativt raskt på små rapporter som denne, men dersom det viser seg å være ineffektivt, er dette et sted en kan tenke seg paralellisering for å øke hastigheten. En kan også optimalisere hastigheten ved å ikke skrive til disk, men lagre mellomformatet i minnet, da diskaksess er tregere enn minneaksess. Eksekusjonshastighet har dog ikke vært et fokus i dette prosjektet, ren kode, testdekning og kompletthet har vært større og viktigere fokus enn hastighet.

Slik det står i dag er mellomformatet skrevet til disk for å kunne lettere feilrette evt. feil som måtte dukke opp, og for å gjøre det så enkelt som mulig for enhetstesting. Ved en senere iterasjon kan en gå over til andre måter å ha enhetstesting på, men slik det er i dag fungerer korrekt.

## Mellomformatet ##

For eksempel kan en ta denne teksten (basert på kompileringen av oppgaven, forkortet):
        (NEW-PARAGRAPH)
        (UNORDERED-LIST
        (LINE-ITEM Språket er med vilje holdt enkelt. (...) )
        (LINE-ITEM Språket velger alltid (...) )
        (LINE-ITEM Språket er valgt til å (...) )
        (LINE-ITEM Språket vil beskrive hver (...) )
        (LINE-ITEM Rammeverket vil også legge opp til å (...) )
        (LINE-ITEM Rammeverket legger opp til (...) ))
        (NEW-PARAGRAPH)
        Et annen type problem er utdataformater.
		(...)

Mer formelt kan en beskrive formatet slik (EBNF):

        tekst = {(:char: - "(" - ")") | ("\\", :char:)} ;
        strengliteral = "\"", {(:char: - "\"") | ("\\", :char:)}, "\"" ;
        
        kommando = nullær kommando | tekst kommando | opsjonskommando | topprekursiv kommando ;
        nullær kommando = ny paragraf | horisontal linje ;
        ny paragraf = "\n(NEW-PARAGRAPH)\n" ;
        horisontal linje = "\n(HORISONTAL-LINE)\n" ;
        
        tekstkommando = understreket | emph | kursiv | sitat | sitering ;
        understreket = "(UNDERLINE ", tekst, ")" ;
        kursiv = "(CURSIVE ", tekst ")" ;
        emph = "(EMPHASISED ", tekst ")" ;
        sitat = "(QUOTE ", tekst ")" ;
        sitering = "(CITE ", tekst, ")" ;
        
        opsjonskommando = bilde | url kommando | overskrift ;
        bilde = "(IMAGE :FILE ", streng, ")" ;
        overskrift = "(HEADLINE ", nivå, tekst, ")" ;
        nivå = ":LEVEL ", strengliteral heltall ;
        strengliteral heltall = "\"" :integer: "\"" ;
        
        url kommando = "(URL", navn, altnavn, url, ")" | 
            	       "(URL", navn, url, altnavn, ")" |
        	           "(URL", altnavn, navn, url, ")" | 
        	           "(URL", altnavn, url, navn, ")" |
        	           "(URL", url, altnavn, navn, ")" |
        	           "(URL", url, navn, altnavn, ")" ;
        navn = " :NAME ", strengliteral ;
        altnavn = " :ALT-NAME ", strengliteral ;
        url = " :URL ", strengliteral ;
        
        topprekursiv kommando = liste | tabell ; 
        liste = uliste | oliste
        uliste = "(UNORDERED-LIST", {listeelement}, ")" ;
        oliste = "(ORDERED-LIST", {llisteelement}, ")" ;
        listeelement = "\n(LINE-ITEM ", tekst, ")" ;
        
        tabell = tabell uten header | tabell med header ;
        tabell uten header = "(TABLE", size, "\n", {datarad}, ")" ;
        tabell med header = "(TABLE", størrelse, ":HEADERS \"yes\"\n", overskriftsrad, {datarad}, ")" |
               	   	    "(TABLE", ":HEADERS \"yes\"", størrelse, "\n", overskriftsrad, {datarad}, ")" ;
        rad = datarad | overskriftsrad ;
        datarad = "(ROW", {data}, ")\n" ;
        data = "(DATA ", tekst, ")" ;
        overskriftsrad = "(ROW ", {overskrift}, ")" ;
        overskrift = " (HEADER ", tekst, ")" ;

## Ting som ble utelatt ##

### MVP - Minimal Valuable Product og valg av features som kunne være med ###
Kilde: [Startup Lessons Learned](http://www.startuplessonslearned.com/2009/03/minimum-viable-product.html Eric-Ries,-forfatter-av-The-Lean-Startup)

MVP, eller Minimal Valuable Product (Det minste levedyktige produktet) er det minste produktet du kan lage og få tilbakemelding på i markedsplassen, i følge Eric Ries.

I denne oppgaven er ikke målet å selge et produkt, men å vise at det er en mulighet for å forbedre livene våre ved å kunne lage rapporter automatisk. Derfor er det minste levedyktige produktet ikke et produkt som kan selges på en markedsplass,
men et produkt som kan overbevise om at et system som lar en spesifisere automatiske rapporter vil kunne gjøre livene bedre til de som lager rapporter. Dette prinsippet ble konsekvent anvendt for å avgjøre hvilke egenskaper produktet måtte ha, og hvilke ville være gode å ha, men ikke være essensielle.
Derfor ble en mengde planlagte funksjoner kuttet vekk av forskjellige årsaker for å få på plass en kjerne av systemet som ville kunne gjøre jobben så bra som mulig. For å prioritere ble det tenkt over om andre verktøy kunne ta over noe av jobben (som i tilfellet med eksterne kommandoer og Make), og om de er faktisk essensielle. Til slutt, ble arbeidsmengden vurdert ut ifra hvor mye arbeid det ble antatt å kreve. Å utvide kjøretidsmiljøet til å takle makroer eller funksjoner som argumenter ble vurdert til å ta for mye tid, uten å være tvingende essensielle.

### Kjøring av eksterne kommandoer ###

En tidlig feature som var planlagt å implementere var spesifisering av kommandoer som skulle kjøres, i en egen kommando:

        (Kommando :UNIX "pwd" :Windows "CD")

Dette ville la en spesifisere kommandoer som en kunne kjøre¤Eksempelet ville returnert mappen programmet brukte for øyeblikket¤, basert på operativsystem.¤Kommandoen i eksempelet ville virket på Windows, GNU/Linux distribusjoner og OSX¤
Grunnen til at kommandoen ble skrinlagt er tidsmangel: For at den skulle vært nyttig måtte den ikke bare kunne kjørt kommandoer for å lagre filer, som en kan spesifisere i andre automatiseringsprogrammer som GNU Make.
Det ville ikke gitt så veldig mye. Det den derimot var planlagt til var å hjelpe med definisjoner av makroer, som ble skrinlagt relativt tidlig når arbeidet ble planlagt. Disse makroene har sitt eget avsnitt.
Selvsagt ville evnen til å kjøre egne kommandoer la en slippe å bruke GNU Make i enkle tilfeller, og dermed være et positivt tillegg på egne premisser, men det ville ikke være en essensiell del av programmet ihht. MVP prinsippet som ble gitt tidligere.
I tillegg kan en få funksjonaliteten via andre programmer som GNU Make. Derfor ble den skrinlagt og ideen puttet på vent til kjernen av programmet ble ferdig.

Den ville likevel blitt implementert før muligheten til å definere makroer, da muligheten til å definere makroer ville fått mye større muligheter ut av denne kommandoen enn noen andre.

### Andre kilder til tekst enn filer ###

Opprinnelig var det planlagt å tillate tre forskjellige datakilder til en kilde. Til dømes ville alle disse være lovlige:

        (Markdown :fil "~/Dokumenter/markdown.md")
		(Markdown :sitat "# Overskrift #")
        (Markdown :kommando "~/skript/lag-markdown.sh")

Dette ble skrinlagt grunnet tidsbegrensinger. Det var også vurdert som mindre viktig enn andre muligheter:

For kommando er følgende problemer:
 - :kommando er ikke et trygt predikat, da noe som virker på et UNIX-system ikke nødvendigvis ville virket på et Windows-system.

 - Faktisk ville det vært tryggere å bruke (Kommando) direktivet, bruke utfilen, og slettet den manuelt etterpå.
   Å tillate predikater som er raskere å skrive er i utgangspunktet bra, men ikke når det gjør resultatet utrygt. Det er bedre å bruke ti sekunder mer på å skrive enn ti minutter på å debugge.

 - Selv om (Kommando) ikke ble implementert kan en bruke GNU Make eller lignende til å få samme effekten. Dermed faller det direkte behovet for å ha muligheten i første utgave bort.

 - Til sist, direktivet (Kommando) og predikatet :kommando vil ha samme funksjonalitet. Det gjør språket mindre forutsigbart.

For sitat er det relativt enklere: Det var der for å gjøre enkelte brukstilfeller som oppstod under bruk/utvikling raskere å behandle. Det det kokte ned til da var et det var relativt greit å lage en funksjon i editoren (GNU Emacs) som lagde en fil med sitatet og satte inn et direktiv med et :fil-predikat istedenfor.
Det er ikke alle editorer som tillater utvidelse på den måten, men det viste seg altså ikke å være et essensielt valg.

### Begrensede språkkonstruksjoner ###

Dersom en skal kunne utvide språket selv med egne konstruksjoner og funksjoner, kommer en før eller senere til å ønske å kunne gjøre ting som ikke er en direkte kommando.
For å støtte opp om makrosystemet var det derfor opprinnelig tiltenkt ekstra hjelpefunksjoner som for eksempel  Operativsystem) som henter ut operativsystemet (UNIX, Windows, eller evt. annet), eller (Formatter) som lar en formattere en tekststreng.
Dette ville nødvendiggjøre utvidelser til språket som å la en gi andre argumenter en strengliteraler til et direktiv.
En kan tenke seg for eksempel noe ala:

        (Kommando :UNIX (Formatter "~A~A" (AuRa-Mappe) "/skript/nix/shellscript.sh") :Windows (Formatter "~A~A (AuRa-Mappe) "/skript/windows/batchfil.bat"))

Som ville latt en ha relative stier til forskjellige kommandoer. Videre har en funksjoner som (Slett-Fil), (Finnes-Fil) og lignende. Dessuten har en også (Kondisjonal) som ville latt en gjøre ting ala:

        (kondisjonal
		  ((Finnes-Fil (Formatter "~A~A" (AuRa-Mappe) "tmp/del1.md"))
		   (Slett-Fil  (Formatter "~A~A" (AuRa-Mappe) "tmp/del1.md")))
	      ((Finnes-Fil (Formatter "~A~A" (AuRa-Mappe) "tmp/del2.md"))
		   (Slett-Fil  (Formatter "~A~A" (AuRa-Mappe) "tmp/del2.md"))))

Som ville slettet filer om de eksisterte. Videre ville konstruksjoner som lister og løkker på et tidspunkt begynne å dukke opp. Dette ville igjen tatt mye tid, uten å være av kritisk nødvendighet. Derfor ble det utstatt ihht. MVP-idiomet.

### Definisjoner av egne makroer ###

AuRa var alltid ment til å være et fleksibelt og utvidbart språk. I tillegg til å tilrettelegge for å legge til nye inn og utdataformat, var det også meningen å la brukere legge til egne kommandoer om de trengte det, og å la dem dele dem med hverandre.
På denne måten kunne behov som ikke var dekket av utviklere bli dekket av brukere. På denne måten kan en tilrettelegge for problemløsning som ikke var forutsett av hovedutviklerene. Opprinnelig var ideen å inkludere definisjoner av makroer slik:

        (Makro :fil "~/.aura/makroer/sql.aud")

Der "aud" var det tiltenkte etternavnet på makrofilene (kort for AuRa Definisjoner).

Videre var makroer tiltenkt å kunne defineres noe ala dette:

        (Definer-Makro :Navn "Slett"
		  (:filnavn fil)
		  (Kommando :UNIX (formatter "rm ~A" fil)
		            :Windows (formatter "del ~A" fil))) 

        (Definer-Makro :Navn "Kjør-Og-Slett-CSV"
		  (:Windows wkommando :UNIX ukommando :filnavn filnavn)
		  (Kommando :Windows wkommando :UNIX ukommando)
		  (CSV :fil filnavn)
		  (Slett filnavn))

Merk at dette ikke nødvendigvis er gode eller trygge makroer. Syntaks og lignende kom aldri lengre enn tegnebrettet, da arbeidsmengden som skulle til for å lage korrekte og leselige makroer fort ble ansett til å være relativt høy.
For eksempel ville en måtte kunne utvide AuRa til å utvide makroene, slik at til dømes¤(Markdown) er her for å gi litt kontekst til et tenkt enkelt dokument¤:

        ;; Dette programmet vil kun kjøre korrekt på *NIX-systemer, vil ikke kjøre på Windows-systemer.
		(Markdown :fil "/tmp/generert-forord")
        (Kjør-Og-Slett-CSV :UNIX "/opt/sqldumper/query-to-csv --query=\"Select 'something' from 'table' where param < 4 order by foo limit 10\" --outfile=/tmp/table.csv" :filnavn "/tmp/table.csv")
		(Markdown :fil "/tmp/generert-ettermæle")

Vil måtte utvides til følgende:

        ;; Dette programmet vil kun kjøre korrekt på *NIX-systemer, vil ikke kjøre på Windows-systemer.
		(Markdown :fil "/tmp/generert-forord")
		(Kommando :UNIX "/opt/sqldumper/query-to-csv --query=\"Select 'something' from 'table' where param < 4 order by foo limit 10\" --outfile=/tmp/table.csv" :filnavn "/tmp/table.csv")
		(CSV :fil "/tmp/table.csv")
		(Kommando :UNIX "rm /tmp/table.csv" :Windows "del /tmp/table.csv")
		(Markdown :fil "/tmp/generert-ettermæle")

Arbeidsmengden ble vurdert til å være for stor til å gjøre og å bli ferdig. Arbeidet ville ikke bare inkludert å preprosessere AuRa-filene, men også å itererere over syntaksen til den ble så bra som mulig.
I tillegg er nytteverdien sterkt synergisk med andre språkkonstruksjoner, som muligheten til å kjøre kommandoer, kondisjonaler og lignende. Siden disse også er en stor arbeidsmengde ble beslutningen tidlig tatt om å legge makroer til siden, og heller konsentrere seg om andre ting i systemet.

### Teksttyper annet enn Markdown ###

Selv om andre større og mer kompliserte teksttyper ikke var tiltenkt fra begynnelsen var det likevel andre datakilder som var tiltenkt.
Noen av disse har allerede kode påbegynt med enhetstester, men ble ikke inkludert i det ferdige produktet av forskjellige årsaker.

#### Direkte innsatt tekst ####
Direkte innsatt tekst ville vært tekst som ble satt inn nøyaktig slik den var og ikke oversatt på noen måter. Det var opprinnelig tiltenkt som en måte å legge til ting som ikke var støttet i mellomformatet inn i et spesifikt sluttformat. Et eksempel ville være matematiske formler i LaTeX.
Sammen med :sitat predikatet ville det la brukere gjøre ting som:

        ;; Forutsetter pdflatex-kompilatoren
		;; Novas DPS for (Q) Snipe, gitt at du går for Ambush Snipe
		(Markdown :fil "~/rapporter/Nova/Snipe-Damage-Ambush-Snipe-1.md")
		(Direkte-Innsatt :sitat " \\ $f(F_{Ambush-Snipe}(N_{Level}) = \frac{(146 + (31 \cdot N_{Level})) \cdot 1,20}{10}$ \\"
		(Markdown :fil "~/rapporter/Nova/Snipe-Damage-Ambush-Snipe-2.md")
		;; Novas DPS for (Q) Snipe, gitt at du går for Psi-Op Rangefinder
		(Markdown :fil "~/rapporter/Nova/Snipe-Damage-PsiOp-Rangefinder.md")
		(Direkte-Innsatt :sitat " \\ $f(F_{PsiOp-Range}(N_{Level}) = \frac{(146 + (31 \cdot N_{Level}))}{8}$ \\"
        (Markdown :fil "~/rapporter/Nova/Snipe-Damage-PsiOp-Rangefinder.md")
		;; Oppsummering til slutt, konkluderer med at lvl-1 talentene ikke bør velges med hensyn til dps på (Q) Snipe (diff på lvl 30 er ~5(!)).
		(Markdown :fil "~/rapporter/Nova/Snipe-Damage-konklusjon-1.md")
		(Bilde :fil "~/rapporter/Nova/diff-dps.png")
		(Markdown :fil "~/rapporter/Nova/Snipe-Damage-konklusjon-2.md")

For å få matte inn i et dokument som ellers ikke ville støttet det.
Av tidsmessige grunner ble dette ikke tatt med i prosjektet.

#### Ren tekst ####

En annen ting som kunne vært greit å hatt med hadde vært ren tekst (txt). Det finnes kode og slikt for å parse den ut, og det ville være lite arbeid å legge det til som et støttet format.
Årsaken til at det ikke ble gjort direkte var MVP-prinsippet om å bare ha med essensielle ting i begynnelsen, og for å unngå å ha mer ting i kodebasen som må vedlikeholdes og feilrettes.

## Utfordringer ##

### Markdown ###
En av de største utfordringene var en korrekt parsing av markdown uten formelle definisjoner av språket. Markdown er et språk som er lett å tyde, og enkelt i bruk, men implementasjonsdetaljene varierer mellom de forskjellige implementasjonene med forskjellige tillegg, endret oppførsel og mer.
Som et eksempel har en GitHubs endring, der et filnavn ala: "langt\_filnavn\_her.txt" vil bli stående som det er. I originalt markdown ville det blitt til "langt_filnavn_her.txt". Siden det er flere dialekter av språket, og ingen offisiell styring er det heller ikke noe som heter offisielt markdown. Dialekten som ble implementert er i all hovedsak som den original, med noen tillegg og særegenheter:

 - En URL *må* ha tre elementer, både navn, URL og alternativt navn.
 - En kan gjøre siteringer vha to paragraftegn, slik: \§SiterBok\§.
 - En kan be om fotnoter vha pengetegnet, slik: \¤Dette blir en fotnote\¤

URL-biten var gjort for å bli ferdig fortere, da Markdown tok særdeles lang tid sett under ett med feilretting, utvidelse, testing og refaktorering over tid. Den var til slutt tatt ut i en egen fil bare for å holde det overkommelig å lese.

### Definisjon av AuRa som språk ###

Språket i seg selv tok flere iterasjoner for å få til korrekt.
Det gikk gjennom flere former fra en YAML-inspirert notasjon via noe som lignet mer på XML, til dagens Lisp-inspirerte syntaks.
Den første syntaksen var ment til å være så enkel som mulig: En åpnet et dokument ved å be om et dokument, så spesifiserte man det man ville ha i dokumentet, og så avsluttet man dokumentet. Et eksempel på den første syntaksen så slik ut:

        Dokument:
          Tekst: type="markdown" fil="~/master/oppgave/del1.md" .
          Bilde: type="png" fil="~/master/oppgave/fig1.png" .
          Tabell: type="csv" fil="~/master/oppgave/tab1.csv" .
          .

I forhold til formatet som er nå, hadde det sine negative sider:

 - Det var nødvendig å begynne en rapport med ordet "Dokument:" selv om det alltid ville være der.
 - Brukere måtte huske på å avslutte alle elementene selv, vha. et punktum ('.'), inkludert dokumentet.
 - En måtte også bruke mellomrom mellom alle elementene, inkludert punktumet.
 - Formatet lå opp til en trestruktur, uten å tilby noen rekursive elementer.

Tilsvarende i det ferdige formatet ville vært

        (Markdown :FIL "~/master/oppgave/del1.md")
        (Bilde :FIL "~/master/oppgave/fig1.png")
        (Tabell :FIL "~/master/oppgave/tab1.csv")

Som har sine fordeler. Først å fremst er det mer konsist, og det er umiddelbart klart ved et øyenkast hvor et uttrykk begynner og slutter.
Det enkle metaforiske grepet med å putte uttrykk i parenteser kan argumenteres for og i mot. På den ene siden er det egentlig unødvendig: Alle uttrykk har sin egen linje per dags dato. Dermed blir det mer å skrive uten at det er nødvendig. På den annen side kan en tenke seg utvidelser der en bruker flere linjer på å uttrykke et direktiv. En kan tenke seg en framtidig utvidelse der en kan kjøre spørringer mot en SQL-database slik:

        (SQL-tabell :SPØRRING "SELECT * FROM TABLE"
		            :DATABASENAVN "DB"
					:DATABASETYPE "ORACLE-SQL"
					:SERVER "LOCALHOST"
					:BRUKERNAVN "TESTBRUKER"
					:PASSORD "TESTPASSORD")

En slik utvidelse ville vært mye enklere å lese når den kan fordeles ut over flere linjer:

        (SQL-tabell :SPØRRING "SELECT * FROM TABLE" :DATABASENAVN "DB" :DATABASETYPE "ORACLE-SQL" :SERVER "LOCALHOST" :BRUKERNAVN "TESTBRUKER" :PASSORD "TESTPASSORD")

Den får ikke engang plass på siden, men det er allerede unødvendig tungvint å se hva som skjer. Derfor ble det valgt å bruke et taggingsystem for å avgrense uttrykk, eller direktivene i AuRa.
Valget av avgrensing falt til slutt på Lispnotasjon istedenfor XML, som i sin tid så slik ut:

      <SQL-TABELL>
          <SPØRRING>SELECT * FROM TABLE</SPØRRING>
          <DATABASENAVN>DB</DATABASENAVN>
          <DATABASETYPE>ORACLE-SQL</DATABASETYPE>
          <SERVER>LOCALHOST</SERVER>
          <BRUKERNAVN>TESTBRUKER</BRUKERNAVN>
          <PASSORD>TESTPASSORD </PASSORD>
	  </SQL-TABELL>

Det er likevel to objektive hovedgrunner til at valget falt på lispinspirert notasjon:

 1. Lispnotasjon er raskere å skrive, da det kreves færre tegn enn XML.
 2. Lispnotasjon er enklere å parse, da det er færre regler og spesialtilfeller¤Sammenlign [W3s definisjon av XML her](http://www.w3.org/TR/REC-xml/ EBNF-for-XML) med grammatikken for AuRas språk lenger oppe.¤

XML-notasjon har den fordelen at det er enorme mengder verktøy tilgjengelig for å lette byrden med parsing. På den annen side tok det en kveld å skrive parseren for AuRa slik den er nå, så i dette tilfellet er det ikke et stort tap.
Selv om XML tilbyr støtte for rekursive definisjoner og trestrukturer, er ikke dette noe AuRa bruker per dags dato, og dagens enkle grammatikk kan utvides til å takle rekursive strukturer om det blir behov for det.
En kan argumentere for at dersom AuRa-rapporter blir spesifisert for hånd, så vil det blir gjort av verktøy, og dermed faller mye, om ikke all forskjellen mellom AuRas format og et XML-format bort. Men selv om det hadde eksistert verktøy som skrev AuRa-filer ville disse verktøyene ha nødvendigvis blitt skrevet av mennesker som måtte lest og forstått formatet de behandlet. Derfor blir det likevel aktuelt å gjøre det så lett som mulig for disse programmererene å gjøre jobben sin så godt som mulig.
Det er derfor ingen unnskyldning for å ha et dårlig format fordi verktøy tar hånd om det. 

### Definisjon av mellomformatet ###

Mellomformatet var sett som en nødvendighet siden dag en. Ønsket var et format som kunne leses for hånd, og være så tydelig at dersom en bare hadde tilgang på en tekstbehandler som til dømes Microsoft Word og en fil fra mellomformatet, skulle det være mulig å gjenskape dokumentet for hånd, om en hadde tålmodighet nok.
Her tok det også flere iterasjoner før dagens løsning ble skapt, men i motsetning til AuRa-formatet var det ingen store endringer, bare små, mindre endringer helt til nåværende iterasjon ble valgt. Den første iterasjonen så ut som HTML med parenteser, og var inspirert av [CL-WHO](http://weitz.de/cl-who/ cl-who) skrevet av Edi Weitz, men ble sakte men sikkert morfet inn i dagens utgave.


## Design for utvidbarhet ##
asdf

### Nye inndataformater ###
asdf

### Nye utdataformater ###
asdf

## Brukervennlighet ##
asdf
