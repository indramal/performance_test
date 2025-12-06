#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

// Configuration
const FRAMEWORKS = ["tuono", "bun", "nextjs", "deno"];
const LOGS_DIR = "logs";
const LIGHTHOUSE_DIR = ".lighthouseci";
const REPORTS_DIR = "reports";
const TIMESTAMP = new Date().toISOString().replace(/[:.]/g, "-");

// Ensure reports directory exists
if (!fs.existsSync(REPORTS_DIR)) {
  fs.mkdirSync(REPORTS_DIR, { recursive: true });
}

// Parse wrk output
function parseWrkOutput(content) {
  const results = {
    requestsPerSec: 0,
    transferPerSec: "",
    avgLatency: "",
    maxLatency: "",
    requests: 0,
    duration: "",
    errors: 0,
  };

  try {
    // Requests per second
    const rpsMatch = content.match(/Requests\/sec:\s+([\d.]+)/);
    if (rpsMatch) results.requestsPerSec = parseFloat(rpsMatch[1]);

    // Transfer per second
    const transferMatch = content.match(/Transfer\/sec:\s+([\d.]+\w+)/);
    if (transferMatch) results.transferPerSec = transferMatch[1];

    // Average latency
    const avgLatMatch = content.match(/Latency\s+([\d.]+\w+)/);
    if (avgLatMatch) results.avgLatency = avgLatMatch[1];

    // Max latency
    const maxLatMatch = content.match(/Max\s+([\d.]+\w+)/);
    if (maxLatMatch) results.maxLatency = maxLatMatch[1];

    // Total requests
    const reqMatch = content.match(/([\d.]+[kM]?)\s+requests in/);
    if (reqMatch) results.requests = reqMatch[1];

    // Duration
    const durMatch = content.match(/requests in ([\d.]+\w+)/);
    if (durMatch) results.duration = durMatch[1];

    // Errors
    const errMatch = content.match(/Non-2xx or 3xx responses:\s+(\d+)/);
    if (errMatch) results.errors = parseInt(errMatch[1]);
  } catch (err) {
    console.error("Error parsing wrk output:", err.message);
  }

  return results;
}

// Parse Lighthouse results
function parseLighthouseResults(framework) {
  const lhDir = path.join(LIGHTHOUSE_DIR, framework);

  if (!fs.existsSync(lhDir)) {
    return null;
  }

  try {
    const files = fs.readdirSync(lhDir);
    const jsonFiles = files.filter(
      (f) => f.endsWith(".json") && !f.includes("manifest")
    );

    if (jsonFiles.length === 0) return null;

    // Get the most recent file
    const latestFile = jsonFiles.sort().reverse()[0];
    const content = fs.readFileSync(path.join(lhDir, latestFile), "utf8");
    const data = JSON.parse(content);

    return {
      performance: Math.round((data.categories?.performance?.score || 0) * 100),
      accessibility: Math.round(
        (data.categories?.accessibility?.score || 0) * 100
      ),
      bestPractices: Math.round(
        (data.categories?.["best-practices"]?.score || 0) * 100
      ),
      seo: Math.round((data.categories?.seo?.score || 0) * 100),
      fcp: data.audits?.["first-contentful-paint"]?.displayValue || "N/A",
      lcp: data.audits?.["largest-contentful-paint"]?.displayValue || "N/A",
      tti: data.audits?.["interactive"]?.displayValue || "N/A",
      tbt: data.audits?.["total-blocking-time"]?.displayValue || "N/A",
      cls: data.audits?.["cumulative-layout-shift"]?.displayValue || "N/A",
    };
  } catch (err) {
    console.error(`Error parsing Lighthouse for ${framework}:`, err.message);
    return null;
  }
}

