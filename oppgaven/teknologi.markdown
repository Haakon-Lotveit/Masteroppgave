# Teknologi #

Teknologiene som ble brukt for å lage prosjektet er Common Lisp, Quicklisp, GNU Make, GNU Bash, samt flere Common Lisp biblioteker.

## Common Lisp ##

Common Lisp er et generelt programmeringsspråk, hvis standard er publisert av ANSI[ADD-CITE].
Språket går tilbake til LISP, som ble først utgitt i 1959[ADD-CITE].

I følge https://common-lisp.net/ er Common Lisp er et moderne kompilert  multiparadigme språk som har høy ytelse. (SBCL har også en kompilator, men kan også bruke kun en tolk. [ADD-CITE] (Se manpages?)

Common Lisp har blitt brukt som implementasjonsspråk av flere grunner, først og fremst for dens støtte for høyereordens funksjoner, gode objektorienteringsmodell, robuste typesystem, og tilgjengelige verktøy. (SLIME, Quicklisp, et al.)

## Quicklisp ##
Quicklisp er et avhengighetshåndteringssystem for Common Lisp, likt Maven[ADD-CITE] eller Ivy[ADD-CITE] for Java, eller PIP for Python[ADD-CITE] med noen forskjeller.
Den største er at Quicklisp kan benyttes som en del av programmet, og ikke kun kjøres ved bygging. En kan for eksempel be om å opptadere avhengigheter ved oppstart av programmet, eller sjekke og om nødvendig laste ned avhengigheter ved oppstart, istedenfor den mer ortodokse metoden brukt i Java, der Maven laster ned avhengigheter ved bygging en og bare en gang.

Quicklisp bygger på ASDF (Another System Definition Facility) som tok over etter et annet verkøy for å definere systemer, kalt DEFSYS?[ADD-CITE]

Den største fordelen med Quicklisp som gjør at det passer bedre sammen med Common Lisp sin programmeringsmodell er at den kan gjøre oppslag i sanntid mens systemet kjører. Da kan en legge til avhengigheter løpende mens en bedriver utforskende programmering. Sammenlign med til dømes Python, der PIP kjører utenom, og du er ment til å starte et skall for å kjøre PIP der. Quicklisp kjører som en del av Lisps REPL, og du kan dermed bruke de samme verktøyene til å håndtere Quicklisp som du bruker til all annen lisp kode. Du kan for eksempel autofullføre navn på avhengigheter.

## GNU Make ##
Make er et godt gammelt verktøy for å automatisere byggejobber. Siden byggingen av prosjektet ikke er spesielt komplisert, og Common Lisp er plattformuavhengig, er Make et trygt valg for å automatisere deler av byggingen.

## GNU Bash ##

Bash ble brukt som shell til alle shellskript, siden det er en de-facto standard i Unix-verdenen (Blir levert på OSX, Ubuntu, RHEL, Fedora, AIX, og er tilgjengelig på freeBSD og openBSD.[ADD-CITE])

