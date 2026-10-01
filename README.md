# Advances in Artificial Intelligence — Student Proceedings

This repository is the starting point for four-page student project papers and
their shared printed proceedings. Each paper compiles on its own. The volume
compiles the same LaTeX sources with one cover, preface, contents page,
continuous paper page numbers, and a common two-column design. It does not
concatenate PDFs.

## Repository map

```text
config/                 edition metadata and four-page limit
template/               copy this folder for a new submission
papers/example-paper/   complete two-page demonstration paper
proceedings/            shared preamble, cover, preface, and paper order
scripts/                shared build and validation logic
.github/workflows/      pull-request validation and main-branch PDF build
```

The example paper demonstrates citations, a local PDF figure, a table, an
equation, and cross-references. Its figure source is
`papers/example-paper/figures/radar.tex`; the generated `radar.pdf` is committed
as a source asset because the paper uses it. Other build PDFs are ignored.

## Student workflow

Replace `<repository-url>` with the course repository URL and `<team-name>`
with a short unique lowercase name.

```bash
git clone <repository-url> advances-in-ai-proceedings
cd advances-in-ai-proceedings
git checkout -b paper/<team-name>
cp -r template papers/<team-name>
cd papers/<team-name>
./build.sh
```

Edit `paper.tex`, add sources to `references.bib`, and store all local images
in `figures/`. The `\PaperHeading` arguments supply title, authors,
programme/institution, optional email, abstract, and keywords. Use a unique
prefix such as `fig:team-name-...` for every `\label` to avoid collisions in
the combined volume. Build from any directory with
`bash papers/<team-name>/build.sh` or run `./build.sh` in the paper folder.

```bash
cd ../..
git add papers/<team-name>
git commit -m "Add paper: Team Name"
git push origin paper/<team-name>
```

Open a pull request into `main`. Pull requests allow review and automatically
build the affected paper. The paper validation check must be green before
merging. Students should change only their own `papers/<team-name>/` folder;
the editorial team maintains the template, shared layout, scripts, and
proceedings order.

## Paper rules

- Maximum **four A4 pages**, including references and appendices. The build
  script checks the PDF page count with `pdfinfo`.
- LaTeX is required. `paper.tex` must compile locally with `./build.sh`, and
  CI must pass.
- Keep the shared layout files unchanged. Do not override margins, fonts,
  headings, headers, colors, or bibliography style in your paper.
- Put images in your own `figures/` folder and references in your own
  `references.bib`. Use relative paths with `\subfix{figures/name.pdf}`.
- Do not use absolute paths or fetch images over HTTP during the build.
- Do not commit generated PDFs (except a PDF used as a figure), `.build/`, or
  other LaTeX intermediate files.
- Cite all borrowed ideas, data, and graphics. Describe how results were
  obtained and state meaningful limitations.

Suggested sections: **Introduction and Motivation**, **Approach**, **Design
Decisions and Alternatives**, **Results**, **Discussion and Limitations**,
**Conclusion**, and **References**. The template contains prompts and examples
for each. Replace all placeholder values and illustrative measurements.

## Build the volume (editors)

Add each accepted paper to `proceedings/papers.tex` in publication order:

```latex
\subfile{../papers/team-name/paper}
```

Then run:

```bash
bash papers/example-paper/build.sh
bash proceedings/build.sh
```

The outputs are `papers/example-paper/paper.pdf` and
`proceedings/proceedings.pdf`. Each `\PaperHeading` begins a new page. The cover
has no printed number, the preface and contents use Roman numerals, and the
paper pages use continuous Arabic numerals. Every paper has its own
`refsection` and bibliography; `\subfix` resolves local resource paths in
both build modes. The shared preamble and heading live in
`proceedings/main.tex`.

For a new edition, update `config/edition.tex` (course title, proceedings
title, year, institution, faculty, and event), `config/limits.sh` (maximum
pages), and `proceedings/preface.tex`. This split keeps LaTeX metadata and the
shell page limit in their native formats. The default year is 2027.

## Local prerequisites

The scripts require Bash, `latexmk`, `pdflatex`, `biber`, and `pdfinfo`
(Poppler). The TeX installation must include standard packages used by
`proceedings/main.tex`, notably `subfiles`, `biblatex`, `biblatex-ieee`,
`geometry`, `fancyhdr`, `titlesec`, `microtype`, `booktabs`, and `lmodern`.
No network access is needed while compiling. CI installs the corresponding
TeX Live packages on Ubuntu.

### Ubuntu / Debian

```bash
sudo apt-get update
sudo apt-get install latexmk biber poppler-utils texlive-latex-recommended \
  texlive-latex-extra texlive-fonts-recommended texlive-bibtex-extra
```

The editable example figure uses TikZ and the `standalone` class, supplied by
`texlive-pictures` and `texlive-latex-extra`. The committed figure PDF means
these packages are only needed if you regenerate that figure.

### macOS

Install the full [MacTeX distribution](https://tug.org/mactex/), then install
Poppler with `brew install poppler`. MacTeX provides `latexmk`, `pdflatex`,
and `biber`. Use Terminal or another Bash-compatible shell.

### Windows

Install [TeX Live](https://tug.org/texlive/) or
[MiKTeX](https://miktex.org/download), plus Git for Windows (Git Bash) and
[Poppler for Windows](https://github.com/oschwartz10612/poppler-windows/releases).
Ensure `latexmk`, `pdflatex`, `biber`, and `pdfinfo` are on Git Bash's `PATH`.
For MiKTeX, enable automatic installation of missing LaTeX packages. Run the
scripts from Git Bash; PowerShell can invoke `bash papers/team-name/build.sh`.

## CI behavior

The pull-request workflow compares the base commit with the proposed change
and builds only modified paper folders. Changes to shared LaTeX or build files
trigger validation of all papers; changes under `proceedings/` or `config/`
also rebuild the volume. `latexmk` handles all necessary LaTeX and
Biber passes; failures, unresolved references/citations, missing bibliography
entries, missing figures, empty title/authors, and overlong papers fail the
check. The `main` branch workflow validates every paper, builds the volume,
and publishes `proceedings.pdf` as a GitHub Actions artifact. Generated PDFs
are not stored in Git.

## License

Repository code and example text are available under the [MIT License](LICENSE).
Paper authors should confirm rights for their own text, figures, and data.

