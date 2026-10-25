TPFVER := $(shell awk '/ProvidesExplPackage\{tcbpagefootnote\}/{getline; split($$0, a, "[{}]"); print a[4]}' tcbpagefootnote.sty)

DOCS := tcbpagefootnote.pdf

.PHONY: ctanzip
ctanzip: tcbpagefootnote.zip ## Archive for CTAN upload
tcbpagefootnote.zip: clean $(DOCS)
	git archive --format=tar --prefix=tcbpagefootnote/ HEAD | gtar -x
	## remove unpacked files
	cd tcbpagefootnote/ && \
		rm -f .gitignore Makefile ctan.toml
	## then, now just make archive
	zip -9 -r tcbpagefootnote.zip tcbpagefootnote/*
	rm -rf tcbpagefootnote
	@echo finished

.PHONY: tcbpagefootnote.pdf
tcbpagefootnote.pdf: tcbpagefootnote.tex tcbpagefootnote.sty
	pdflatex -interaction=nonstopmode -halt-on-error $<
	pdflatex -interaction=nonstopmode -halt-on-error $<

## Run the test suite ($(TPFVER)):
##  * every test compiles without errors
##  * TPF-RESULT OK and no TPF-* NG: every footnote text is typeset once,
##    with its own mark, where it is expected (see test-common.tex)
##  * test-breakable-*: exactly one tcbpagefootnote warning;
##    the others: none
##  * test-hyperref-*: no warning on a duplicate or missing destination
##    in the log or in the output of the engine and (x)dvipdfmx
##  * test-errors-*: the expected error message
## A test is "<engine>:<jobname>:<input>".  The output of the engine and
## of (x)dvipdfmx is kept in <jobname>.term.
TESTS := \
  pdflatex:test-basic-pdflatex:'\input test-basic' \
  xelatex:test-basic-xelatex:'\input test-basic' \
  lualatex:test-basic-lualatex:'\input test-basic' \
  lualatex:test-basic-ltjsarticle-lualatex:'\def\CLS{ltjsarticle}\input test-basic' \
  platex:test-basic-platex:'\def\CLS{jarticle}\input test-basic' \
  uplatex:test-basic-uplatex:'\def\CLS{ujarticle}\input test-basic' \
  pdflatex:test-hyperref-pdflatex:'\input test-hyperref' \
  xelatex:test-hyperref-xelatex:'\input test-hyperref' \
  lualatex:test-hyperref-lualatex:'\input test-hyperref' \
  platex:test-hyperref-platex:'\def\CLS{jarticle}\input test-hyperref' \
  uplatex:test-hyperref-uplatex:'\def\CLS{ujarticle}\input test-hyperref' \
  pdflatex:test-breakable-pdflatex:'\input test-breakable' \
  xelatex:test-breakable-xelatex:'\input test-breakable' \
  lualatex:test-breakable-lualatex:'\input test-breakable' \
  platex:test-breakable-platex:'\def\CLS{jarticle}\input test-breakable' \
  uplatex:test-breakable-uplatex:'\def\CLS{ujarticle}\input test-breakable' \
  lualatex:test-japanese-lualatex:'\input test-japanese' \
  platex:test-japanese-platex:'\def\CLS{jbook}\input test-japanese' \
  uplatex:test-japanese-uplatex:'\def\CLS{ujbook}\input test-japanese'

## "<case>:<error message>" of test-errors.tex (pdflatex)
ERRORS := \
  float:"cannot be used with" \
  after:"no longer" \
  defined:"is already"

.PHONY: test
test:
	@set -e; \
	for t in $(TESTS); do \
	  eng=$${t%%:*}; rest=$${t#*:}; job=$${rest%%:*}; in=$${rest#*:}; \
	  echo "== $$eng $$job"; \
	  rm -f $$job.aux $$job.dvi $$job.xdv; \
	  opt=; if [ $$eng = xelatex ]; then opt=-no-pdf; fi; \
	  $$eng $$opt -interaction=nonstopmode -jobname=$$job "$$in" >$$job.term 2>&1 || true; \
	  if [ -f $$job.dvi ]; then dvipdfmx $$job.dvi >>$$job.term 2>&1; fi; \
	  if [ -f $$job.xdv ]; then xdvipdfmx $$job.xdv >>$$job.term 2>&1; fi; \
	  if grep -q '^!' $$job.log; then echo "NG: error in $$job.log"; exit 1; fi; \
	  if grep -q '^TPF-.* NG' $$job.log; then grep '^TPF-.* NG' $$job.log; exit 1; fi; \
	  grep -q '^TPF-RESULT OK' $$job.log || \
	    { echo "NG: no TPF-RESULT OK in $$job.log"; exit 1; }; \
	  nwarn=`grep -c 'tcbpagefootnote Warning' $$job.log || true`; \
	  case $$job in test-breakable-*) want=1;; *) want=0;; esac; \
	  [ $$nwarn -eq $$want ] || \
	    { echo "NG: $$nwarn tcbpagefootnote warning(s) in $$job.log, want $$want"; exit 1; }; \
	  case $$job in test-hyperref-*) \
	    if cat $$job.log $$job.term | \
	      grep -i 'duplicate\|already defined\|does not exist\|unreferenced destination'; then \
	      echo "NG: destination warning in $$job.log or $$job.term"; exit 1; fi;; \
	  esac; \
	done; \
	for e in $(ERRORS); do \
	  c=$${e%%:*}; msg=$${e#*:}; job=test-errors-$$c; \
	  echo "== pdflatex $$job"; \
	  pdflatex -interaction=nonstopmode -jobname=$$job "\def\CASE{$$c}\input test-errors" >$$job.term 2>&1 || true; \
	  grep -q "^! Package tcbpagefootnote Error: .*$$msg" $$job.log || \
	    { echo "NG: no expected error in $$job.log"; exit 1; }; \
	done; \
	echo "All tests passed ($(TPFVER))"

.PHONY: clean
clean: ## Clean this repository
	rm -rf tcbpagefootnote.zip tcbpagefootnote
	rm -f *.aux *.log *.out *.toc *.dvi *.xdv *.synctex.gz *.term
	rm -f test-*.pdf
	find . -type f -name "*~" -delete