// Parse system information
function parseSystemInfo() {
  const sysInfoPath = path.join(LOGS_DIR, "system-info.txt");

  if (!fs.existsSync(sysInfoPath)) {
    return null;
  }

  try {
    const content = fs.readFileSync(sysInfoPath, "utf8");
    const info = {};

    // Extract key information using patterns
    const osMatch = content.match(
      /PRETTY_NAME="([^"]+)"|Operating System: ([^\n]+)/
    );
    info.os = osMatch ? osMatch[1] || osMatch[2] : "Unknown";

    const cpuMatch = content.match(/Model: ([^\n]+)/);
    info.cpu = cpuMatch ? cpuMatch[1].trim() : "Unknown";

    const coresMatch = content.match(/Cores: (\d+)/);
    info.cores = coresMatch ? coresMatch[1] : "Unknown";

    const archMatch = content.match(/Architecture: ([^\n]+)/);
    info.architecture = archMatch ? archMatch[1].trim() : "Unknown";

    const ramMatch = content.match(/Total RAM: ([^\n]+)/);
    info.ram = ramMatch ? ramMatch[1].trim() : "Unknown";

    const gpuMatch = content.match(
      /VGA[^\n]*: ([^\n]+)|Chipset Model: ([^\n]+)/
    );
    info.gpu = gpuMatch
      ? (gpuMatch[1] || gpuMatch[2] || "Unknown").trim()
      : "Not detected";

    const kernelMatch = content.match(/Kernel Version:\s*([^\n]+)/);
    info.kernel = kernelMatch ? kernelMatch[1].trim() : "Unknown";

    // Extract runtime versions
    const nodeMatch = content.match(/Node: (v[\d.]+)/);
    info.nodeVersion = nodeMatch ? nodeMatch[1] : "N/A";

    const bunMatch = content.match(/Bun: ([\d.]+)/);
    info.bunVersion = bunMatch ? bunMatch[1] : "N/A";

    const denoMatch = content.match(/deno ([\d.]+)/);
    info.denoVersion = denoMatch ? denoMatch[1] : "N/A";

    const rustMatch = content.match(/rustc ([\d.]+)/);
    info.rustVersion = rustMatch ? rustMatch[1] : "N/A";

    const dateMatch = content.match(/Date & Time:\s*([^\n]+)/);
    info.timestamp = dateMatch ? dateMatch[1].trim() : new Date().toISOString();

    return info;
  } catch (err) {
    console.error("Error parsing system info:", err.message);
    return null;
  }
}

// Collect system information
const systemInfo = parseSystemInfo();

// Collect all benchmark data
const benchmarkData = {};

FRAMEWORKS.forEach((framework) => {
  const wrkLogPath = path.join(LOGS_DIR, `${framework}_wrk.log`);

  if (fs.existsSync(wrkLogPath)) {
    const wrkContent = fs.readFileSync(wrkLogPath, "utf8");
    benchmarkData[framework] = {
      wrk: parseWrkOutput(wrkContent),
      lighthouse: parseLighthouseResults(framework),
    };
  }
});

