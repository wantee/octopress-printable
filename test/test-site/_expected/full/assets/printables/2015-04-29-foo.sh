pandoc -s -N  --include-in-header=assets/printables/2015-04-29-foo.pdf.header.tex assets/printables/2015-04-29-foo.pdf.markdown -o assets/printables/2015-04-29-foo.tex 
xelatex -shell-escape -output-directory=assets/printables -no-pdf --interaction=nonstopmode assets/printables/2015-04-29-foo >/dev/null
bibtex assets/printables/2015-04-29-foo >/dev/null
xelatex -shell-escape -output-directory=assets/printables -no-pdf --interaction=nonstopmode assets/printables/2015-04-29-foo >/dev/null
xelatex -shell-escape -output-directory=assets/printables --interaction=nonstopmode assets/printables/2015-04-29-foo >/dev/null