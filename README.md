# OGC Standard template (Building Blocks)

Template repository to author an **OGC Standard** as [OGC Building Blocks](https://ogcincubator.github.io/bblocks-docs/)
and generate the standards document from them.

- The document has the structure of the OGC **standard** template of Metanorma
  ([metanorma/mn-templates-ogc › standard](https://github.com/metanorma/mn-templates-ogc/tree/master/standard)):
  preface, clauses 1–8, Annex A (Abstract Test Suite), other annexes, Revision History and Bibliography.
- Every clause, requirements class, term list, reference list and annex is a building block in
  [`_sources/part1/`](_sources/part1); [`standards.yaml`](standards.yaml) holds the document metadata and
  the clause order.
- The generator is [bblocks-postprocess](https://github.com/opengeospatial/bblocks-postprocess)
  (validation, register, viewer) with the [bblocks-specgen](https://github.com/JFarduino/bblocks-specgen)
  build plugin (`layout: ogc`: ModSpec tables, numbered clauses, OGC cover), declared in
  [`bblocks-config.yaml`](bblocks-config.yaml). Using the JFarduino fork (`feature/update` branch) is
  temporary: once [ogcincubator/bblocks-specgen#2](https://github.com/ogcincubator/bblocks-specgen/pull/2)
  is merged, the template will use the official
  [ogcincubator/bblocks-specgen](https://github.com/ogcincubator/bblocks-specgen).

Out of the template, everything to fill in is marked **TODO**, and the document still generates.

## Creating a Standard from this template

1. On GitHub, click **Use this template › Create a new repository** (do not fork it).
2. In the new repository: **Settings › Pages › Build and deployment › Source: GitHub Actions**.
3. Fill in the metadata of the Standard (title, document number, identifier prefix, base URI, editor),
   **either**
   - on GitHub: **Actions › Initialize the standard › Run workflow**, fill in the form. The workflow
     commits the metadata and launches the generation; **or**
   - locally: clone the repository, run `./init.sh` (it asks the questions), commit and push.
4. Write the content: replace every remaining TODO.
   ```shell
   grep -rn TODO standards.yaml _sources
   ```
5. Generate the document: every push to `master`/`main` builds it and publishes it to GitHub Pages
   (`<pages-url>/build/standards/part1/`), or build it locally (see [Building locally](#building-locally)).

## Document structure

| Metanorma `standard/` | Building block (`_sources/part1/…`) | Number |
|---|---|---|
| `clause_0_front_material.adoc` — Abstract, Keywords | `abstract` and `keywords` in `standards.yaml` | I, II |
| — Preface | `preface/preface` | III |
| — Security Considerations | `preface/security-considerations` | IV |
| — Submitting organizations | `preface/submitting-organizations` | V |
| — Submitters | `preface/submitters` | VI |
| — Contributors (optional) | `preface/contributors` | VII |
| `clause_1_scope.adoc` | `clauses/scope` | 1 |
| `clause_2_conformance.adoc` | `clauses/conformance` | 2 |
| `clause_3_references.adoc` | `clauses/references` (`references.yaml`) | 3 |
| `clause_4_terms_and_definitions.adoc` | `clauses/terms` (`terms.yaml`) | 4 |
| `clause_5_conventions.adoc` | `clauses/conventions` | 5 |
| `clause_6_informative_text.adoc` | `clauses/informative-text` | 6 |
| `clause_7_normative_text.adoc` | `clauses/normative-text` | 7 |
| — Requirement Class A (`requirements/*.adoc`) | `requirements/req-class-a` (`requirements.yaml`) | 7.1 |
| `clause_8_media_types.adoc` | `clauses/media-types` | 8 |
| `annex-a.adoc` — Abstract Test Suite | `annexes/ats` (layout of the annex) | Annex A |
| `annex-n.adoc` | `annexes/annex-b` | Annex B |
| `annex-history.adoc` | `annexes/revision-history` | Annex C |
| `annex-bibliography.adoc` | `annexes/bibliography` (`references.yaml`) | Bibliography |

Each block is a folder with a `bblock.json` (its `name` is the clause title, `normative: false` makes it
informative) and a `description.md` (the clause text). Clauses are numbered in the order of `clauses` in
`standards.yaml`; to add, remove or reorder a clause or an annex, change that list.

## Writing the content

- **Text** — `description.md` is Markdown. Headings carry no number: the layout numbers them (7.1.1…),
  and cross-references use `#sec-<number>` anchors, e.g. `[Clause 7.1](#sec-7.1)`, `[Annex A](#sec-A)`.
- **Figures** — put the image in an `assets/` folder of the block and reference it with a caption on its
  own line: `![Caption of the figure](assets/figure.svg)` ("Figure N — Caption").
- **Requirements** — the requirements, recommendations, permissions and abstract tests of a class are in
  its `requirements.yaml`, and placed in the text with `<!-- requirement: <id> -->`,
  `<!-- recommendation: <id> -->`, `<!-- permission: <id> -->` markers. They are numbered in document order.
  Their URIs are `<base-uri>/req/<id>`, `/rec/<id>`, `/per/<id>` (`draft/` is added while `status: Draft`).
- **New requirements class** — copy `requirements/req-class-a/` (e.g. to `requirements/req-class-b/`),
  change its `class-id` and the ids of its statements, add it to the `subclauses` of clause 7 in
  `standards.yaml`, and add its conformance class to `annexes/ats/description.md`
  (`<!-- conformance-class: <block id> -->`, `<!-- abstract-test: <id> -->`).
- **Terms and references** — `clauses/terms/terms.yaml`, `clauses/references/references.yaml` and
  `annexes/bibliography/references.yaml`.
- **Schemas** — a requirement can point to a schema building block (`applies-to: {bblock: …}`), and
  a schema can be shown in the text with an include:
  ````markdown
  ```yaml include=bblocks://<identifier of the schema block>
  ```
  ````
  To reference blocks of other registers (e.g. `@ogc/ogcapi-common`), add them to `imports` in
  `bblocks-config.yaml`.

The format of these files is described in the
[bblocks-specgen authoring guide](https://github.com/JFarduino/bblocks-specgen/blob/feature/update/docs/authoring.md)
(the fork's version, which documents `layout: ogc`; it moves to ogcincubator/bblocks-specgen once
[PR #2](https://github.com/ogcincubator/bblocks-specgen/pull/2) is merged).

## Building locally

Requires Docker. The postprocessor image is only published for `linux/amd64`: on Apple Silicon, set
`DOCKER_DEFAULT_PLATFORM=linux/amd64` (Docker Desktop emulates it).

```shell
DOCKER_DEFAULT_PLATFORM=linux/amd64 ./build.sh   # validation, register, documentation, standards document
open build/standards/part1/index.html            # the generated Standard
./view.sh                                        # optional: Building Blocks viewer at http://localhost:9090
```

The first build asks for permission to install the bblocks-specgen plugin; in scripts, pass
`--skip-permissions true` to `./build.sh`. `build/standards/part1/report.json` lists how each building
block was used.

## Repository layout

```
standards.yaml          document metadata, front page notices, preface and clause order
bblocks-config.yaml     register: name, identifier prefix, imports, specgen build plugin
init.sh                 fills in the metadata (run once)
_sources/part1/
├── preface/            preface III-VII
├── clauses/            clauses 1-8 (prose, references, terms)
├── requirements/       requirements classes (subclauses of clause 7)
└── annexes/            Annex A layout, annexes B…, Revision History, Bibliography
.github/workflows/
├── initialize.yml      "Initialize the standard" form (run once)
├── process-bblocks.yml generation and publication on GitHub Pages (every push)
└── pr-check.yml        validation of pull requests
```

The generation workflow does not run on the very first commit of a repository created from the
template; if it does not run after the initialization, start **Validate and process Building Blocks**
from the Actions tab.
