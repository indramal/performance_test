# Multi-Framework Performance Testing

Comprehensive performance benchmarking framework comparing **Tuono**, **Bun**, **Next.js**, **Deno**, **Astro (CSR)**, **Astro (SSR)**, **TanStack Start**, and **Astro+Askama** with identical UI and backend implementations.

## 🎯 Overview

This repository contains eight equivalent SSR/CSR React applications built with different frameworks:

- **Tuono** (Rust + React SSR) - Port 3000
- **Bun** (Bun runtime + React) - Port 3001
- **Next.js** (Node.js + React SSR) - Port 3002
- **Deno Fresh** (Deno + Preact) - Port 3003
- **Astro + React CSR** (Client-Side Rendering) - Port 3004
- **Astro + React + Bun SSR** (Server-Side Rendering with Bun) - Port 3005
- **TanStack Start + Bun** (SSR with TanStack Router) - Port 3006
- **Astro + React + Askama** (Hybrid: Rust templating + React CSR) - Port 3007

All applications implement the same UI and functionality for fair performance comparison.

## 📊 Benchmarking Tools

### HTTP Performance (wrk)
- **Tool**: [wrk](https://github.com/wg/wrk)
- **Metrics**: Requests/sec, latency, throughput
- **Configuration**: 30s duration, 12 threads, 400 connections

### Web Performance (Lighthouse CI)
- **Tool**: [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci)
- **Metrics**: Performance score, Core Web Vitals, Accessibility, SEO
- **Configuration**: 3 runs per framework, averaged results

## 🚀 Quick Start

### Prerequisites

```bash
# Install Node.js, Bun, Deno, and Rust
node --version  # v20+
bun --version   # 1.0+
deno --version  # 1.37+
rustc --version # 1.70+

# Install wrk
sudo apt-get install wrk  # Ubuntu/Debian
brew install wrk          # macOS

# Install Lighthouse CI
npm install -g @lhci/cli
```

### Run Benchmarks Locally

```bash
# Make script executable
chmod +x scripts/run-benchmarks.sh

# Run all benchmarks
./scripts/run-benchmarks.sh

# View results
cat reports/latest/index.md
```

## 📁 Project Structure

```
performance_test/
├── tuono-test/           # Tuono (Rust + React SSR)
├── bun-test/             # Bun SSR
├── nextjs-test/          # Next.js 14+
├── deno-test/            # Deno Fresh
├── astro-react-csr/      # Astro + React (CSR)
├── astro-react-bun-ssr/  # Astro + React + Bun (SSR)
├── tanstack-start-bun/   # TanStack Start + Bun
├── astro-react-askama/   # Astro + React + Askama
├── scripts/
│   ├── run-benchmarks.sh     # Main benchmark orchestrator
│   └── generate-report.js    # Report generator
├── config/
│   └── benchmark-config.json # Framework configuration
├── reports/
│   ├── latest/          # Latest benchmark results
│   └── history/         # Historical archives
├── .github/workflows/
│   └── performance-benchmark.yml
└── README.md
```

## 🏃 Individual Framework Commands

### Tuono
```bash
cd tuono-test
npm install
cargo run --release
# Server: http://localhost:3000
```

### Bun
```bash
cd bun-test
bun install
bun run start
# Server: http://localhost:3001
```

### Next.js
```bash
cd nextjs-test
npm install
npm run build
npm run start
# Server: http://localhost:3002
```

### Deno Fresh
```bash
cd deno-test
deno task start
# Server: http://localhost:3003
```

### Astro + React (CSR)
```bash
cd astro-react-csr
npm install
npm run build
npm run preview -- --port 3004
# Server: http://localhost:3004
```

### Astro + React + Bun (SSR)
```bash
cd astro-react-bun-ssr
bun install
bun run build
bun run ./dist/server/entry.mjs
# Server: http://localhost:3005
```

### TanStack Start + Bun
```bash
cd tanstack-start-bun
bun install
bun run build
bun run .output/server/index.mjs
# Server: http://localhost:3006
```

### Astro + React + Askama
```bash
cd astro-react-askama
npm install
npm run build
cargo build --release
cargo run --release
# Server: http://localhost:3007
```

## 🤖 GitHub Actions

Benchmarks run automatically on every push to `main` branch:

1. Sets up all required environments (Node, Bun, Deno, Rust)
2. Installs dependencies and builds projects
3. Starts all servers concurrently
4. Runs wrk and Lighthouse benchmarks
5. Generates markdown reports
6. Commits results to `reports/` directory
7. Archives results as artifacts

### Manual Trigger

You can manually trigger benchmarks from the GitHub Actions tab.

## 📈 Reports

### Latest Results
- **Location**: `reports/latest/index.md`
- **Updated**: On every commit to main
- **Contents**: Summary tables, detailed metrics, performance charts

### Historical Data
- **Location**: `reports/history/YYYY-MM-DD/`
- **Retention**: Permanent
- **Format**: Timestamped markdown files

## 🔧 Customization

### Adjust Benchmark Settings

Edit `scripts/run-benchmarks.sh`:

```bash
DURATION=30s        # Test duration
THREADS=12          # Number of threads
CONNECTIONS=400     # Concurrent connections
```

### Add New Framework

1. Create new project directory
2. Implement matching UI/backend
3. Add to `FRAMEWORKS` array in `run-benchmarks.sh`
4. Update GitHub Actions workflow
5. Update this README

## 📊 Sample Metrics

Expected baseline metrics:

| Framework | Requests/sec | Avg Latency | Performance Score |
|-----------|--------------|-------------|-------------------|
| Tuono     | 15000+       | < 10ms      | 95+               |
| Bun       | 12000+       | < 15ms      | 90+               |
| Next.js   | 8000+        | < 20ms      | 90+               |
| Deno      | 10000+       | < 15ms      | 92+               |
| Astro CSR | 9000+        | < 18ms      | 92+               |
| Astro SSR | 11000+       | < 16ms      | 93+               |
| TanStack  | 10000+       | < 17ms      | 91+               |
| Askama    | 14000+       | < 12ms      | 94+               |

*Actual results vary based on hardware and configuration*

## 🛠️ Development

### File Structure

Each framework implements:
- **Homepage**: Root route with server-side data fetching
- **API Endpoint**: `/api/data` returning JSON
- **Static Assets**: Favicon, logos (rust.svg, react.svg)
- **Styles**: Global CSS with animations

### Consistent UI

All frameworks render identical UI:
- Header with links to Crates.io and npm
- Large "TUONO" title
- Rotating Rust and React logos
- Subtitle from server-side data
- GitHub button link

## 📝 License

This is a performance testing framework. Individual framework implementations follow their respective licenses.

## 🤝 Contributing

To add benchmarks or improve the testing framework:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run benchmarks locally
5. Submit a pull request

## 📚 Resources

- [Tuono Documentation](https://tuono.dev)
- [Bun Documentation](https://bun.sh)
- [Next.js Documentation](https://nextjs.org)
- [Deno Fresh Documentation](https://fresh.deno.dev)
- [wrk Documentation](https://github.com/wg/wrk)
- [Lighthouse CI Documentation](https://github.com/GoogleChrome/lighthouse-ci)

## ⚡ Performance Tips

### For Production Deployments:
- Always build in production mode
- Enable all optimizations
- Use caching strategies
- Configure CDN for static assets
- Monitor with real user metrics (RUM)

### For Fair Comparison:
- Same hardware/environment
- Same UI complexity
- Same data payload size
- Multiple test runs
- Warm-up period before testing
