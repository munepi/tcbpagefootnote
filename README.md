# tcbpagefootnote Package

**LaTeX: Page footnotes from inside tcolorbox**

tcolorbox typesets the content of a box like a minipage: a `\footnote` inside the box is numbered with the `mpfootnote` counter (as a, b, c) and its text is put at the bottom of the box.

The tcbpagefootnote package adds the tcolorbox key `page footnote`. With it, the footnotes in the title, the upper part and the lower part of the box

1. are numbered with the `footnote` counter and `\thefootnote`, along with the footnotes of the body text, and
2. are put at the bottom of the page where the box is: their texts are collected while the box is typeset and are put into the ordinary footnote insertion right after the box. If the box moves to the next page, its footnotes move with it.

`\footnote[<number>]`, `\footnotemark` with `\footnotetext`, `\tcbox`, and boxes with `page footnote` inside each other work as usual. With hyperref, each footnote mark links to its own footnote text.

**Breakable boxes.** A `breakable` box that is broken across pages puts each footnote text on the page of its mark, like the body text does, and each part of the box leaves room for its footnotes. This is done in one run, in a way that depends on the engine. With LuaLaTeX, the footnote texts are real insertions at their marks; when tcolorbox splits the content of the box, each part keeps the insertions of its marks, and tcbpagefootnote moves them out of the part to its page (`tcbpagefootnote.lua`). With the other engines, each footnote text is typeset at its mark and kept in a box, and a TeX mark (`\marks`) at the footnote mark tells which part the footnote belongs to; the content is split again, from a copy, until the part and its footnotes fit.

**Breakable boxes inside breakable boxes.** tcolorbox does not break a box inside another box. With the tcbnestbreak package it does: a `breakable` box inside a `breakable` box is broken together with the outer box. If both boxes have `page footnote`, the footnotes of the inner box are put on the pages of their marks as well.

