# Report Folder Structure

## Overview

Benchmark reports are now properly saved to both `reports/latest` and `reports/history` folders.

## Folder Structure

```
reports/
├── latest/
│   └── index.md           # Latest benchmark results (always current)
└── history/
    └── YYYY-MM-DD/
        └── benchmark-YYYYMMDD_HHMMSS.md  # Historical timestamped reports
```

## How It Works

### 1. Report Generation (`generate-report.js`)

The script generates the benchmark report and saves it to three locations:

- `reports/latest/benchmark-[timestamp].md` - Timestamped version
- `reports/latest/index.md` - Current report (always updated)
- `logs/benchmark-report.md` - Temporary copy for GitHub Actions

### 2. GitHub Actions Workflow

When benchmarks complete:

1. **Creates folders**:
   ```bash
   mkdir -p reports/latest
   mkdir -p reports/history
   mkdir -p reports/history/$DATE
   ```

2. **Copies reports**:
   - `logs/benchmark-report.md` → `reports/latest/index.md`
   - `logs/benchmark-report.md` → `reports/history/$DATE/benchmark-$TIMESTAMP.md`

3. **Commits and pushes**:
   ```bash
   git add reports/latest/ reports/history/
   git commit -m "docs: Update performance benchmarks [skip ci]"
   git push
   ```

## Accessing Reports

### Latest Report
Always available at: `reports/latest/index.md`

### Historical Reports
Browse by date in: `reports/history/YYYY-MM-DD/`

Each historical report is timestamped for tracking performance over time.

## Benefits

✅ **Latest reports** - Always available at a fixed location  
✅ **Historical tracking** - All benchmarks preserved by date  
✅ **GitHub Actions compatible** - Works with automated workflows  
✅ **No data loss** - Old reports are never overwritten  

## Example

After running benchmarks on 2025-12-06 at 13:45:30:

```
reports/
├── latest/
│   └── index.md                                    # Current benchmark
└── history/
    └── 2025-12-06/
        └── benchmark-20251206_134530.md            # Timestamped snapshot
```

Running again at 15:20:10 on the same day:

```
reports/
├── latest/
│   └── index.md                                    # Updated with new results
└── history/
    └── 2025-12-06/
        ├── benchmark-20251206_134530.md            # First run
        └── benchmark-20251206_152010.md            # Second run
```
