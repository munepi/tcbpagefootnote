TPFVER := $(shell awk '/ProvidesExplPackage\{tcbpagefootnote\}/{getline; split($$0, a, "[{}]"); print a[4]}' tcbpagefootnote.sty)

DOCS := tcbpagefootnote.pdf

## The TeX Live to test with: the directory of its binaries, e.g.
##   make test TEXBIN=/usr/local/texlive/2025/bin/universal-darwin
## (default: the one in PATH)
TEXBIN ?=

## The tcbnestbreak package for test-nested.tex; the tests with it are
## skipped if it is not there.
TNB ?= ../tcbnestbreak

## The pxpgftate package for the tests in tate with pLaTeX and upLaTeX,
## used if the TeX Live does not have it (TeX Live 2025); these tests
## are skipped if it is in neither place.
PXPGFTATE ?= ../pxpgftate

## The footnotenosplit package for the tests with it (test-*nosplit-*),
## used if the TeX Live does not have it (TeX Live 2025); these tests
## are skipped if it is in neither place.
FNS ?= ../footnotenosplit

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
##  * no tcbpagefootnote warning
##  * test-*breakable-long-*: no overfull page and no split footnote
##    ("% split" of \tracingpages)
##  * test-*twocolumn-*: the two columns of LaTeX, also with ftnright;
##    no overfull page, no split footnote, and the parts of the boxes
##    are in the expected columns (TPF-COLUMN)
##  * test-*width-*: code around \@footnotetext sets the footnotes of
##    the page in another width (\TPFwidth of test-common.tex), also
##    with tagging; a page footnote has this width
##  * test-*hyperref-*: no warning on a duplicate or missing destination
##    in the log or in the output of the engine and (x)dvipdfmx (the
##    info "mathml file ... does not exist" of tagging is ignored)
##  * test-tagging-*: run twice with \DocumentMetadata{tagging=on}; with
##    pdflatex, xelatex and lualatex, test-tagging.lua finds every
##    footnote (FENote) right after its mark (Lbl) in the structure
##    tree, except the two \footnotemark of test-basic.tex (not for
##    test-tagging-japanese-*: the marks of ltjbook are not tagged as Lbl)
##  * test-tate-*: vertical writing (tarticle, utarticle, ltjtarticle);
##    the same checks as in yoko
##  * test-*nested-* (with tcbnestbreak in $(TNB)): breakable boxes
##    inside a breakable box; no overfull page and no split footnote.
##    With tagging, the footnote of the box without "page footnote" is
##    the one unpaired mark
##  * test-*nosplit-* (with footnotenosplit): TPF-RULE OK: no page has
##    a footnote rule without a footnote, and the first footnote below
##    the rule is as far from it on every page (\TPFnosplit of
##    test-common.tex); no warning of footnotenosplit and no "pop empty
##    color page stack".  test-nosplit.tex has footnotes that TeX
##    moves to the next page; the other tests are run as they are
##    (*-nosplit-*; "first": footnotenosplit is loaded first)
##  * test-errors-*: the expected error message
## A test is "<engine>:<jobname>:<input>".  The output of the engine and
## of (x)dvipdfmx is kept in <jobname>.term.
## $(TNB), $(PXPGFTATE) and $(FNS) are put into TEXINPUTS only for the tests
## that need them: a directory with files of the same job names (as
## the tests of tcbnestbreak have) must not be searched by the other
## tests.
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
  pdflatex:test-breakable-long-pdflatex:'\input test-breakable-long' \
  xelatex:test-breakable-long-xelatex:'\input test-breakable-long' \
  lualatex:test-breakable-long-lualatex:'\input test-breakable-long' \
  lualatex:test-breakable-long-ltjsarticle-lualatex:'\def\CLS{ltjsarticle}\input test-breakable-long' \
  platex:test-breakable-long-platex:'\def\CLS{jarticle}\input test-breakable-long' \
  platex:test-breakable-long-jsarticle-platex:'\def\CLS{jsarticle}\input test-breakable-long' \
  uplatex:test-breakable-long-uplatex:'\def\CLS{ujarticle}\input test-breakable-long' \
  pdflatex:test-hyperref-breakable-long-pdflatex:'\def\TPFhyperref{1}\input test-breakable-long' \
  xelatex:test-hyperref-breakable-long-xelatex:'\def\TPFhyperref{1}\input test-breakable-long' \
  lualatex:test-hyperref-breakable-long-lualatex:'\def\TPFhyperref{1}\input test-breakable-long' \
  platex:test-hyperref-breakable-long-platex:'\def\CLS{jarticle}\def\TPFhyperref{1}\input test-breakable-long' \
  uplatex:test-hyperref-breakable-long-uplatex:'\def\CLS{ujarticle}\def\TPFhyperref{1}\input test-breakable-long' \
  pdflatex:test-twocolumn-pdflatex:'\input test-twocolumn' \
  xelatex:test-twocolumn-xelatex:'\input test-twocolumn' \
  lualatex:test-twocolumn-lualatex:'\input test-twocolumn' \
  platex:test-twocolumn-platex:'\input test-twocolumn' \
  uplatex:test-twocolumn-uplatex:'\input test-twocolumn' \
  pdflatex:test-ftnright-twocolumn-pdflatex:'\def\TPFftnright{1}\input test-twocolumn' \
  xelatex:test-ftnright-twocolumn-xelatex:'\def\TPFftnright{1}\input test-twocolumn' \
  lualatex:test-ftnright-twocolumn-lualatex:'\def\TPFftnright{1}\input test-twocolumn' \
  platex:test-ftnright-twocolumn-platex:'\def\TPFftnright{1}\input test-twocolumn' \
  uplatex:test-ftnright-twocolumn-uplatex:'\def\TPFftnright{1}\input test-twocolumn' \
  pdflatex:test-width-pdflatex:'\def\TPFwidth{.75\columnwidth}\input test-basic' \
  lualatex:test-width-lualatex:'\def\TPFwidth{.75\columnwidth}\input test-basic' \
  pdflatex:test-breakable-long-width-pdflatex:'\def\TPFwidth{.75\columnwidth}\input test-breakable-long' \
  lualatex:test-breakable-long-width-lualatex:'\def\TPFwidth{.75\columnwidth}\input test-breakable-long' \
  lualatex:test-japanese-lualatex:'\input test-japanese' \
  platex:test-japanese-platex:'\def\CLS{jbook}\input test-japanese' \
  uplatex:test-japanese-uplatex:'\def\CLS{ujbook}\input test-japanese' \
  pdflatex:test-tagging-pdflatex:'\input test-tagging' \
  xelatex:test-tagging-xelatex:'\input test-tagging' \
  lualatex:test-tagging-lualatex:'\input test-tagging' \
  platex:test-tagging-platex:'\def\CLS{jarticle}\input test-tagging' \
  uplatex:test-tagging-uplatex:'\def\CLS{ujarticle}\input test-tagging' \
  pdflatex:test-tagging-hyperref-pdflatex:'\def\TPFhyperref{1}\input test-tagging' \
  lualatex:test-tagging-hyperref-lualatex:'\def\TPFhyperref{1}\input test-tagging' \
  pdflatex:test-tagging-breakable-pdflatex:'\def\TPFfile{test-breakable}\input test-tagging' \
  lualatex:test-tagging-breakable-lualatex:'\def\TPFfile{test-breakable}\input test-tagging' \
  pdflatex:test-tagging-breakable-long-pdflatex:'\def\TPFfile{test-breakable-long}\input test-tagging' \
  xelatex:test-tagging-breakable-long-xelatex:'\def\TPFfile{test-breakable-long}\input test-tagging' \
  lualatex:test-tagging-breakable-long-lualatex:'\def\TPFfile{test-breakable-long}\input test-tagging' \
  pdflatex:test-tagging-width-pdflatex:'\def\TPFwidth{.75\columnwidth}\input test-tagging' \
  lualatex:test-tagging-width-lualatex:'\def\TPFwidth{.75\columnwidth}\input test-tagging' \
  pdflatex:test-tagging-breakable-long-width-pdflatex:'\def\TPFwidth{.75\columnwidth}\def\TPFfile{test-breakable-long}\input test-tagging' \
  lualatex:test-tagging-breakable-long-width-lualatex:'\def\TPFwidth{.75\columnwidth}\def\TPFfile{test-breakable-long}\input test-tagging' \
  lualatex:test-tagging-japanese-lualatex:'\def\TPFfile{test-japanese}\input test-tagging' \
  platex:test-tate-platex:'\input test-tate' \
  uplatex:test-tate-uplatex:'\def\CLS{utarticle}\input test-tate' \
  lualatex:test-tate-lualatex:'\input test-tate' \
  platex:test-tate-breakable-platex:'\def\TPFfile{test-breakable}\input test-tate' \
  uplatex:test-tate-breakable-uplatex:'\def\CLS{utarticle}\def\TPFfile{test-breakable}\input test-tate' \
  lualatex:test-tate-breakable-lualatex:'\def\TPFfile{test-breakable}\input test-tate' \
  platex:test-tate-breakable-long-platex:'\def\TPFfile{test-breakable-long}\input test-tate' \
  uplatex:test-tate-breakable-long-uplatex:'\def\CLS{utarticle}\def\TPFfile{test-breakable-long}\input test-tate' \
  lualatex:test-tate-breakable-long-lualatex:'\def\TPFfile{test-breakable-long}\input test-tate'

