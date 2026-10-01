# Advances in Artificial Intelligence — Student Proceedings

This repository is the starting point for four-page student project papers and
their shared printed proceedings. Each paper compiles on its own. The volume
compiles the same LaTeX sources with a cover, preface, editor page, contents,
continuous paper page numbers, an author appendix, and a common two-column
paper design. It does not concatenate PDFs.

**Students:** read [Student guide](#student-guide) from top to bottom once. It
lists every step from `git clone` to the merged paper, including what you have
to enter about yourselves (**authors, portraits, links**) and how to read the
automatic checks.

**Editors:** see [Editors](#editors-build-the-volume-and-maintain-the-repository).

---

## Student guide

### At a glance

1. Install the [tools](#local-prerequisites) (LaTeX, Biber, Poppler, Git Bash).
2. Clone the repository and create a branch `paper/<team-name>`.
3. Copy `template/` to `papers/<team-name>/`.
4. Fill in **`metadata.tex`**: title, abstract, keywords, **project repository
   URL** and **one `\AddAuthor` block per author** (name, programme, biography,
   optional portrait and links).
5. Write **`paper.tex`**, put citations into `references.bib`, figures into
   `figures/`.
6. Run `./build.sh` in your paper folder until it prints *Paper validation
   successful*.
7. Commit, push, open a **pull request** into `main`.
8. Wait for the check **Validate changed papers** to turn green; fix reported
   problems and push again.
9. After the merge, the editors include your paper in the printed volume.

### Repository map

```text
config/                 edition metadata and four-page limit (editors)
template/               copy this folder for a new submission
papers/example-paper/   four-page demonstration paper and author metadata
papers/<team-name>/     YOUR folder -- the only place you change
proceedings/            shared layout, cover, front matter, paper order (editors)
scripts/                build and validation logic (editors)
.github/workflows/      pull-request validation and main-branch PDF build (editors)
```

The example paper (`papers/example-paper/`) demonstrates citations, a local PDF
figure, a table, an equation, cross-references and a complete `metadata.tex`.
Look at it whenever you are unsure how something is written.

### 1. Get the repository and create your folder

Replace `<repository-url>` with the course repository URL and `<team-name>`
with a short, unique, lowercase name without spaces (for example `trend-radar`).

```bash
git clone <repository-url> advances-in-ai-proceedings
cd advances-in-ai-proceedings
git checkout -b paper/<team-name>
cp -r template papers/<team-name>
cd papers/<team-name>
./build.sh
```

- **No write access to the course repository?** First click *Fork* on GitHub,
  clone **your fork**, and later open the pull request from your fork into the
  course repository's `main`. Everything else is identical, including the
  automatic checks.
- **Teams with several people:** one person creates the branch and pushes it;
  the others run `git fetch` and `git checkout paper/<team-name>`. Always run
  `git pull` before you start working and before you push, so you do not
  overwrite each other's changes. Edit different files or sections where
  possible.
- The very first `./build.sh` is expected to **fail** with messages about
  template placeholders. That is the checklist for the next step.

### 2. Fill in `metadata.tex` (title, authors, repository link)

`papers/<team-name>/metadata.tex` is the **single place** for everything
about the paper that is not running text. It feeds the first page of your
paper, the QR code, and the **About the Authors** appendix at the end of the
printed volume. Replace *every* placeholder:

| Command | What to enter |
| --- | --- |
| `\PaperTitle{...}` | Title of your paper. |
| `\PaperInstitution{...}` | Degree programme and Hochschule Düsseldorf. |
| `\PaperEmail{...}` | Optional contact address; leave `{}` empty to print none. |
| `\PaperAbstract{...}` | 5–8 lines: problem, approach, implementation, key result, main limitation. |
| `\PaperKeywords{...}` | Comma-separated keywords. |
| `\ProjectRepository{...}` | **Required.** URL of *your project's* GitHub repository (not this course repository), e.g. `https://github.com/my-team/my-project`. Must start with `https://github.com/`. |

**Project repository and QR code.** The URL from `\ProjectRepository` produces a
1.7 cm **QR code on the first page** (beside the abstract and keywords) and a
small printed URL below the keywords. You do not need an image. Use a public or
otherwise accessible repository that contains your project's source code, and
check that readers can open it.

**Authors.** Add **one `\AddAuthor` block per person**, in the order in which
the names should appear on the paper and in the appendix. Copy the block from
the template for further authors. Each block has seven arguments, one per line,
all in curly braces. Leave unused optional arguments as `{}`:

```latex
\AddAuthor
  {Maria Beispiel}                        % 1 full name
  {B.Sc. Data Science}                    % 2 study programme
  {Maria Beispiel is a ... }              % 3 biography, 50--80 words, third person
  {authors/maria-beispiel.jpg}            % 4 portrait (optional)
  {https://github.com/maria-beispiel}     % 5 personal GitHub (optional)
  {https://www.linkedin.com/in/maria}     % 6 LinkedIn (optional)
  {https://maria-beispiel.example}        % 7 website / portfolio (optional)
```

Rules for the author information (all checked automatically):

- **Biography:** **50–80 words**, third person, factual: who you are, what you
  contributed to *this* project, and your academic interests.
- **Portrait (optional):** place the file in your paper folder, e.g.
  `papers/<team-name>/authors/maria-beispiel.jpg`, and write the relative path
  `authors/maria-beispiel.jpg` as argument 4. Use a **square JPG or PNG** below
  **500 KB** with a neutral, professional look. File names are
  *case-sensitive* on GitHub. Without a portrait a neutral placeholder is
  printed. The build never downloads images.
- **Links (optional):** personal GitHub, LinkedIn, and website appear as small
  links below your biography. They are separate from the project repository.
- Do not edit the author appendix itself. It is generated from `metadata.tex`
  and does **not** count towards the four-page limit. The paper title is added
  next to each author automatically.
- Keep one argument per line in the `{...}` form of the template. A `%`
  starts a comment up to the end of the line; to print a literal percent sign
  write `\%`. Special characters need LaTeX notation (e.g. `\"u`, `\&`).

### 3. Write the paper

Edit `paper.tex`. The required sections in this order are **Abstract**
(from `metadata.tex`), **Introduction & Motivation**, **State of the Art**,
**Method**, **Results & Evaluation**, **Discussion & Limitations**,
**Conclusion**, and **References**. The template contains prompts and
approximate space guidance for each; delete the prompt comments and replace all
placeholder text and illustrative numbers.

- Put images into your own `figures/` folder and include them with
  `\includegraphics[width=\columnwidth]{\subfix{figures/name.pdf}}`.
  Prefer vector PDFs; PNG and JPG also work.
- Put every cited source into your own `references.bib` and cite with
  `\autocite{key}`. Cite all borrowed ideas, data, and graphics.
- Make every `\label` unique with a team prefix, e.g.
  `\label{fig:trend-radar-pipeline}`. The papers share one document in the
  printed volume, so a plain `\label{fig:pipeline}` can clash with another team.
- Do not change margins, fonts, headings, headers, colours, or the
  bibliography style. The layout is shared and fixed.

### 4. Build and check locally

```bash
cd papers/<team-name>
./build.sh
```

(or `bash papers/<team-name>/build.sh` from the repository root). On success
the script prints *Paper validation successful (n/4 pages)* and writes
`paper.pdf` into your folder. Open it and **read the PDF**: first page, QR code,
figures, references. The same script runs in the automatic check on GitHub, so
**if it is green locally, it will be green on GitHub**.

The build stops with a readable message and a hint if something is wrong:
placeholders still in `metadata.tex`, too short/long biographies, missing
portrait files, LaTeX errors with file and line, unresolved references or
citations, duplicate labels, missing bibliography entries, a missing or
non-GitHub repository URL, or more than four pages. Fix the **first** reported
problem first; later ones are often follow-up errors. Intermediate files are
written to `.build/` and `paper.pdf` and are not committed.

### 5. Commit, push, and open a pull request

```bash
cd ../..                       # repository root
git status                     # only papers/<team-name>/ should be listed
git add papers/<team-name>
git commit -m "Add paper: Team Name"
git push origin paper/<team-name>
```

On GitHub, open the pull request from your branch into `main` and complete the
checklist in the description. Change **only your own** `papers/<team-name>/`
folder; the editorial team maintains the template, shared layout, scripts, and
the order of papers. Do not commit generated PDFs (except PDF figures), `.build/`,
or other LaTeX intermediate files — `.gitignore` already excludes them.

### 6. Read the automatic check

Every push to the pull request starts the check **Validate changed papers**
(job `validate`). It builds your paper exactly like `./build.sh` and fails the
pull request if anything is wrong. A green check is required before merging.

- Open the pull request, tab **Checks** (or the *Details* link next to the red
  ✗ at the bottom of the conversation). Failed checks show **annotations** with
  file name, line number, and a hint directly in the **Files changed** tab.
- Open the failed step *Build affected papers and enforce four-page limit* for
  the full log. The summary block starts with `================ LaTeX error #1`.
- After a green run, the compiled paper is attached to the run as the artifact
  **paper-pdf** (*Summary* page of the run) so everyone can review the PDF
  without compiling locally.
- Fix the problem locally, run `./build.sh`, commit, and `git push` again; the
  check restarts automatically.

Typical messages and what to do:

| Message | Meaning / fix |
| --- | --- |
| `The paper title is still the template placeholder` / `... First Author` | Replace the template values in `metadata.tex`. |
| `A GitHub URL still contains "your-account"` | Enter your real project URL (and remove or replace placeholder links). |
| `No project repository URL defined` / `must start with https://github.com/` | Set `\ProjectRepository{https://github.com/<owner>/<repository>}`. |
| `The biography of "<name>" has N words` | Rewrite it to 50–80 words. |
| `Portrait file "..." not found` | Check the path and the exact (case-sensitive) file name below your paper folder. |
| `Portrait ... is larger than 500 KB` | Scale the image down (a square ~400×400 px JPG is enough). |
| `Undefined control sequence` | Misspelled LaTeX command; see the `l.<line>` excerpt in the log. |
| `File '...' not found` | Missing figure or wrong path/case; use `\subfix{figures/...}`. |
| `Unresolved reference or citation` | A `\ref`/`\autocite` has no matching `\label` / entry in `references.bib`. |
| `A label is defined more than once` | Use unique, team-prefixed labels. |
| `Paper contains N pages` | The limit is four pages **including references**; shorten text, figures, or references. |
| `WARNING: ... modifies shared files` | You changed files outside your folder; revert them (`git checkout origin/main -- <file>`). |

### 7. After the merge

When your pull request is merged, the editors add
`\IncludePaper{<team-name>}` to `proceedings/papers.tex` in the publication
order. The `main` branch workflow then rebuilds the complete volume, and your
paper and **About the Authors** entry appear in it. If you find a mistake
later, open a new pull request against your own folder.

### Paper rules

- Maximum **four A4 pages**, including references and appendices. The build
  script checks the PDF page count with `pdfinfo`.
- LaTeX is required. `paper.tex` must compile locally with `./build.sh`, and
  the pull-request check must pass.
- Keep the shared layout unchanged (margins, fonts, headings, headers, colours,
  bibliography style).
- Use relative paths only and no images fetched over HTTP during the build.
- Provide a project GitHub repository URL in `metadata.tex`.
- Describe how results were obtained and state meaningful limitations.

---

## Editors: build the volume and maintain the repository

Add each accepted paper to `proceedings/papers.tex` in publication order:

```latex
\IncludePaper{team-name}
```

Then run:

```bash
bash papers/example-paper/build.sh
bash proceedings/build.sh
```

The outputs are `papers/example-paper/paper.pdf` and
`proceedings/proceedings.pdf`. Each `\PaperHeading` begins a new page. The cover
has no printed number; the shared preface/editor page and contents use Roman
numerals. Paper pages use continuous Arabic numerals, followed by **About the
Authors**. Every paper has its own `refsection` and bibliography; `\subfix`
resolves local resource paths in both build modes. `proceedings/papers.tex`
is the only ordering list for both papers and profiles. The shared layout and
components live in `proceedings/main.tex` and `proceedings/paper-components.tex`;
the cover page is `proceedings/titlepage.tex` and takes all texts from
`config/edition.tex`. The portrait and the HSD logo live in `proceedings/figures/`.

For a new edition, update `config/edition.tex` (course title, proceedings
title, year, institution, faculty, and event), `config/limits.sh` (maximum
pages), and `proceedings/preface.tex`. This split keeps LaTeX metadata and the
shell page limit in their native formats. The default year is 2027.

### Continuous integration

- **Pull requests** (`.github/workflows/validate-paper.yml`, job `validate`):
  compares the base commit with the proposed change and builds only modified
  paper folders. Changes to shared LaTeX or build files trigger validation of
  all papers; changes under `proceedings/` or `config/` also rebuild the
  volume. Per paper, `scripts/build-paper.sh` runs
  `scripts/check-metadata.sh` (placeholders, biography length, portrait
  files), `latexmk`, `scripts/check-log.sh` (unresolved references/citations,
  duplicate labels, missing bibliography entries), and the page limit.
  Failures are summarised by `scripts/report-errors.sh` and shown as
  annotations on the pull request. The compiled PDF is uploaded as the artifact
  `paper-pdf`. A warning is shown when a pull request touches shared files.
- **`main` branch** (`build-proceedings.yml`): validates every paper, builds the
  volume, and publishes `proceedings.pdf` as the GitHub Actions artifact
  `student-proceedings`. Generated PDFs are not stored in Git.
- The placeholder rules of the metadata check are skipped for `template/` and
  `papers/example-paper/`, which intentionally contain sample data. Remove the
  example paper from `proceedings/papers.tex` and `papers/` before publishing the
  real volume.
- **Recommended repository settings** (Settings → Branches → branch protection
  for `main`): *Require a pull request before merging*, *Require status checks
  to pass* with the check **validate**, and *Require branches to be up to date*.
  This enforces the green check for every paper.
- Newly submitted papers are validated standalone. Before the final volume,
  include them in `proceedings/papers.tex` and run `bash proceedings/build.sh`
  to see all papers together.

## Local prerequisites

The scripts require Bash, `latexmk`, `pdflatex`, `biber`, and `pdfinfo`
(Poppler). The TeX installation must include standard packages used by
`proceedings/main.tex`, notably `subfiles`, `biblatex`, `biblatex-ieee`,
`geometry`, `fancyhdr`, `titlesec`, `microtype`, `booktabs`, `lmodern`,
`qrcode`, `tikz`, and `xstring` (the cover uses TikZ and the Helvetica clone
from `psnfss`). No network access is needed while compiling. CI installs the
corresponding TeX Live packages on Ubuntu.

### Ubuntu / Debian

```bash
sudo apt-get update
sudo apt-get install latexmk biber poppler-utils texlive-latex-recommended \
  texlive-latex-extra texlive-pictures texlive-fonts-recommended texlive-bibtex-extra
```

`texlive-pictures` supplies the QR-code package and TikZ for the cover and the
editable example figure. `texlive-latex-extra` supplies `xstring` and
`standalone`.

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
If `./build.sh` complains about a missing tool, open a new Git Bash window after
installing it and check with `latexmk -v`, `biber --version`, `pdfinfo -v`.

## License

Repository code and example text are available under the [MIT License](LICENSE).
Paper authors should confirm rights for their own text, figures, and data.
