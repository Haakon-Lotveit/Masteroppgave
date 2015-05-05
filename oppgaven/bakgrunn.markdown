# Bakgrunn #

## Hvorfor lage AuRa? ##
Poenget med AuRa er ikke å gjøre

## Hvorfor lage AuRa? ##
En må per i dag lage rapporter som bygger på data.
Datamaskinen din vet hva dataene er, den kan sannsynligvis lage ting utav dataene, og alt du egentlig har lyst til er å trykke på knappen, og få en pdf-fil, eller et annet format. (Docbook, docx, postscript, html eller annet.)

Dette er egentlig mulig å lage fra før av. Alt som kreves er kunnskap til:
Shell-scripting, uthenting av dataene dine, GNU Make, Pandoc, og minst et markup-språk til å skrive i, kompilatoren til nevnte språk, og kommandolinjer.

Dette er tungvint og burde ikke være nødvendig. En bedre løsning ville vært å kunne spesifisere datakilder, rekkefølgen de skulle brukes i, og deretter utdataformatet. Da må du vite om et fornatet for å spesifisere inndatakildene, et format for markup (Markdown er valgt) til å kunne skrive brødtekst med, og nok kunnskap til databasene til å kunne hente ut dataene. Dersom du i tillegg kan skripte uthenting av data, er det gjort. Du kan da "trykke på knappen" så å si, og deretter få en rapport raskt og enkelt. Så kan du finskrive den etterpå. Da må du gjøre mindre unødvendig jobb, og kan få gjort mer med tiden din.

Et annet poeng med et slikt format er at formatet er veldig enkelt, og dermed lett for verktøy å operere med. En kan dermed skrive verktøy som lager denne type filer, og kjøre dem, og en kan lage dem med gode brukervennlige grensesnitt. Da blir programmet mer brukbart for flere mennesker, uten at det går på bekostning av de som kjenner programmet, og vil skrive selv. En kan også skrive verktøy som gjør den prosessen enklere.

Det finnes også verktøy som gjør jobben fra ende til ende, men AuRa er ment til å være et annet type verktøy med en annen filosofi. Ved å gjøre det enklere å integrere mot andre verktøy, og ved å være enkel å forstå vha. rene tekstformater er AuRa ment til å redusere behovet for store programpakker, ikke å være et. Dette har konsekvenser for bruk og forståelse av programmet som blir diskutert senere.

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


*Eller evt. et kjærlighetsbrev til denne tradisjonen, men dette er en seriøs akademisk tekst, blottet for humor og selvinnsikt.
