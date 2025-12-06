#!/bin/bash

set -e

echo "🚀 Starting Performance Benchmarks"
echo "=================================="

# Configuration
DURATION=30s
THREADS=12
CONNECTIONS=400
RESULTS_DIR="reports/latest"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Frameworks and ports
declare -A FRAMEWORKS=(
    ["tuono"]="3000"
    ["bun"]="3001"
    ["nextjs"]="3002"
    ["deno"]="3003"
)

# Server PIDs
declare -A SERVER_PIDS

# Function to wait for server to be ready
wait_for_server() {
    local port=$1
    local name=$2
    local max_attempts=30
    local attempt=0
    
    echo "⏳ Waiting for $name server on port $port..."
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:$port/ > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $name server is ready"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    echo "❌ Failed to connect to $name server on port $port"
    return 1
}

# Function to stop all servers
cleanup() {
    echo ""
    echo "🛑 Stopping all servers..."
    for name in "${!SERVER_PIDS[@]}"; do
        pid=${SERVER_PIDS[$name]}
        if [ ! -z "$pid" ] && ps -p $pid > /dev/null 2>&1; then
            echo "  Stopping $name (PID: $pid)"
            kill $pid 2>/dev/null || true
        fi
    done
    
    # Wait a bit for graceful shutdown
    sleep 2
    
    # Force kill any remaining processes
    for port in "${FRAMEWORKS[@]}"; do
        lsof -ti:$port | xargs kill -9 2>/dev/null || true
    done
}

trap cleanup EXIT

echo ""
echo "💻 Collecting system information..."
mkdir -p logs

# Collect system information
{
    echo "=== SYSTEM INFORMATION ==="
    echo ""
    echo "OS Information:"
    if [ -f /etc/os-release ]; then
        cat /etc/os-release
    elif [ "$(uname)" == "Darwin" ]; then
        echo "Operating System: macOS $(sw_vers -productVersion)"
    else
        uname -a
    fi
    echo ""
    
    echo "CPU Information:"
    if [ -f /proc/cpuinfo ]; then
        echo "Model: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
        echo "Cores: $(grep -c ^processor /proc/cpuinfo)"
        echo "Architecture: $(uname -m)"
    elif [ "$(uname)" == "Darwin" ]; then
        echo "Model: $(sysctl -n machdep.cpu.brand_string)"
        echo "Cores: $(sysctl -n hw.ncpu)"
        echo "Architecture: $(uname -m)"
    else
        echo "CPU Info: $(uname -p)"
    fi
    echo ""
    
    echo "Memory Information:"
    if [ -f /proc/meminfo ]; then
        echo "Total RAM: $(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')"
        echo "Available RAM: $(grep MemAvailable /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')"
    elif [ "$(uname)" == "Darwin" ]; then
        echo "Total RAM: $(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024)) GB"
    else
        free -h 2>/dev/null || echo "Memory info not available"
    fi
    echo ""
    
    echo "GPU Information:"
    if command -v lspci &> /dev/null; then
        lspci | grep -i vga || echo "No GPU detected via lspci"
        lspci | grep -i 3d || echo ""
    elif [ "$(uname)" == "Darwin" ]; then
        system_profiler SPDisplaysDataType 2>/dev/null | grep "Chipset Model" || echo "GPU info not available"
    else
        echo "GPU info not available (lspci not found)"
    fi
    echo ""
    
    echo "Disk Information:"
    df -h / | tail -1 | awk '{print "Root Partition: " $2 " (Used: " $3 ", Available: " $4 ")"}'
    echo ""
    
    echo "Kernel Version:"
    uname -r
    echo ""
    
    echo "Runtime Versions:"
    node --version 2>/dev/null && echo "Node: $(node --version)" || echo "Node: Not installed"
    bun --version 2>/dev/null && echo "Bun: $(bun --version)" || echo "Bun: Not installed"
    deno --version 2>/dev/null | head -1 || echo "Deno: Not installed"
    rustc --version 2>/dev/null || echo "Rust: Not installed"
    echo ""
    
    echo "Date & Time:"
    date
    echo ""
} > logs/system-info.txt

cat logs/system-info.txt
echo ""

echo "📦 Installing dependencies..."

