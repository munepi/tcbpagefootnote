# tcbpagefootnote Package

**LaTeX: Page footnotes from inside tcolorbox**

tcolorbox typesets the content of a box like a minipage: a `\footnote` inside the box is numbered with the `mpfootnote` counter (a, b, ...) and its text is put at the bottom of the box.

The tcbpagefootnote package adds the tcolorbox key `page footnote`. With it, the footnotes in the title, the upper part and the lower part of the box

1. are numbered with the `footnote` counter and `\thefootnote`, along with the footnotes of the body text, and
2. are put at the bottom of the page where the box is: their texts are collected while the box is typeset and are put into the ordinary footnote insertion right after the box. If the box moves to the next page, its footnotes move with it.

`\footnote[<number>]`, `\footnotemark` with `\footnotetext`, `\tcbox`, and boxes with `page footnote` inside each other work as usual. With hyperref, each footnote mark links to its own footnote text.

* **Supported formats/engines:** pdfLaTeX, XeLaTeX, LuaLaTeX (with or without LuaTeX-ja), pLaTeX, upLaTeX (+ dvipdfmx)

## Files

| File | Description |
|---|---|
| `tcbpagefootnote.sty` | The package |
| `tcbpagefootnote.tex` / `.pdf` | Documentation |
| `test-*.tex` | Test suite (see below) |

## Requirements

* `tcolorbox` (the `hooks` library is loaded by the package)
* Tested with TeX Live 2026 (LaTeX2e 2026-06-01, tcolorbox 6.10.0)

## Installation

Copy `tcbpagefootnote.sty` to your local TeX tree:
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
* Keys that set the whole `after` code (`after`, `after skip`, `nobeforeafter`, ...) remove the code that puts the footnotes when they come after `page footnote` (error): give them before it, e.g. `[after skip=1pt, page footnote]`.
* A `breakable` box that is broken across pages puts the footnote texts of all its parts on the page where the box ends, and the package warns. The content of a breakable box is typeset as a whole before it is split, and footnote insertions do not travel with the split parts.
* Vertical writing (tate) has not been tested.

## Testing

`make test` compiles every test with pdfLaTeX, XeLaTeX, LuaLaTeX, pLaTeX and upLaTeX (+ dvipdfmx), and checks the log:

* `TPF-RESULT OK`: every footnote text is typeset exactly once, with its own mark, on the expected page, as a page footnote or as a footnote of the box (recorded at shipout to the `.aux` file and checked when it is read back at `\end{document}`; see `test-common.tex`).
* `test-hyperref`: no warning on a duplicate or missing destination in the log or in the output of the engine and (x)dvipdfmx.
* `test-breakable`: exactly one tcbpagefootnote warning; the other tests: none.
* `test-errors`: the expected error message.

| Test | Engines | What it covers |
|---|---|---|
| `test-basic.tex` | pdflatex, xelatex, lualatex (article, ltjsarticle), platex, uplatex | title/upper/lower, several footnotes, `\footnote[9]`, `\footnotemark`/`\footnotetext`, nested boxes, an ordinary box, `\tcbox`, `\newtcolorbox`, `\tcbset`, a box moved to the next page |
| `test-hyperref.tex` | pdflatex, xelatex, lualatex, platex, uplatex | `test-basic.tex` with hyperref |
| `test-breakable.tex` | pdflatex, xelatex, lualatex, platex, uplatex | a broken box (footnotes on the last page, warning), an unbroken breakable box, an unbreakable box after a broken one |
| `test-japanese.tex` | lualatex (ltjbook), platex (jbook), uplatex (ujbook) | a Japanese document |
| `test-errors.tex` | pdflatex | the error messages (`float`, `after`, key already defined) |

`test-common.tex` holds the helpers shared by the tests.

## Repository

* <https://github.com/munepi/tcbpagefootnote>
* Bug reports: <https://github.com/munepi/tcbpagefootnote/issues>

## License

This package is licensed under the conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl.txt), either version 1.3c of this license or any later version.

Copyright (c) 2026 Munehiro Yamamoto
