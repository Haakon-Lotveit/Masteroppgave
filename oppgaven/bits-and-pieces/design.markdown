## Design av systemet ##

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

public class MarkdownReport extends RepGenEntity {
  public file markdownFile;
  @Override
  public String repGenString() {
    return String.format("(markdown fil=\"%s\")", RepGenEntity.escapeString(markdownFile.getAbsolutePath()));
  }

Og med dette kan du bruke Java sine innebygde GUI elementer til å generere hele greien. JFileChooser, JavaFX, hele pakken. Med denne type objekter enkelt og greit.


Sammenligning med hva som har kommet før:

Du kan lage noe lignende et slikt system vha. standard UNIX-verktøy som Make og Bash. Disse programmene er standard vare, og har vært i bruk lenge og er relativt feilfri. Men det er likevel en forferdelig ide, fordi den jevne kontormedarbeider ikke sitter med en UNIX-maskin, og om de gjorde det (Mac, til dømes er da rimelig populært per i dag), så ville de ikke forventes å kunne bruke Make eller BASH. (Se: https://www.ecademy.no/nettstudier/okonomi-og-administrasjon/kontormedarbeider og http://www.treider.no/kontor-og-administrasjon/sekretaer/ for lånekassengodkjente utdannelser innen faget. Se videre Navs kursbeskrivelse her: https://www.nav.no/Forsiden/_attachment/353293?_ts=13fc24b8e78 http://www.studenttorget.no/index.php?show=5192&expand=4631,5192&yrkesid=110 har også ingenting om bruk av operativsystemer eller lignende i sin beskrivelse.) Det er også mye å be folk sette seg inn i.
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
(markdown fil="~/rapporter/testrapport/innledning.md")
(bilde fil="~/rapporter/testrapport/graf-fig-1.png")
(markdown fil="~/rapporter/testrapport/brodtekst.md")
(tabell fil="~/rapporter/testrapport/database-fig-2.csv")
(markdown fil="~/rapporter/testrapport/konklusjon.md")

Som er enkel å forstå, parse, og skripte.


Dersom en setter alle kilder og kall til dem som uavhengige uttrykk, og lar alle slike uttrykk være så enkle som mulig, så blir dette en beskrivelse av hva som skal inn i rapporten. Rapporten kan så genereres til et mellomformat som ikke ser så aller verst ut. Men hva med sluttresultatet? Skal den lages som HTML, ren tekst, PDF via LaTeX/DocBook, eller noe annet?