**Tagged PDF.** With the new footnote code of LaTeX (loaded e.g. by `\DocumentMetadata{tagging=on}`), the footnote text is typeset where its mark is, as in a minipage, and the typeset text is put into the footnote insertion after the box. In the structure tree, the footnote (`FENote`) then directly follows its mark (`Lbl`), as for a footnote in the body text ([latex3/tagging-project#1709](https://github.com/latex3/tagging-project/issues/1709)).

**Vertical writing.** `page footnote` also works in tate, with the tate classes of pLaTeX and upLaTeX (e.g. `tarticle` and `utarticle`) and of LuaTeX-ja (e.g. `ltjtarticle`). With pLaTeX and upLaTeX, load the [pxpgftate](https://ctan.org/pkg/pxpgftate) package as well: without it, TikZ/PGF, and so tcolorbox, draws the boxes sideways in tate. tcbpagefootnote does not load it itself.

```latex
\documentclass[dvipdfmx]{tarticle}
\usepackage{tcbpagefootnote}
\usepackage{pxpgftate}
```

* **Supported formats/engines:** pdfLaTeX, XeLaTeX, LuaLaTeX (with or without LuaTeX-ja), pLaTeX, upLaTeX (+ dvipdfmx); yoko and tate

## Files

| File | Description |
|---|---|
| `tcbpagefootnote.sty` | The package |
| `tcbpagefootnote.lua` | Lua code for breakable boxes (LuaLaTeX) |
| `tcbpagefootnote.tex` / `.pdf` | Documentation |
| `test-*.tex` | Test suite (see below) |

## Requirements

* `tcolorbox` (the `hooks` library is loaded by the package)
* Tested with TeX Live 2025 (frozen: LaTeX2e 2025-11-01, tcolorbox 6.9.0) and TeX Live 2026 (LaTeX2e 2026-11-01, tcolorbox 6.10.0)
* For tate with pLaTeX and upLaTeX: `pxpgftate` (in TeX Live from 2026 on; with TeX Live 2025, install it from CTAN)

## Installation

Copy `tcbpagefootnote.sty` and `tcbpagefootnote.lua` to your local TeX tree:
`$TEXMF/tex/latex/tcbpagefootnote/`

## Usage

```latex
\usepackage{tcbpagefootnote}

\begin{tcolorbox}[title=Note, page footnote]
  Text\footnote{A page footnote.}.
\end{tcolorbox}

\newtcolorbox{note}[1][]{colback=blue!5, page footnote, #1}
\tcbset{page footnote}  % for every box
```

## Errors, warnings and limitations

* `page footnote` cannot be used with `float` (error).
* Keys that set the whole `after` code (such as `after`, `after skip` and `nobeforeafter`) remove the code that puts the footnotes when they come after `page footnote` (error): give them before it, e.g. `[after skip=1pt, page footnote]`.
* In a `multicols` environment, where the footnotes are below all the columns, and inside another box such as a `minipage`, a `breakable` box that is broken puts the footnote texts of all its parts where the box ends, and the package warns.
* With an engine other than LuaTeX, a footnote inside a box of the content of a broken box (e.g. a `\footnotetext` in a `tabular`) can be put on the page after that of its mark: TeX does not see the mark of such a footnote when the content is split. Also, the footnote text is typeset through `\@footnotetext` with `\insert` redefined; a class or package whose `\@footnotetext` does not use `\insert\footins` is not supported there.
* With LuaLaTeX, the part of a broken box on a page that has no footnote before the box can be up to `\skip\footins` (the space above the footnotes) shorter than without `page footnote`, when the part has no footnote but the rest of the box has one.
* With pLaTeX and upLaTeX in tate, a `\footnotetext` in vertical mode (e.g. right after a box) does not work with the new footnote code of LaTeX (`\DocumentMetadata`), with or without this package. Put it in a paragraph.

## Testing

`make test` compiles every test with pdfLaTeX, XeLaTeX, LuaLaTeX, pLaTeX and upLaTeX (+ dvipdfmx), and checks the log. `make test TEXBIN=<directory of the binaries>` runs the tests with another TeX Live than the one in `PATH`; `PXPGFTATE=<directory>` (default: `../pxpgftate`) is where pxpgftate is taken from if that TeX Live does not have it.

* `TPF-RESULT OK`: every footnote text is typeset exactly once, with its own mark, on the expected page, as a page footnote or as a footnote of the box (recorded at shipout to the `.aux` file and checked when it is read back at `\end{document}`; see `test-common.tex`).
* `test-hyperref`, `test-tagging-hyperref`: no warning on a duplicate or missing destination in the log or in the output of the engine and (x)dvipdfmx.
* No tcbpagefootnote warning in any test.
* `test-breakable-long`: no overfull page and no split footnote (`% split` of `\tracingpages`) in the log.
* `test-tagging` (pdflatex, xelatex, lualatex): `test-tagging.lua` reads the structure tree with `show-pdf-tags` and finds every `FENote` right after its `Lbl`, except the two `\footnotemark` whose texts are given later by `\footnotetext`.
* `test-tate`: the same checks as for `test-basic`, `test-breakable` and `test-breakable-long`, in tate.
* `test-nested` (if tcbnestbreak is in `../tcbnestbreak`, or in `TNB=<directory>`): every footnote text is on the page of its mark, no overfull page and no split footnote; also with hyperref, with tagging and in tate.
* `test-errors`: the expected error message.

| Test | Engines | What it covers |
|---|---|---|
| `test-basic.tex` | pdflatex, xelatex, lualatex (article, ltjsarticle), platex, uplatex | title/upper/lower, several footnotes, `\footnote[9]`, `\footnotemark`/`\footnotetext`, nested boxes, an ordinary box, `\tcbox`, `\newtcolorbox`, `\tcbset`, a box moved to the next page |
| `test-hyperref.tex` | pdflatex, xelatex, lualatex, platex, uplatex | `test-basic.tex` with hyperref |
| `test-breakable.tex` | pdflatex, xelatex, lualatex, platex, uplatex | a box broken by `\tcbbreak` with footnotes in its title, upper and lower part (each footnote on the page of its mark), an unbroken breakable box, an unbreakable box after a broken one |
| `test-breakable-long.tex` | pdflatex, xelatex, lualatex (article, ltjsarticle), platex (jarticle, jsarticle), uplatex; with hyperref | boxes that TeX breaks across several pages: a box that starts in the middle of a page, footnotes of one and of several lines in every part, a footnote only in the last part, `height fixed for`, boxes inside a broken box |
| `test-nested.tex` | pdflatex, xelatex, lualatex (article, ltjsarticle), platex, uplatex; with hyperref, with tagging, in tate | with tcbnestbreak: breakable boxes with `page footnote` inside a breakable box, three levels deep, with footnotes in a title and in a lower part; an unbreakable box inside; a box without the key |
| `test-japanese.tex` | lualatex (ltjbook), platex (jbook), uplatex (ujbook) | a Japanese document |
| `test-tagging.tex` | pdflatex, xelatex, lualatex, platex, uplatex | `test-basic.tex` (and `test-breakable.tex`, `test-breakable-long.tex`, `test-japanese.tex`, with hyperref) with `\DocumentMetadata{tagging=on}`; pLaTeX and upLaTeX do not write a structure tree, so only the log is checked |
| `test-tate.tex` | platex (tarticle), uplatex (utarticle), lualatex (ltjtarticle) | `test-basic.tex`, `test-breakable.tex` and `test-breakable-long.tex` in tate, with pxpgftate for pLaTeX and upLaTeX |
| `test-errors.tex` | pdflatex | the error messages (`float`, `after`, key already defined) |

`test-common.tex` holds the helpers shared by the tests, and `test-tagging.lua` the check of the structure tree.

## Repository

* <https://github.com/munepi/tcbpagefootnote>
* Bug reports: <https://github.com/munepi/tcbpagefootnote/issues>

## License

This package is licensed under the conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl.txt), either version 1.3c of this license or any later version.

Copyright (c) 2026 Munehiro Yamamoto
