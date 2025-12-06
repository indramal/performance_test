# Performance Benchmark History

This directory contains historical benchmark results organized by date.

## Structure

```
history/
└── YYYY-MM-DD/
    └── benchmark-YYYYMMDD_HHMMSS.md
```

## Usage

Each subdirectory represents benchmarks run on a specific date, with timestamped files for each run.

## Viewing History

To compare performance over time:

```bash
# List all historical benchmarks
find history/ -name "*.md" -type f

# View specific date
cat history/2025-12-06/benchmark-*.md
```

---

*Historical reports will be automatically added by GitHub Actions*
