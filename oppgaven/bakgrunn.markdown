# Bakgrunn #

## Hvorfor lage AuRa? ##
Det finnes i dag mange rapporteringsoppgaver som må gjøres på et jevnlig basis [whitepapers og slikt kan siteres, er det en ok ting å gjøre?], og disse tar tid og krefter, og verre er, går ut på å hente ut data fra datamaskinen, lime det sammen i et format andre kan lese og sende det av gårde.
Dette tar tid som kunne produktivt brukes på andre ting. Videre er eksisterende løsninger deler av store automatiseringssystemer som er ment til å integrere mot andre løsninger, men ikke å bli integrert mot utenfra. De passer dermed ikke til å automatisk generere dokumenter som en del av en annen prosess, med mindre de selv styrer denne prosessen. Dette låser en ned til spesifikke løsninger, og gjør en mindre fleksibel. En annen løsning har tidligere vært å skripte vha. Python, PERL, Bash eller lignende. Dette er mer fleksibelt, og lar deg kompartmentalisere rapportgenereringen inn i logiske enheter relativt enkelt, men introduserer andre problemer i stedenfor: De har ofte dårlige teknikker for innpakking av kode, de blir fort komplekse, og de må vedlikeholdes på lik linje med all annen kode. De er dermed heller ikke perfekte. En kan selvsagt skrive sitt eget språk for å håndtere denne type data, men da får en et nytt problem. En må nå vedlikeholde et helt språk, og med mindre en får andre til å bruke det, får en problemet med å lære nye mennesker opp i språk.

Oppgaven vil prøve å takle problemet en bit på vei med å introdusere AuRa. Som er både et språk, men også et rammeverk for å produsere rapporter. AuRa er ment til å håndtere problemene som skripting medfører ved hjelp av følgende designvalg:

 - Språket er med vilje holdt enkelt. Det er ingen kompliserte ting i språket som helhet. Du snakker om tekst og/eller filer, og du får ut en eller flere filer.
 - Språket velger alltid klarhet framfor å være kortfattet. Du skriver gjerne kode en gang, men du leser den fire. Å gjøre det lettere for de som skal vedlikeholde programmene beskrevet i AuRa er en stor fordel.
 - Språket er valgt til å enkelt kunne genereres programmatisk. På den måten kan en skrive verktøy som bruker AuRa uten å være bundet til AuRa, eller måtte være en del av AuRa. På den måten kan en ha et samfunn rundt denne løsningen.
 - Språket vil beskrive hver bit av programmet som en fil. Denne filen må dermed enten finnes eller genereres på forhånd. Dette kan gjøres ved hjelp av til dømes Make, SCons eller Rake som kan enten kalle programmer som genererer filen, eller kjøre kommandoen som genererer den selv. En framtidig utgave av AuRa burde også støtte denne typen enkel oppførsel, men for å bli ferdig med prosjektet støttes ikke dette i den nåværende versjonen.
 - Rammeverket vil også legge opp til å bruke andre løsninger som allerede finnes, er velprøvde og fungerende der det lar seg gjøre. Det er til dømes ingen vits i å lage et system for å kjøre en AuRa-fil ved en viss tid eller mellom et visst intervall når cron(8) allerede finnes.
 - Rammeverket legger opp til at hver genererte bit av innhold blir separert fra andre biter av innhold. Dette har konsekvenser, både positivt og negativt, men det fremmer igjen synspunktet at det er viktigere å være enkel å vedlikeholde enn å være rask å skrive.

Et annen type problem er utdataformater. De er ofte relativt prisgitt det som støttes av plattformene. Dersom en bruker et automatisk system er du låst til de formatene som systemet støtter. Skripter du er du prisgitt det som er tilgjengelig. Det kan være alt fra HTML-templates til LaTeX hånd-hacking. Ingen av delene er spesielt fantastiske. På den ene siden kan man generere et format og så bruke et verktøy som Pandoc til å konvertere, men det blir fort problematisk om du har krav som Pandoc ikke kan eller vil støtte.

For å unngå denne problemstillingen er AuRa delt opp i to deler ala Gnu Compiler Collection, og fungerer som følgende: Først blir rapporten generert som normalt, og kompilert til et mellomformat. Dette mellomformatet er uttrykt i standard symbolske uttrykk fra Lisp, som gjør det lett å lese, parse og skrive. Dette mellomformatet er instruksjoner om hvordan rapporten skal se ut, og inneholder alle data som behøvs for å generere det endelige dokumentet. Dette dokumentet blir så gitt videre til en ny kompilator. Denne kompilatoren genererer den endelige rapporten, og forskjellige generatorer vil generere forskjellige typer og formater av rapporter. En kan tenke seg klartekstrapporter, e-post rapporter som formaterer om til en e-post som kan sendes direkte til mottakere, ODF-rapporter |ODF = Open Document Format| for å overholde EU-standarden for offentlig kommunikasjon, eller LaTeX rapporter, som kan bli kompilert med LaTeX kompilatorer om til PDF eller PostScript. Mulighetene er mange, men det beste med denne typen løsning er at om et nytt format skulle ta verden med storm, kan en enkelt ta hånd om dette formatet vha. å skrive en ny viderekompilator som en plugin for AuRa.

