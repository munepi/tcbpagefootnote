# tcbpagefootnote Package

**LaTeX: Page footnotes from inside tcolorbox**

tcolorbox typesets the content of a box like a minipage: a `\footnote` inside the box is numbered with the `mpfootnote` counter (as a, b, c) and its text is put at the bottom of the box.

The tcbpagefootnote package adds the tcolorbox key `page footnote`. With it, the footnotes in the title, the upper part and the lower part of the box

1. are numbered with the `footnote` counter and `\thefootnote`, along with the footnotes of the body text, and
2. are put at the bottom of the page where the box is: their texts are collected while the box is typeset and are put into the ordinary footnote insertion right after the box. If the box moves to the next page, its footnotes move with it.

`\footnote[<number>]`, `\footnotemark` with `\footnotetext`, `\tcbox`, and boxes with `page footnote` inside each other work as usual. With hyperref, each footnote mark links to its own footnote text.

**Breakable boxes.** With LuaLaTeX, a `breakable` box that is broken across pages puts each footnote text on the page of its mark, like the body text does. The footnote texts of such a box are real insertions at their marks; when tcolorbox splits the content of the box, each part keeps the insertions of its marks, and tcbpagefootnote moves them out of the part to its page (`tcbpagefootnote.lua`). A part leaves room for its footnotes. With the other engines, see the limitations below.

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
* Tested with TeX Live 2026 (LaTeX2e 2026-06-01, tcolorbox 6.10.0)
* For tate with pLaTeX and upLaTeX: `pxpgftate`

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
* With an engine other than LuaTeX, a `breakable` box that is broken across pages puts the footnote texts of all its parts on the page where the box ends, and the package warns. The content of a breakable box is typeset as a whole before it is split, and only LuaTeX can take the footnote insertions out of the split parts. This also holds for LuaLaTeX in a `multicols` environment, where the footnotes are below all the columns.
* With LuaLaTeX, the part of a broken box on a page that has no footnote before the box can be up to `\skip\footins` (the space above the footnotes) shorter than without `page footnote`, when the part has no footnote but the rest of the box has one.
* With pLaTeX and upLaTeX in tate, a `\footnotetext` in vertical mode (e.g. right after a box) does not work with the new footnote code of LaTeX (`\DocumentMetadata`), with or without this package. Put it in a paragraph.

## Testing

`make test` compiles every test with pdfLaTeX, XeLaTeX, LuaLaTeX, pLaTeX and upLaTeX (+ dvipdfmx), and checks the log:

* `TPF-RESULT OK`: every footnote text is typeset exactly once, with its own mark, on the expected page, as a page footnote or as a footnote of the box (recorded at shipout to the `.aux` file and checked when it is read back at `\end{document}`; see `test-common.tex`).
* `test-hyperref`, `test-tagging-hyperref`: no warning on a duplicate or missing destination in the log or in the output of the engine and (x)dvipdfmx.
* `test-breakable`, `test-tagging-breakable`: exactly one tcbpagefootnote warning, none with LuaLaTeX; the other tests: none.
* `test-breakable-lua`: no overfull page and no split footnote (`% split` of `\tracingpages`) in the log.
* `test-tagging` (pdflatex, xelatex, lualatex): `test-tagging.lua` reads the structure tree with `show-pdf-tags` and finds every `FENote` right after its `Lbl`, except the two `\footnotemark` whose texts are given later by `\footnotetext`.
* `test-tate`: the same checks as for `test-basic`, `test-breakable` and `test-breakable-lua`, in tate.
* `test-errors`: the expected error message.

| Test | Engines | What it covers |
|---|---|---|
| `test-basic.tex` | pdflatex, xelatex, lualatex (article, ltjsarticle), platex, uplatex | title/upper/lower, several footnotes, `\footnote[9]`, `\footnotemark`/`\footnotetext`, nested boxes, an ordinary box, `\tcbox`, `\newtcolorbox`, `\tcbset`, a box moved to the next page |
| `test-hyperref.tex` | pdflatex, xelatex, lualatex, platex, uplatex | `test-basic.tex` with hyperref |
| `test-breakable.tex` | pdflatex, xelatex, lualatex, platex, uplatex | a box broken by `\tcbbreak` with footnotes in its title, upper and lower part (LuaLaTeX: each footnote on the page of its mark; the others: footnotes on the last page, warning), an unbroken breakable box, an unbreakable box after a broken one |
| `test-breakable-lua.tex` | lualatex (article, ltjsarticle, with hyperref) | boxes that TeX breaks across several pages: a box that starts in the middle of a page, footnotes of one and of several lines in every part, a footnote only in the last part, `height fixed for`, boxes inside a broken box |
| `test-japanese.tex` | lualatex (ltjbook), platex (jbook), uplatex (ujbook) | a Japanese document |
| `test-tagging.tex` | pdflatex, xelatex, lualatex, platex, uplatex | `test-basic.tex` (and `test-breakable.tex`, `test-breakable-lua.tex`, `test-japanese.tex`, with hyperref) with `\DocumentMetadata{tagging=on}`; pLaTeX and upLaTeX do not write a structure tree, so only the log is checked |
| `test-tate.tex` | platex (tarticle), uplatex (utarticle), lualatex (ltjtarticle) | `test-basic.tex`, `test-breakable.tex` and (LuaLaTeX) `test-breakable-lua.tex` in tate, with pxpgftate for pLaTeX and upLaTeX |
| `test-errors.tex` | pdflatex | the error messages (`float`, `after`, key already defined) |

`test-common.tex` holds the helpers shared by the tests, and `test-tagging.lua` the check of the structure tree.

## Repository

* <https://github.com/munepi/tcbpagefootnote>
* Bug reports: <https://github.com/munepi/tcbpagefootnote/issues>

## License

This package is licensed under the conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl.txt), either version 1.3c of this license or any later version.

Copyright (c) 2026 Munehiro Yamamoto
