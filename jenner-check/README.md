# Jenner compatibility bundles

This directory was added by a pull request from the
[Jenner](https://jenneranalytics.com) project. Each `tNNN_*` subdirectory
is a small, self-contained bundle built from code in this repository,
captured together with the response the Jenner API produced for it.

## What's in here

```
jenner-check/
├── README.md                     # this file
├── run_jenner.sas                # SAS runner (PROC HTTP), %jenner_run / %jenner_check_all
├── run_jenner.sh                 # mac/linux curl wrapper
├── run_jenner.bat                # Windows curl wrapper
└── tNNN_<name>/
    ├── script.sas                # the code under test (derived from this repo)
    ├── autoexec.sas              # session setup submitted ahead of the script
    ├── expected.json             # stable response fields from a passing run
    ├── expected/
    │   ├── log.txt               # captured log, verbatim
    │   ├── output.txt            # captured listing, verbatim
    │   └── files.md              # links to generated files/datasets
    └── meta.json                 # provenance: source file, commit, notes
```

## How to run

From SAS (9.4 M5+, needs PROC HTTP):

```sas
%include 'run_jenner.sas';
%jenner_check_all();        /* every bundle */
```

From a shell:

```bash
./run_jenner.sh --all                          # every bundle
./run_jenner.sh t001_lepetit_fox_rose_prince   # just one
```

Or with plain curl:

```bash
curl -X POST https://api.jenneranalytics.com/v1/run \
  -F "script=@t001_lepetit_fox_rose_prince/script.sas" \
  -F "deterministic=1" -F "timeout=60"
```

The API returns JSON with the run's `status`, `log`, `output` (listing),
and links to any generated files and datasets.
