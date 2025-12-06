# Updated Report Structure

## ✅ Changes Made

### Simplified Report Structure

Reports are now saved directly in the `reports/` folder with timestamp-based filenames:

```
reports/
├── benchmark-20251206_130000.md
├── benchmark-20251206_150000.md
└── benchmark-20251206_180000.md
```

### Log Folder Management

- Logs folder is **cleaned before each new benchmark run**
- Only `.gitkeep` file is preserved to maintain the folder structure in git
- All generated logs are added to git for each benchmark commit

## 📁 Folder Structure

```
performance_test/
├── reports/
│   ├── benchmark-YYYYMMDD_HHMMSS.md  # Timestamped reports
│   └── benchmark-YYYYMMDD_HHMMSS.md  
├── logs/
│   ├── .gitkeep                       # Preserved file
│   ├── benchmark-report.md            # Temporary (cleaned each run)
│   ├── tuono.log                      # Server logs (cleaned each run)
│   ├── bun.log
│   ├── nextjs.log
│   ├── deno.log
│   ├── tuono_wrk.log                  # Benchmark logs (cleaned each run)
│   ├── bun_wrk.log
│   ├── nextjs_wrk.log
│   ├── deno_wrk.log
│   └── system-info.txt                # System info (cleaned each run)
└── .lighthouseci/
    └── */                             # Lighthouse results (not cleaned)
```

## 🔄 Workflow Process

### 1. Run Benchmarks
```bash
./scripts/run-benchmarks.sh
```

This generates:
- Log files in `logs/`
- Lighthouse results in `.lighthouseci/`
- Temporary report: `logs/benchmark-report.md`

### 2. GitHub Actions Commit Step

When workflow completes:

1. **Creates reports folder**:
   ```bash
   mkdir -p reports
   ```

2. **Copies report with timestamp**:
   ```bash
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   cp logs/benchmark-report.md reports/benchmark-$TIMESTAMP.md
   ```

3. **Cleans logs folder** (keeps .gitkeep):
   ```bash
   find logs -type f ! -name '.gitkeep' -delete
   ```

4. **Commits both reports and cleaned logs**:
   ```bash
   git add reports/benchmark-$TIMESTAMP.md
   git add logs/
   git commit -m "docs: Add benchmark report benchmark-$TIMESTAMP.md [skip ci]"
   git push
   ```

## 📊 Benefits

✅ **Simple structure** - All reports in one flat folder  
✅ **Timestamped** - Easy to track performance over time  
✅ **Clean logs** - Logs folder emptied before each run (no accumulation)  
✅ **Git tracked** - Both reports AND current run logs are committed  
✅ **No confusion** - No latest/history subfolders to manage  

## 🎯 File Lifecycle

### Report Files (reports/)
- **Created**: After each benchmark run
- **Never deleted**: Permanent historical record
- **Naming**: `benchmark-YYYYMMDD_HHMMSS.md`

### Log Files (logs/)
- **Created**: During each benchmark run
- **Deleted**: Before next benchmark run
- **Committed**: After each run (shows latest run's logs)
- **Exception**: `.gitkeep` always preserved

## 📥 Artifacts

GitHub Actions uploads artifacts containing:
- All reports: `reports/*.md`
- Latest benchmark report: `logs/benchmark-report.md`
- Current run logs: `logs/*.log`
- System info: `logs/system-info.txt`
- Lighthouse data: `.lighthouseci/**/*.json`

## Example Timeline

**Run 1** (2025-12-06 13:00):
```
reports/
└── benchmark-20251206_130000.md

logs/
├── .gitkeep
├── tuono.log
├── tuono_wrk.log
└── system-info.txt
```

**Run 2** (2025-12-06 15:00):
```
reports/
├── benchmark-20251206_130000.md  # Previous run (kept)
└── benchmark-20251206_150000.md  # New run

logs/
├── .gitkeep
├── tuono.log                      # NEW (old one deleted)
├── tuono_wrk.log                  # NEW (old one deleted)
└── system-info.txt                # NEW (old one deleted)
```
