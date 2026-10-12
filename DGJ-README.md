# How to build the text-service — findings

Notes gathered from reading `build.xml`, `docker-compose.yml`, the `docker/`
Dockerfiles and the indexing scripts in this repo. The goal is a reproducible
recipe for building the snippet/text service and getting data into eXist + Solr,
both natively (ant) and in Docker.

> Status: working notes. Paths and target names below are taken straight from
> the code; the "Gotchas" section flags the parts that are fragile or stale.

---

## 0. Repositories needed

The scripts use **hardcoded relative paths** (`../something`), so the easiest
layout is to clone every repo as a sibling directory under one parent, e.g.
`~/tekstportalen/`:

```
parent/
├── public-adl-text-sources/    # ADL texts            -> adl/texts
├── adl-text-sources/           # ADL authors + periods -> adl/authors, adl/periods
├── SKS_tei/                    # Søren Kierkegaard     -> sks
├── trykkefrihedens-skrifter/   # TFS source (alto)
├── dab-lovforarbejder/         # lovforarbejder (jura) -> jura/texts
├── letter-corpus/              # letter books (breve)  -> letters (add_letter_data)
├── GV/                         # we currently only have access to our own mirror
├── alto-to-tei-tools/          # alto -> tei converter -> tfs/texts AND lh/texts?
├── solr-and-snippets/          # this repo — build + index 
└── text-service/               # the Rails front-end app (Docker image)
```

The exact paths the ant targets read from (from `build.xml`):

| Edition / data | Source path (relative)            | Lands in build under     |
|----------------|-----------------------------------|--------------------------|
| ADL texts      | `../public-adl-text-sources/texts`| `text-retriever/adl/texts`   |
| ADL authors    | `../adl-text-sources/authors`     | `text-retriever/adl/authors` |
| ADL periods    | `../adl-text-sources/periods`     | `text-retriever/adl/periods` |
| SKS            | `../SKS_tei/data/v1.9/`           | `text-retriever/sks`         |
| TFS            | `../alto-to-tei-tools/tei_dir`    | `text-retriever/tfs/texts`   |
| LH             | `../alto-to-tei-tools/tei_dir`    | `text-retriever/lh/texts`    |
| Jura           | `../dab-lovforarbejder/volumes`   | `text-retriever/jura/texts`  |
| Letters        | via `utilities/copy-letters.pl`   | `text-retriever/letters`     |
| GV (Grundtvig) | `../GV/` via `utilities/copy-grundtvig.pl` | `text-retriever/gv`  |

### ⚠️ TFS and LH read from the *same* directory
`add_base_data` copies `../alto-to-tei-tools/tei_dir` → `tfs/texts`, and
`add_lh` copies the **same** `../alto-to-tei-tools/tei_dir` → `lh/texts`. If the
converter output isn't separated per collection, TFS and LH data get mixed. This
is the data-mixing risk to resolve. **TODO:** make the alto→tei conversion write
TFS and LH into distinct output dirs (or point the two targets at different
sources).

### Converting alto → tei (building TFS)
TFS TEI does not exist as a repo — it is **generated** from the ALTO in
`../trykkefrihedens-skrifter/` by `../alto-to-tei-tools`, whose output lands in
`../alto-to-tei-tools/tei_dir`. That is exactly the path the `add_base_data` /
`add_lh` ant targets read from (see the table above), so this conversion must run
**before** the solr-and-snippets build.

Prereqs: saxon (an XSLT-3 processor), `xmllint`, perl, bash — e.g.
`sudo apt install libsaxon-java`. Then, from inside `../alto-to-tei-tools`:

```sh
export SAXON_PATH=/usr/share/java/saxon.jar   # scripts read this env var

./clean_really_clean.sh          # wipe any stale data/ (start clean)
./import_alto.pl | /bin/bash     # copy ALTO from ../trykkefrihedens-skrifter/ into ./data/
./collect_alto                   # build per-publication file lists in alto_file_lists/
./run_build                      # saxon: ALTO -> TEI into tei_dir/, then postprocess
```

`run_build` runs `altototei.xsl` over each list via saxon and finishes with
`utilities/traverse-and-transform.pl`. Optional validation:
```sh
find tei_dir/ -name '*.xml' -exec xmllint --noout --relaxng ./tei_all.rng {} \;
```
Both `data/` and `tei_dir/` are **derived data** — not under version control in
that repo. (Its own README ends "store into database and index" → this repo.)