NS := \def\TPFnosplit{1}
NOSPLIT := \
  pdflatex:test-nosplit-pdflatex:'\input test-nosplit' \
  xelatex:test-nosplit-xelatex:'\input test-nosplit' \
  lualatex:test-nosplit-lualatex:'\input test-nosplit' \
  lualatex:test-nosplit-ltjsarticle-lualatex:'\def\CLS{ltjsarticle}\input test-nosplit' \
  platex:test-nosplit-platex:'\def\CLS{jarticle}\input test-nosplit' \
  platex:test-nosplit-jsarticle-platex:'\def\CLS{jsarticle}\input test-nosplit' \
  uplatex:test-nosplit-uplatex:'\def\CLS{ujarticle}\input test-nosplit' \
  pdflatex:test-hyperref-nosplit-first-pdflatex:'\def\TPFfirst{1}\def\TPFhyperref{1}\input test-nosplit' \
  lualatex:test-hyperref-nosplit-first-lualatex:'\def\TPFfirst{1}\def\TPFhyperref{1}\input test-nosplit' \
  pdflatex:test-tagging-nosplit-pdflatex:'\def\TPFfile{test-nosplit}\input test-tagging' \
  xelatex:test-tagging-nosplit-xelatex:'\def\TPFfile{test-nosplit}\input test-tagging' \
  lualatex:test-tagging-nosplit-lualatex:'\def\TPFfile{test-nosplit}\input test-tagging' \
  pdflatex:test-basic-nosplit-pdflatex:'$(NS)\input test-basic' \
  lualatex:test-basic-nosplit-lualatex:'$(NS)\input test-basic' \
  platex:test-basic-nosplit-platex:'\def\CLS{jarticle}$(NS)\input test-basic' \
  pdflatex:test-hyperref-nosplit-pdflatex:'$(NS)\input test-hyperref' \
  lualatex:test-hyperref-nosplit-lualatex:'$(NS)\input test-hyperref' \
  pdflatex:test-breakable-long-nosplit-pdflatex:'$(NS)\input test-breakable-long' \
  xelatex:test-breakable-long-nosplit-xelatex:'$(NS)\input test-breakable-long' \
  lualatex:test-breakable-long-nosplit-lualatex:'$(NS)\input test-breakable-long' \
  platex:test-breakable-long-nosplit-platex:'\def\CLS{jarticle}$(NS)\input test-breakable-long' \
  uplatex:test-breakable-long-nosplit-uplatex:'\def\CLS{ujarticle}$(NS)\input test-breakable-long' \
  pdflatex:test-tagging-basic-nosplit-pdflatex:'$(NS)\input test-tagging' \
  lualatex:test-tagging-basic-nosplit-lualatex:'$(NS)\input test-tagging' \
  pdflatex:test-tagging-breakable-long-nosplit-pdflatex:'$(NS)\def\TPFfile{test-breakable-long}\input test-tagging' \
  lualatex:test-tagging-breakable-long-nosplit-lualatex:'$(NS)\def\TPFfile{test-breakable-long}\input test-tagging' \
  platex:test-tate-breakable-long-nosplit-platex:'$(NS)\def\TPFfile{test-breakable-long}\input test-tate' \
  lualatex:test-tate-breakable-long-nosplit-lualatex:'$(NS)\def\TPFfile{test-breakable-long}\input test-tate'