# Install Tuono dependencies
if [ -d "tuono-test" ]; then
    echo -e "${BLUE}Tuono:${NC} Installing dependencies"
    cd tuono-test
    npm install > /dev/null 2>&1 || true
    cd ..
fi

# Install Bun dependencies
if [ -d "bun-test" ] && command -v bun &> /dev/null; then
    echo -e "${BLUE}Bun:${NC} Installing dependencies"
    cd bun-test
    bun install > /dev/null 2>&1 || true
    cd ..
fi

# Install Next.js dependencies
if [ -d "nextjs-test" ]; then
    echo -e "${BLUE}Next.js:${NC} Installing dependencies"
    cd nextjs-test
    npm install > /dev/null 2>&1 || true
    npm run build > /dev/null 2>&1 || true
    cd ..
fi

echo ""
echo "🏗️  Starting servers..."

# Start Tuono server
if [ -d "tuono-test" ]; then
    cd tuono-test
    echo -e "${BLUE}Tuono:${NC} Starting on port 3000"
    cargo run --release > ../logs/tuono.log 2>&1 &
    SERVER_PIDS["tuono"]=$!
    cd ..
fi

# Start Bun server
if [ -d "bun-test" ] && command -v bun &> /dev/null; then
    cd bun-test
    echo -e "${BLUE}Bun:${NC} Starting on port 3001"
    NODE_ENV=production bun run src/server.tsx > ../logs/bun.log 2>&1 &
    SERVER_PIDS["bun"]=$!
    cd ..
fi

# Start Next.js server
if [ -d "nextjs-test" ]; then
    cd nextjs-test
    echo -e "${BLUE}Next.js:${NC} Starting on port 3002"
    npm run start > ../logs/nextjs.log 2>&1 &
    SERVER_PIDS["nextjs"]=$!
    cd ..
fi

# Start Deno server
if [ -d "deno-test" ] && command -v deno &> /dev/null; then
    cd deno-test
    echo -e "${BLUE}Deno:${NC} Starting on port 3003"
    deno run -A main.ts > ../logs/deno.log 2>&1 &
    SERVER_PIDS["deno"]=$!
    cd ..
fi

echo ""
echo "⏳ Waiting for all servers to be ready..."
sleep 5

# Wait for each server
for name in "${!FRAMEWORKS[@]}"; do
    port=${FRAMEWORKS[$name]}
    if [ ! -z "${SERVER_PIDS[$name]}" ]; then
        wait_for_server $port $name || echo "Warning: $name server may not be ready"
    fi
done

echo ""
echo "📊 Running wrk benchmarks..."
mkdir -p logs

# Run wrk for each framework
for name in "${!FRAMEWORKS[@]}"; do
    port=${FRAMEWORKS[$name]}
    if [ ! -z "${SERVER_PIDS[$name]}" ]; then
        echo -e "${BLUE}$name:${NC} Running benchmark..."
        wrk -t$THREADS -c$CONNECTIONS -d$DURATION http://localhost:$port/ > "logs/${name}_wrk.log" 2>&1
        echo -e "${GREEN}✓${NC} Completed"
    fi
done

echo ""
echo "💡 Running Lighthouse CI tests..."

# Install lhci if not present
if ! command -v lhci &> /dev/null; then
    echo "Installing @lhci/cli..."
    npm install -g @lhci/cli > /dev/null 2>&1
fi

mkdir -p .lighthouseci

# Run Lighthouse for each framework
for name in "${!FRAMEWORKS[@]}"; do
    port=${FRAMEWORKS[$name]}
    if [ ! -z "${SERVER_PIDS[$name]}" ]; then
        echo -e "${BLUE}$name:${NC} Running Lighthouse..."
        lhci autorun \
            --collect.url="http://localhost:$port/" \
            --collect.numberOfRuns=3 \
            --upload.target=filesystem \
            --upload.outputDir=".lighthouseci/$name" \
            > /dev/null 2>&1 || echo "Warning: Lighthouse failed for $name"
        echo -e "${GREEN}✓${NC} Completed"
    fi
done

echo ""
echo "📈 Generating reports..."
node scripts/generate-report.js

echo ""
echo -e "${GREEN}✅ Benchmarks completed!${NC}"
echo "📄 Reports saved to: $RESULTS_DIR"
