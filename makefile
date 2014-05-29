# Kompiler ned tex-filen
make: førsteutkast.tex
	pdflatex førsteutkast.tex && pdflatex førsteutkast.tex && bibtex førsteutkast.aux && pdflatex førsteutkast.tex

view: make
	evince førsteutkast.pdf