NESTED := \
  pdflatex:test-nested-pdflatex:'\input test-nested' \
  xelatex:test-nested-xelatex:'\input test-nested' \
  lualatex:test-nested-lualatex:'\input test-nested' \
  lualatex:test-nested-ltjsarticle-lualatex:'\def\CLS{ltjsarticle}\input test-nested' \
  platex:test-nested-platex:'\def\CLS{jarticle}\input test-nested' \
  uplatex:test-nested-uplatex:'\def\CLS{ujarticle}\input test-nested' \
  pdflatex:test-hyperref-nested-pdflatex:'\def\TPFhyperref{1}\input test-nested' \
  lualatex:test-hyperref-nested-lualatex:'\def\TPFhyperref{1}\input test-nested' \
  pdflatex:test-tagging-nested-pdflatex:'\def\TPFfile{test-nested}\input test-tagging' \
  lualatex:test-tagging-nested-lualatex:'\def\TPFfile{test-nested}\input test-tagging' \
  platex:test-tate-nested-platex:'\def\TPFfile{test-nested}\input test-tate' \
  uplatex:test-tate-nested-uplatex:'\def\CLS{utarticle}\def\TPFfile{test-nested}\input test-tate' \
  lualatex:test-tate-nested-lualatex:'\def\TPFfile{test-nested}\input test-tate' \
  pdflatex:test-nested-nosplit-pdflatex:'$(NS)\input test-nested' \
  lualatex:test-nested-nosplit-lualatex:'$(NS)\input test-nested' \
  platex:test-nested-nosplit-platex:'\def\CLS{jarticle}$(NS)\input test-nested'