En tredje stor fordel med AuRa er at alle kildene som oppgis er uavhengig av hverandre. Dermed kan en teoretisk generere delene av rapporten paralellt, og kan dermed gjøre ting enda raskere og mer effektivt enn en vanlig seriell kompilering. Der en i en tradisjonell skriptingløsning ville kunne kjørt GNU Make, og latt den gjøre alle oppgavene serielt, kan en nå paralellisere denne type oppgaver i AuRa. Dette er ikke støttet per i dag, men er en opplagt forbedring som kan gjøres i nyere utgaver.

Den fjerde store fordelen som allerede er nevnt er at det er lett å skrive verktøy til denne type språk. Det er altså ikke slik at en må skrive AuRa for hånd, men kan bruke eventuelle GUI-verktøy til å sette opp prosjektet, si hva som skal gjøres, og så generere AuRa-filene fra disse dataene. Tekstfilene som blir genererte vil fortsatt være forståelige, siden formatet er designet til å være enkelt. Store rapporter med hundrevis av deler kan være kjedelig å lese gjennom, men er likeledes ikke vanskelig å skumme eller søke gjennom.

Sett under ett gir dette en fleksibilitet som per dags dato mangler i andre større løsninger. Satt sammen med et enklere språk å skrive i, som er lettere å vedlikeholde og kan bli generert av brukervennlige programmer minskes problemene med tradisjonelle skriptløsninger. Samtidig har vi en økt smidighet sammenlignet med mekanismene som tilbys av automatiseringsløsninger. 


## Hva finnes fra før? ##

