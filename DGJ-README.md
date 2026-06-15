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
├── solr-and-snippets/          # this repo — build + index orchestration
├── public-adl-text-sources/    # ADL texts            -> adl/texts
├── adl-text-sources/           # ADL authors + periods -> adl/authors, adl/periods
├── SKS_tei/                    # Søren Kierkegaard     -> sks
├── trykkefrihedens-skrifter/   # TFS source (alto)
├── alto-to-tei-tools/          # alto -> tei converter -> tfs/texts AND lh/texts
├── dab-lovforarbejder/         # lovforarbejder (jura) -> jura/texts
├── letter-corpus/              # letter books (breve)  -> letters (add_letter_data)
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

### ⚠️ TFS and LH read from the *same* directory
`add_base_data` copies `../alto-to-tei-tools/tei_dir` → `tfs/texts`, and
`add_lh` copies the **same** `../alto-to-tei-tools/tei_dir` → `lh/texts`. If the
converter output isn't separated per collection, TFS and LH data get mixed. This
is the data-mixing risk to resolve. **TODO:** make the alto→tei conversion write
TFS and LH into distinct output dirs (or point the two targets at different
sources).

### Converting alto → tei
TFS (and LH) TEI is generated from alto files using `../alto-to-tei-tools` before
the build can pick them up. **TODO:** document the exact conversion invocation.

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
ant add_letters_ng   # letters (breve) via utilities/copy-letters.pl
ant add_jura         # lovforarbejder   from ../dab-lovforarbejder/volumes
ant add_lh           # Louis Hjelmslev from ../alto-to-tei-tools/tei_dir
ant add_grundtvig    # Grundtvig via utilities/copy-grundtvig.pl 
```

Notes on the targets:
- `add_base_data` requires the TEI to already be generated from alto first (TFS).
- `add_letters` is **deprecated** — use `add_letters_ng`. The old one builds a
  separate `letter_books` collection; the `_ng` one drives a perl script
  (`copy-letters.pl`) that emits shell commands piped to bash.
- `add_letter_data` is a separate path that copies from `../letter-corpus`.

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
- **Alto → TEI conversion** is an undocumented prerequisite for TFS/LH.
- **`ant upload` never deletes** — removed documents linger in eXist until
  cleared manually.
- **Solr heap:** the default 512m OOMs while indexing the full tree (Solr's
  `oom_solr.sh` SIGKILLs the JVM → exit 137); compose sets `SOLR_HEAP=2g`.
- **Suggester** must be built after indexing (`buildOnCommit` is off on purpose).