HASTNB := $(wildcard $(TNB)/tcbnestbreak.sty)

## "<case>:<error message>" of test-errors.tex (pdflatex)
ERRORS := \
  float:"cannot be used with" \
  after:"no longer" \
  defined:"is already"

.PHONY: test
test:
	@set -e; \
	$(if $(TEXBIN),export PATH="$(TEXBIN):$$PATH";) \
	echo "== `pdflatex --version | head -1`"; \
	if kpsewhich pxpgftate.sty >/dev/null 2>&1; then pxp=kpse; \
	elif [ -f $(PXPGFTATE)/pxpgftate.sty ]; then pxp=$(PXPGFTATE); \
	else pxp=; fi; \
	if kpsewhich footnotenosplit.sty >/dev/null 2>&1; then fns=kpse; \
	elif [ -f $(FNS)/footnotenosplit.sty ]; then fns=$(FNS); \
	else fns=; fi; \
	$(if $(HASTNB),,echo "== test-nested skipped: no $(TNB)/tcbnestbreak.sty";) \
	for t in $(TESTS) $(NOSPLIT) $(if $(HASTNB),$(NESTED)); do \
	  eng=$${t%%:*}; rest=$${t#*:}; job=$${rest%%:*}; in=$${rest#*:}; \
	  echo "== $$eng $$job"; \
	  ti=.; case $$job in test-*nested-*) ti="$$ti:$(TNB)";; esac; \
	  case $$job in test-tate-*platex) \
	    case "$$pxp" in "") echo "   skipped: no pxpgftate.sty"; continue;; kpse) ;; *) ti="$$ti:$$pxp";; esac;; \
	  esac; \
	  case $$job in test-*nosplit-*) \
	    case "$$fns" in "") echo "   skipped: no footnotenosplit.sty"; continue;; kpse) ;; *) ti="$$ti:$$fns";; esac;; \
	  esac; \
	  pre="env TEXINPUTS=$$ti:$$TEXINPUTS"; \
	  rm -f $$job.aux $$job.dvi $$job.xdv; \
	  opt=; if [ $$eng = xelatex ]; then opt=-no-pdf; fi; \
	  $$pre $$eng $$opt -interaction=nonstopmode -jobname=$$job "$$in" >$$job.term 2>&1 || true; \
	  case $$job in test-tagging-*) \
	    $$pre $$eng $$opt -interaction=nonstopmode -jobname=$$job "$$in" >$$job.term 2>&1 || true;; \
	  esac; \
	  if [ -f $$job.dvi ]; then dvipdfmx $$job.dvi >>$$job.term 2>&1; fi; \
	  if [ -f $$job.xdv ]; then xdvipdfmx $$job.xdv >>$$job.term 2>&1; fi; \
	  if grep -q '^!' $$job.log; then echo "NG: error in $$job.log"; exit 1; fi; \
	  if grep -q '^TPF-.* NG' $$job.log; then grep '^TPF-.* NG' $$job.log; exit 1; fi; \
	  grep -q '^TPF-RESULT OK' $$job.log || \
	    { echo "NG: no TPF-RESULT OK in $$job.log"; exit 1; }; \
	  nwarn=`grep -c 'tcbpagefootnote Warning' $$job.log || true`; \
	  [ $$nwarn -eq 0 ] || \
	    { echo "NG: $$nwarn tcbpagefootnote warning(s) in $$job.log"; exit 1; }; \
	  case $$job in test-*breakable-long-*|test-*nested-*|test-*twocolumn-*) \
	    if grep 'Overfull .vbox\|^% split' $$job.log; then \
	      echo "NG: overfull page or split footnote in $$job.log"; exit 1; fi;; \
	  esac; \
	  case $$job in test-*nosplit-*) \
	    grep -q '^TPF-RULE OK' $$job.log || \
	      { echo "NG: no TPF-RULE OK in $$job.log"; exit 1; }; \
	    if cat $$job.log $$job.term | \
	      grep 'footnotenosplit Warning\|pop empty color'; then \
	      echo "NG: warning in $$job.log or $$job.term"; exit 1; fi;; \
	  esac; \
	  case $$job in test-*hyperref-*) \
	    if cat $$job.log $$job.term | \
	      grep -i 'duplicate\|already defined\|does not exist\|unreferenced destination' | \
	      grep -v 'mathml file'; then \
	      echo "NG: destination warning in $$job.log or $$job.term"; exit 1; fi;; \
	  esac; \
	  case $$job in test-tagging-*platex|test-tagging-japanese-*) ;; test-tagging-*) \
	    tags=`texlua test-tagging.lua $$job.pdf`; echo "$$tags" >>$$job.term; \
	    case $$job in test-tagging-breakable-*|test-tagging-nosplit-*) want=0;; test-tagging-nested-*) want=1;; *) want=2;; esac; \
	    echo "$$tags" | grep -q "^TPF-TAGS: [1-9][0-9]* paired, $$want unpaired" || \
	      { echo "$$tags"; echo "NG: want $$want unpaired footnote mark(s) in $$job.pdf"; exit 1; };; \
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