### Automate (Kilde: http://www.networkautomation.com/) ###
(kilde:https://www.networkautomation.com/solutions/automated-report-generation-and-distribution/)
Automate er et system for å generere rapporter automatisk vha. en GUI, hvor en kan dra og slippe rapportenheter. Systemet lover automatisk generering av rapporter uten å måtte skrive en linje kode, for alle støttede filkilder. Rapportgenereringen er en integrert del av en større pakke de tilbyr.

De viktigste forskjellene mellom AuRa som er foreslått, og AutoMate sin rapportgenerering er:

 - AutoMate er et ferdig program fra begynnelse til slutt, mens AuRa er ment til å integreres med andre løsninger.
 - AutoMate tilbyr ODS formatet på dokumentene, mens AuRa tilbyr alle formater som kan støttes med en kompilator-plugin.
 - AutoMate er ikke ment til å kunne programmeres, mens for AuRa er det et poeng at du kan programmere det enkelt og smertefritt. Til dømes, i deres case study (kilde: http://www.networkautomation.com/news/case-studies/25/) påpekes det at AutoMate kan lett stilles inn til å trekke ned data, lage en rapport, og skrive den ut. I AuRa, ville en tilsvarende løsning vært å bruke lpr/lpd og cron til å automatisere mtp tid og utskrift.

For å oppsummere, er AuRa mer som et forenklet skriptspråk, med enkle kommandoer ment for å gjøre skriving av en spesiell type skript enklere og raskere. Der AutoMate er en programpakke som gjør jobben fra ende til ende, er AuRa ment til å være et verktøy som integreres med andre verktøy til en komplett pakke.

Det finnes også andre kommersielle pakker for generell automasjon, som til dømes AutomationAnywhere, men de er tilstrekkelig like til at de ikke trenger egen behandling.

### Pandoc ###

Pandoc er et program som oversetter fra et dokumentformat til et annet. Derfor er det interessant fordi det parser dokumenter og lager dokumenter ut av dem.
Per i dag kan du selvsagt skripte handlinger som å hente data ut fra en server, du kan skripte numerisk analyse vha. statistiskkprogrammer som til dømes R, og du kan lime sammen mange filer til en stor fil og sende det til et program, som for eksempel en LaTeX kompilator, som kan lage pdf-en din.

Men du må altså gjøre det for hånd. Og selv om du kan sette opp make til å kjøre skriptene som henter ut og behandle dataene, og deretter lime det sammen via cat til en enhetlig fil som kan kompileres, er du begrenset til et format som du kan evt. kompilere vha. programmer som for eksempel Pandoc.

En kan også tenkes å bruke AutoMate som tidligere nevnt, og konvertere OpenDocument formatet den gir deg til PDF, eller legge til forståelse for mellomformatet til AuRa i Pandoc, og så bruke Pandoc til å konvertere. Pandoc er et nyttig program, som er interessant for dets evne til å forstå dokumenter, men det er altså ikke et system for å generere dokumenter, men å knovertere dem.

## Inspirasjoner ##

AutoMate og dets konkurrenter har tilbudt løsninger som er store og integrerte. De fungerer som monolittiske entiteter, og er dermed ikke enkle å integrere i andre løsninger. De er ment til å integrere andre løsninger til seg, vha. støtte for å bevege musen, trykke på tastaturet, med mer.

Til sammenligning har en andre systemer som Ant og Make som er bygd opp rundt UNIX-filosofien§taop§, der programmer kan integreres med og mot hverandre enkelt og ukomplisert.

## Hva er nytt? ##

Det finnes rapportgenereringsverktøy til salgs per dags dato. Det som er nytt med dette verktøyet er at det er utformet som et enkelt språk. Dette språket er lett å parse, det er lett å skrive, og det er lett å lese. Denne enkelheten gjør at andre verktøy kan bruke systemet til å produsere rapporter med. En kan også skrive sine egne "programmer" for hånd på den måten. For eksempel kan en skrive en masteroppgave i Markdown, og kompilere med AuRa, og få ut en PDF. Denne enkle integrasjonen med og mot andre verktøy gir nye muligheter for integrering og oppgaveflyt. Mens andre systemer lar en kale andre programmer for å lage rapporten, kan en her generere rapporten programmatisk.

## Hva er ikke nytt? ##

Ideen om å ha et enkelt språk som beskriver handlinger er selvsagt ikke nytt, og skriptspråk som for eksempel BASH eller PERL er eksempler på slikt.

GNU Make og Ant er begge byggesystemer som kunne blitt brukt i en del av systemet selv. Disse systemene har metoder for å definere mål som du deretter kan be dem utføre. Til dømes kan du be Make om å bygge et prosjekt, installere det, avinstallere det, rydde opp midlertidige filer og annet.

I rapportgeneratoren derimot, peker du på en fil som definerer prosjektet, og sier hvilket format som skal benyttes. Det er bare ett mål.
Make er veldig fint til å kjøre kommandoer før rapporten bygges, da kan en sikre seg ferske data, slik at en alltid bruker oppdaterte tall.
Dette kunne blitt bygget inn i systemet, men tidsbegrensinger og tilstedeværelsen av make gjorde det unødvendig.

Plugin-systemet er mye likt Emacs sitt system, som er enkelt å drifte, selv om det ikke er ferdig artikulert. Det har manuell håndtering av avhengigheter, og hver plugin antas å kun avhenge av hovedsystemet, eller komme med avhengighetene selv.

## Hva er målet med oppgaven? ##

Målet med oppgavene er altså å argumentere for et nytt språk. Et språk som kan brukes til å generere rapporter automatisk og er utelukkende fokusert på dette formålet. Dette språket lar en generere rapporter enkelt og løser dermed problemet med generiske shellscripts ved å være lettere å vedlikeholde, ved å være et enklere språk med tydeligere syntaks. Videre vil et enkelt språk la en generere rapportbeskrivelser programmatisk vha. tredjeparts programmer som kan integrere mot dette systemet.

Rapporter her er ikke bare ting som salgsrapporter eller ledige sykesenger per dag eller slikt, men kan også være resultater av undersøkelser med mer.
Ved å velge å ikke tilby mer enn nødvendig i språket, men heller tilby å bruke andre språk er dette også et kall* til UNIX-tradisjonene med flere små programmer som er lette å lære, bruke, og koble sammen.

Hvis du allerede bruker R, hvorfor ikke fortsette å bruke R, og heller bruke resultatene i en rapport uavhengig? Og hvorfor ikke ha et byggesystem for slike rapporter? Dersom du kan ha kontinuerlig integrering (Continous Integration) i alle ledd helt ned til rapporten som leveres til slutt, vil det være bedre for alle involverte. Du må selvsagt ikke bruke R. Du kan også bruke Python, Julia, Java, eller andre programmer. Poenget er å appellere til valgfrihet, og åpne opp for bruken av flere verktøy, istedenfor å låse brukere fast til bare et av dem.

Videre er det også et argument, ikke bare for et språk, men også et rammeverk for å skrive rapporter i. I stedenfor å beskrive rapporter for hånd kjedsommelig, vil jeg argumentere for at å ha et system som gjør det lett å automatisere denne type oppgaver vil være til det felles beste.

Det er dermed ikke et argument for at AuRa og dets konvensjoner er de beste konvensjonene som kan tenkes, men et argument for at å ha konvensjoner og et språk er et steg opp fra å ikke ha dem. Helintegrerte programpakker som AutoMate kan bruke systemer som AuRa, men det kan også enklere systemer som Makefiler, eller shellscript eller et fullblods skrivebordsprogram som trenger å lage dokumenter.

Byggesystemer som Make, Ant, Rake og lignende har et bruksområde for å generere informasjon, tilbakemeldinger til programmerere og lignende. AuRa vil kunne gjøre dette arbeidet enklere ved å kunne generere e-poster, html-sider eller PDF-rapporter som kan sendes til relevante mennesker.
Generiske rapporteringsoppgaver som for eksempel ledige senger ved sykehus, en pasientjournal for de siste 14 dagene pasienten har blitt innlagt, med journal og notater fra sykesengen vil kunne lages automatisk og sendes til legen uten at hun må etterspørre dette.

Det er mange muligheter med et slikt system, og å gjøre det enklere å få informasjon ut fra datamaskiner og inn i hendene til mennesker som trenger det vil kunne gjøre livet enklere for mange.

*Eller evt. et kjærlighetsbrev til denne tradisjonen, men dette er en seriøs akademisk tekst, blottet for humor og selvinnsikt.