// Generate markdown report
function generateMarkdownReport() {
  let md = `# Performance Benchmark Report\n\n`;
  md += `**Generated:** ${new Date().toLocaleString()}\n\n`;

  // Add system information section
  if (systemInfo) {
    md += `## 💻 System Information\n\n`;
    md += `> [!NOTE]\n`;
    md += `> Performance results are specific to this hardware configuration.\n\n`;

    md += `| Component | Details |\n`;
    md += `|-----------|----------|\n`;
    md += `| **Operating System** | ${systemInfo.os} |\n`;
    md += `| **Kernel** | ${systemInfo.kernel} |\n`;
    md += `| **CPU** | ${systemInfo.cpu} |\n`;
    md += `| **CPU Cores** | ${systemInfo.cores} |\n`;
    md += `| **Architecture** | ${systemInfo.architecture} |\n`;
    md += `| **RAM** | ${systemInfo.ram} |\n`;
    md += `| **GPU** | ${systemInfo.gpu} |\n`;
    md += `\n`;

    md += `**Runtime Versions:**\n`;
    md += `- Node.js: ${systemInfo.nodeVersion}\n`;
    md += `- Bun: ${systemInfo.bunVersion}\n`;
    md += `- Deno: ${systemInfo.denoVersion}\n`;
    md += `- Rust: ${systemInfo.rustVersion}\n\n`;

    md += `**Benchmark Timestamp:** ${systemInfo.timestamp}\n\n`;
    md += `---\n\n`;
  }

  md += `## 📊 Summary\n\n`;

  // Summary table - sorted by Requests/sec (descending)
  md += `| Framework | Requests/sec | Avg Latency | Performance | Accessibility | SEO |\n`;
  md += `|-----------|--------------|-------------|-------------|---------------|-----|\n`;

  // Create array of frameworks with their data for sorting
  const frameworksWithData = FRAMEWORKS.map((framework) => ({
    name: framework,
    data: benchmarkData[framework],
  })).filter((item) => item.data); // Only include frameworks with data

  // Sort by Requests/sec (descending - highest first)
  frameworksWithData.sort((a, b) => {
    const rpsA = a.data.wrk.requestsPerSec || 0;
    const rpsB = b.data.wrk.requestsPerSec || 0;
    return rpsB - rpsA; // Descending order
  });

  // Generate sorted table rows
  frameworksWithData.forEach(({ name, data }) => {
    const rps = data.wrk.requestsPerSec.toFixed(2);
    const latency = data.wrk.avgLatency;
    const perf = data.lighthouse ? `${data.lighthouse.performance}%` : "N/A";
    const a11y = data.lighthouse ? `${data.lighthouse.accessibility}%` : "N/A";
    const seo = data.lighthouse ? `${data.lighthouse.seo}%` : "N/A";

    md += `| **${name}** | ${rps} | ${latency} | ${perf} | ${a11y} | ${seo} |\n`;
  });

  md += `\n---\n\n`;

  // Detailed results for each framework
  FRAMEWORKS.forEach((framework) => {
    const data = benchmarkData[framework];
    if (!data) return;

    md += `## ${framework.toUpperCase()}\n\n`;

    // wrk Results
    md += `### HTTP Benchmarks (wrk)\n\n`;
    md += `| Metric | Value |\n`;
    md += `|--------|-------|\n`;
    md += `| Requests/sec | ${data.wrk.requestsPerSec.toFixed(2)} |\n`;
    md += `| Transfer/sec | ${data.wrk.transferPerSec} |\n`;
    md += `| Avg Latency | ${data.wrk.avgLatency} |\n`;
    md += `| Max Latency | ${data.wrk.maxLatency} |\n`;
    md += `| Total Requests | ${data.wrk.requests} |\n`;
    md += `| Duration | ${data.wrk.duration} |\n`;
    md += `| Errors | ${data.wrk.errors} |\n\n`;

    // Lighthouse Results
    if (data.lighthouse) {
      md += `### Lighthouse Scores\n\n`;
      md += `| Category | Score |\n`;
      md += `|----------|-------|\n`;
      md += `| Performance | ${data.lighthouse.performance}% |\n`;
      md += `| Accessibility | ${data.lighthouse.accessibility}% |\n`;
      md += `| Best Practices | ${data.lighthouse.bestPractices}% |\n`;
      md += `| SEO | ${data.lighthouse.seo}% |\n\n`;

      md += `### Core Web Vitals\n\n`;
      md += `| Metric | Value |\n`;
      md += `|--------|-------|\n`;
      md += `| First Contentful Paint | ${data.lighthouse.fcp} |\n`;
      md += `| Largest Contentful Paint | ${data.lighthouse.lcp} |\n`;
      md += `| Time to Interactive | ${data.lighthouse.tti} |\n`;
      md += `| Total Blocking Time | ${data.lighthouse.tbt} |\n`;
      md += `| Cumulative Layout Shift | ${data.lighthouse.cls} |\n\n`;
    }

    md += `---\n\n`;
  });

  // Performance comparison chart
  md += `## Performance Comparison\n\n`;
  md += "```mermaid\n";
  md += "graph LR\n";
  md += '    subgraph "Requests per Second"\n';
  FRAMEWORKS.forEach((framework) => {
    const data = benchmarkData[framework];
    if (data) {
      md += `        ${framework}["${framework}: ${data.wrk.requestsPerSec.toFixed(
        0
      )} req/s"]\n`;
    }
  });
  md += "    end\n";
  md += "```\n\n";

  return md;
}

// Generate and save report
const report = generateMarkdownReport();
const logsReportPath = path.join(LOGS_DIR, "benchmark-report.md");

// Save to logs for GitHub Actions workflow to pick up
fs.writeFileSync(logsReportPath, report);

console.log(`✅ Report generated and saved to: ${logsReportPath}`);
console.log(`📋 Workflow will copy to: reports/benchmark-[timestamp].md`);
