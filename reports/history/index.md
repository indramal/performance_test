# Performance Benchmark Report

**Generated:** 12/6/2025, 8:48:37 AM

## 💻 System Information

> [!NOTE]
> Performance results are specific to this hardware configuration.

| Component | Details |
|-----------|----------|
| **Operating System** | Ubuntu 24.04.3 LTS |
| **Kernel** | 6.11.0-1018-azure |
| **CPU** | AMD EPYC 7763 64-Core Processor |
| **CPU Cores** | 4 |
| **Architecture** | x86_64 |
| **RAM** | 15.62 GB |
| **GPU** | Microsoft Corporation Hyper-V virtual VGA |

**Runtime Versions:**
- Node.js: v20.19.6
- Bun: 1.3.3
- Deno: 1.46.3
- Rust: 1.91.1

**Benchmark Timestamp:** Sat Dec  6 08:44:03 UTC 2025

---

## 📊 Summary

| Framework | Requests/sec | Avg Latency | Performance | Accessibility | SEO |
|-----------|--------------|-------------|-------------|---------------|-----|
| **tuono** | 9113.24 | 43.82ms | 90% | 59% | 67% |
| **bun** | 25804.79 | 15.34ms | N/A | N/A | N/A |
| **nextjs** | 2213.39 | 110.22ms | 95% | 100% | 100% |
| **deno** | 10982.24 | 35.59ms | 96% | 90% | 91% |

---

## TUONO

### HTTP Benchmarks (wrk)

| Metric | Value |
|--------|-------|
| Requests/sec | 9113.24 |
| Transfer/sec | 12.16MB |
| Avg Latency | 43.82ms |
| Max Latency |  |
| Total Requests | 273918 |
| Duration | 30.06s |
| Errors | 0 |

### Lighthouse Scores

| Category | Score |
|----------|-------|
| Performance | 90% |
| Accessibility | 59% |
| Best Practices | 93% |
| SEO | 67% |

### Core Web Vitals

| Metric | Value |
|--------|-------|
| First Contentful Paint | 2.9 s |
| Largest Contentful Paint | 2.9 s |
| Time to Interactive | 2.9 s |
| Total Blocking Time | 0 ms |
| Cumulative Layout Shift | 0.001 |

---

## BUN

### HTTP Benchmarks (wrk)

| Metric | Value |
|--------|-------|
| Requests/sec | 25804.79 |
| Transfer/sec | 3.49MB |
| Avg Latency | 15.34ms |
| Max Latency |  |
| Total Requests | 774796 |
| Duration | 30.03s |
| Errors | 774796 |

---

## NEXTJS

### HTTP Benchmarks (wrk)

| Metric | Value |
|--------|-------|
| Requests/sec | 2213.39 |
| Transfer/sec | 14.21MB |
| Avg Latency | 110.22ms |
| Max Latency |  |
| Total Requests | 66511 |
| Duration | 30.05s |
| Errors | 0 |

### Lighthouse Scores

| Category | Score |
|----------|-------|
| Performance | 95% |
| Accessibility | 100% |
| Best Practices | 100% |
| SEO | 100% |

### Core Web Vitals

| Metric | Value |
|--------|-------|
| First Contentful Paint | 2.3 s |
| Largest Contentful Paint | 2.4 s |
| Time to Interactive | 2.4 s |
| Total Blocking Time | 0 ms |
| Cumulative Layout Shift | 0.01 |

---

## DENO

### HTTP Benchmarks (wrk)

| Metric | Value |
|--------|-------|
| Requests/sec | 10982.24 |
| Transfer/sec | 11.69MB |
| Avg Latency | 35.59ms |
| Max Latency |  |
| Total Requests | 330046 |
| Duration | 30.05s |
| Errors | 0 |

### Lighthouse Scores

| Category | Score |
|----------|-------|
| Performance | 96% |
| Accessibility | 90% |
| Best Practices | 100% |
| SEO | 91% |

### Core Web Vitals

| Metric | Value |
|--------|-------|
| First Contentful Paint | 2.3 s |
| Largest Contentful Paint | 2.3 s |
| Time to Interactive | 2.3 s |
| Total Blocking Time | 0 ms |
| Cumulative Layout Shift | 0.01 |

---

## Performance Comparison

```mermaid
graph LR
    subgraph "Requests per Second"
        tuono["tuono: 9113 req/s"]
        bun["bun: 25805 req/s"]
        nextjs["nextjs: 2213 req/s"]
        deno["deno: 10982 req/s"]
    end
```