### ⚠️ Where does LH (Louis Hjelmslev) come from? — UNKNOWN
The `add_lh` target reads `../alto-to-tei-tools/tei_dir` (the **same** dir TFS is
built into), but `import_alto.pl` only ever imports ALTO from
`../trykkefrihedens-skrifter/` — there is **no known LH ALTO source** wired up
anywhere in these repos. So it is currently unclear where LH's TEI is supposed to
originate; as it stands `add_lh` would just re-copy the TFS output. **TODO:** find
/ document the LH source and give it its own conversion input and output dir (this
is the same data-mixing risk flagged above).

### The actual sibling clones (git remotes)
Snapshot of the repos currently checked out alongside this one under
`~/tekstportalen/`, with the `origin` URL each was cloned from (all on `kb-dk`):

| Directory                    | Git URL (`origin`)                                |
|------------------------------|---------------------------------------------------|
| `solr-and-snippets/`         | `git@github.com:kb-dk/solr-and-snippets.git` (this repo) |
| `text-service/`              | `https://github.com/kb-dk/text-service`           |
| `public-adl-text-sources/`   | `git@github.com:kb-dk/public-adl-text-sources.git`|
| `adl-text-sources/`          | `git@github.com:kb-dk/adl-text-sources.git`       |
| `SKS_tei/`                   | `git@github.com:kb-dk/SKS_tei.git`                |
| `trykkefrihedens-skrifter/`  | `git@github.com:kb-dk/trykkefrihedens-skrifter.git`|
| `alto-to-tei-tools/`         | `git@github.com:kb-dk/alto-to-tei-tools.git`      |
| `dab-lovforarbejder/`        | `git@github.com:kb-dk/dab-lovforarbejder.git`     |
| `letter-corpus/`             | `git@github.com:kb-dk/letter-corpus.git`          |
| `GV/`                        | `ssh://git@github.com/kb-dk/gv-mirror`            |

Notes:
- **GV directory vs remote name mismatch:** the source dir is `GV/` (what
  `copy-grundtvig.pl` hardcodes as `../GV/`) but its remote is **`gv-mirror`**, so a
  fresh `git clone` gives you `gv-mirror/` — rename it to `GV` or the GV build
  fails silently (empty `find`).
- `text-service` uses an `https://` remote; everything else uses `git@`/`ssh`.

---

## 1. Build the service and load data (native / ant)

The build assembles a tree under `build/text-retriever/` that mirrors the eXist
collection layout under `/db/text-retriever`.

### Copy the service software (XQuery/XSLT, configs)
```sh
ant service        # common files + index config -> build/
ant base_service   # per-edition exporters: adl, sks, gv, tfs, letters, lh, jura
```

### Add data (run one or more)
```sh
ant add_base_data    # ADL + SKS + TFS  (depends on base_service)
perl utilities/capabilities_adder_sks.pl
ant add_letters_ng   # letters (breve) via utilities/copy-letters.pl
ant add_jura         # lovforarbejder   from ../dab-lovforarbejder/volumes
ant add_lh           # Louis Hjelmslev from ../alto-to-tei-tools/tei_dir
ant add_grundtvig    # Grundtvig via utilities/copy-grundtvig.pl 
perl utilities/capabilities_adder_gv.pl

```

Notes on the targets:
- `add_base_data` requires the TEI to already be generated from alto first (TFS).
- `add_letters` is **deprecated** — use `add_letters_ng`. The old one builds a
  separate `letter_books` collection; the `_ng` one drives a perl script
  (`copy-letters.pl`) that emits shell commands piped to bash.
- `add_letter_data` is a separate path that copies from `../letter-corpus`.

### Generate Grundtvig capabilities (manual, after `add_grundtvig`)
`add_grundtvig` copies the GV data but does **not** build the per-work
`capabilities.xml` manifests — it only prints a reminder
(`NB you might need to update capabilities.` / `note to self
utilities/capabilities_adder_gv.pl?`, build.xml:145-146). Run the script yourself
from the **repo root** (its `build/text-retriever/gv` path is hardcoded relative
to the cwd):
```sh
perl utilities/capabilities_adder_gv.pl
```
What it does: for every directory under `build/text-retriever/gv` containing a
`txt.xml`, it writes a TEI `<bibl>` `capabilities.xml` next to it — a `<ref
type='Værk' target='txt.xml'/>` for the main text plus one `<relatedItem>` per
sibling `*.xml`, typed by filename:

| sibling file | `type=` label |
|--------------|---------------|
| `intro.xml`  | Indledning |
| `com.xml`    | Punktkommentarer |
| `txr.xml`    | Tekstredegørelse |
| `v0.xml`     | Varianter |
| `kolofon.xml` / `col.xml` | Kolofon (`col.xml` is rewritten to target `kolofon.xml`) |
| anything else | `ignore` (still emitted) |

It also writes an empty `<bibl/>` stub into `gv/registre/capabilities.xml` if that
dir exists. The run is **silent on success** and **overwrites** in place; verify
with counts:
```sh
find build/text-retriever/gv -name txt.xml         | wc -l   # dirs to process
find build/text-retriever/gv -name capabilities.xml | wc -l   # = dirs + 1 (registre)
```
Last verified run: 442 `txt.xml` dirs → 443 `capabilities.xml` (incl. the registre
stub). These files are consumed by the front-end and are **excluded from Solr
indexing** (see §3), so they must exist in the build **before `ant upload`**.

> SKS has its own variant, `utilities/capabilities_adder_sks.pl` — same engine,
> main-text `<ref type='Hovedtekst'>`, and type map (`int_1`→Indledning,
> `int_2`→Kommentar, `ekom`→E-kommentarer, `kom`→Tekstkommentarer,
> `txr`→Tekstredegørelse).
>
> In practice you rarely need it: the SKS source (`../SKS_tei/data/v1.9/`) already
> **ships `capabilities.xml`** for each work, and `ant add_base_data` just copies
> them into `build/text-retriever/sks`. The `txt.xml` convention is the same as GV.
>
> ⚠️ **Unscoped `find` — footgun.** Unlike the GV script (hardcoded to
> `build/text-retriever/gv`), this one uses `find . -name 'txt.xml'` from the
> **current dir**. Run from the repo root it recurses into `build/text-retriever/gv`
> and **overwrites the GV `capabilities.xml` with SKS typing** (wrong
> `<ref type='Hovedtekst'>` and labels). If you must run it, `cd` into the SKS tree
> first:
> ```sh
> cd build/text-retriever/sks && perl ../../../utilities/capabilities_adder_sks.pl
> ```
>
> ⚠️ **Non-deterministic order:** in both scripts the `<relatedItem>` lines come out
> in Perl hash-iteration order, so re-running reshuffles them — noisy in diffs but
> harmless to consumers that key off `type`/`target`.

### Upload to eXist
```sh
ant upload -Dhostport=localhost:8080
```
This runs `utilities/load_exist.pl` over `build/` (suffixes:
`xconf,xml,xq,xqm,xsl,page`) and prompts for the admin password.

> **Upload semantics:** it overwrites existing files and adds new ones, but it
> **does not delete** files that are gone from the build. To remove documents you
> must clear them in eXist explicitly.

### Fix permissions after upload (not sure it this is needed)
```
http://admin@localhost:8080/exist/rest/db/text-retriever/xchmod.xqt
```

---

## 2. Build with Docker

`docker-compose.yml` defines four services:

| Service | Image | Purpose |
|---------|-------|---------|
| `solr`  | `solr:8.11.1` | precreates core `text-retriever-core` from `solr/adl/conf`; `SOLR_HEAP=2g` |
| `exist` | `existdb/existdb:4.8.0` | XML DB, data in named volume `exist-data` |
| `app`   | `text-service-app:latest` | Rails front-end (port 3000) |
| `tools` | built from `docker/tools/Dockerfile` | ant + perl toolchain for build/load/index |

```sh
# Build the Rails app image first (see the text-service repo):
#   cd ../text-service && docker build -t text-service-app .

docker compose up -d
```

### Running the build/load/index inside the `tools` container (NOT TESTET)
The `tools` service bind-mounts the whole parent dir at `/workspace` and sets
`EXIST_HOST`, `SOLR_HOST`, etc., so the same ant targets and indexing scripts run
unchanged against the `exist`/`solr` services:

```sh
docker compose run --rm tools ant service
docker compose run --rm tools ant base_service
docker compose run --rm tools ant add_base_data
docker compose run --rm tools ant upload -Dhostport=exist:8080
docker compose run --rm tools ./run_local_indexing.sh
```

---

## 3. Indexing into Solr

Solr only serves what has been indexed — **nothing is "published" until it is in
Solr.** Indexing pulls the solrized form from eXist (not from disk), so documents
must be uploaded to eXist first.

### Index the build tree
```sh
./run_local_indexing.sh                 # auto-generates the list from build/text-retriever
./run_local_indexing.sh my_files.text   # or pass an explicit file list
```
The following files contains the currently published data
```
./run_local_indexing.sh files_to_be_indexed/files-gv_to_be_indexed.text
./run_local_indexing.sh files_to_be_indexed/files-tfs_to_be_indexed.text
./run_local_indexing.sh files_to_be_indexed/files-jura_to_be_indexed.text
./run_local_indexing.sh files_to_be_indexed/files-adl_to_be_indexed.text
./run_local_indexing.sh files_to_be_indexed/files-lh_to_be_indexed.text
./run_local_indexing.sh files_to_be_indexed/files-sks_to_be_indexed.text
./run_local_indexing.sh files_to_be_indexed/files-letters_ng_to_be_indexed.text
```

`run_local_indexing.sh`:
- with no arg, finds every `*.xml` under `build/text-retriever` (excluding
  non-text files: `capabilities.xml`, `toc.xml`, `creator-relations.xml`,
  `author-and-period.xml`, `missing_facs.xml`), paths relative to the build root;
- calls `indexing/solr_updater.pl` with `op=solrize`;
- is driven by env vars (defaults in brackets): `EXIST_HOST`[localhost],
  `EXIST_PORT`[8080], `EXIST_USER`[admin], `EXIST_PASSWD`[],
  `SOLR_HOST`[localhost], `SOLR_PORT`[8983], `SOLR_COLLECTION`[text-retriever-core].
  In Docker these are set on the `tools` service.
- finally builds the **suggester dictionary** once
  (`suggest?suggest.build=true`), because `buildOnCommit` is off in
  `solrconfig.xml` (rebuilding the FST on every commit OOMs the load).

Environment-specific variants: `run_prod_indexing.sh`, `run_stage_indexing.sh`,
`run_test_indexing.sh` (these have hardcoded prod/stage/test hosts and
credentials). (TODO fix this)

### Pre-made file lists
`files_to_be_indexed/` holds per-collection lists, mostly hand-maintained:
(TODO: is all of these stil relevant? I guess that at lease files-letters_to_be_index can be deleted)
```
files-adl_to_be_indexed.text          files-letters_ng_to_be_indexed.text
files-sks_to_be_indexed.text          files-letters_to_be_indexed.text
files-sks_printed_to_be_indexed.text  files-lh_to_be_indexed.text
files-tfs_to_be_indexed.text          files-gv_to_be_indexed.text
files-colophon_gv_to_be_indexed.text  files-other_to_be_indexed.text
```

### Generating the letters list automatically
Letters are published per-document via a `status` attribute on the root `<TEI>`:
```xml
<TEI xmlns="http://www.tei-c.org/ns/1.0" ... xml:id="root" status="published">
```
`list_published_letters.sh` walks `build/text-retriever/letters` and prints the
paths whose root `<TEI>` has the wanted status (default `published`):
```sh
./list_published_letters.sh > published_letters.text   # STATUS=ready to override
./run_local_indexing.sh published_letters.text
```


## Gotchas / TODOs

- **TFS vs LH share `../alto-to-tei-tools/tei_dir`** — risk of mixing data
  (see §0).
- **Alto → TEI conversion** is a prerequisite for TFS (now documented in §0,
  "Converting alto → tei").
- **LH source is unknown** — `add_lh` reads the TFS output dir and no LH ALTO
  source is wired up anywhere (see §0). Needs tracking down.
- **`ant upload` never deletes** — removed documents linger in eXist until
  cleared manually.
- **Solr heap:** the default 512m OOMs while indexing the full tree (Solr's
  `oom_solr.sh` SIGKILLs the JVM → exit 137); compose sets `SOLR_HEAP=2g`.
- **Suggester** must be built after indexing (`buildOnCommit` is off on purpose).
- **GV capabilities are a manual step:** `add_grundtvig` does *not* run
  `utilities/capabilities_adder_gv.pl` — run it yourself (from repo root) after the
  target, before `ant upload` (see §1). **TODO:** fold it into `add_grundtvig`.
