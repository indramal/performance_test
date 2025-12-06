#!/bin/bash

set -e

echo "🚀 Starting Performance Benchmarks"
echo "=================================="

# Load configuration from JSON
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../config/benchmark-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "📋 Loading configuration from: $CONFIG_FILE"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed. Please install with: sudo apt-get install jq"
    exit 1
fi

# Load benchmark configuration
DURATION=$(jq -r '.benchmark.duration' "$CONFIG_FILE")
THREADS=$(jq -r '.benchmark.threads' "$CONFIG_FILE")
CONNECTIONS=$(jq -r '.benchmark.connections' "$CONFIG_FILE")
RESULTS_DIR=$(jq -r '.benchmark.results_dir' "$CONFIG_FILE")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Load server configuration
STARTUP_WAIT=$(jq -r '.server.startup_wait_seconds' "$CONFIG_FILE")
HEALTH_CHECK_MAX=$(jq -r '.server.health_check_max_attempts' "$CONFIG_FILE")
HEALTH_CHECK_INTERVAL=$(jq -r '.server.health_check_interval_seconds' "$CONFIG_FILE")
SHUTDOWN_WAIT=$(jq -r '.server.graceful_shutdown_wait_seconds' "$CONFIG_FILE")

# Load Lighthouse configuration
LIGHTHOUSE_RUNS=$(jq -r '.lighthouse.number_of_runs' "$CONFIG_FILE")
LIGHTHOUSE_DIR=$(jq -r '.lighthouse.output_dir' "$CONFIG_FILE")

# Load logging configuration
LOG_DIR=$(jq -r '.logging.directory' "$CONFIG_FILE")

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load frameworks from config
declare -A FRAMEWORKS
declare -A FRAMEWORK_DIRS
declare -A INSTALL_COMMANDS
declare -A BUILD_COMMANDS
declare -A START_COMMANDS

for framework in $(jq -r '.frameworks | keys[]' "$CONFIG_FILE"); do
    FRAMEWORKS["$framework"]=$(jq -r ".frameworks.\"$framework\".port" "$CONFIG_FILE")
    FRAMEWORK_DIRS["$framework"]=$(jq -r ".frameworks.\"$framework\".directory" "$CONFIG_FILE")
    INSTALL_COMMANDS["$framework"]=$(jq -r ".frameworks.\"$framework\".install_command" "$CONFIG_FILE")
    BUILD_COMMANDS["$framework"]=$(jq -r ".frameworks.\"$framework\".build_command" "$CONFIG_FILE")
    START_COMMANDS["$framework"]=$(jq -r ".frameworks.\"$framework\".start_command" "$CONFIG_FILE")
done

echo -e "${GREEN}✓${NC} Configuration loaded successfully"
echo ""
echo "Benchmark Settings:"
echo "  Duration: $DURATION"
echo "  Threads: $THREADS"
echo "  Connections: $CONNECTIONS"
echo "  Lighthouse Runs: $LIGHTHOUSE_RUNS"
echo ""

# Server PIDs
declare -A SERVER_PIDS

# Function to wait for server to be ready
wait_for_server() {
    local port=$1
    local name=$2
    local attempt=0
    
    echo "⏳ Waiting for $name server on port $port..."
    
    while [ $attempt -lt $HEALTH_CHECK_MAX ]; do
        if curl -s http://localhost:$port/ > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $name server is ready"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep $HEALTH_CHECK_INTERVAL
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
    
    # Wait for graceful shutdown
    sleep $SHUTDOWN_WAIT
    
    # Force kill any remaining processes
    for port in "${FRAMEWORKS[@]}"; do
        lsof -ti:$port | xargs kill -9 2>/dev/null || true
    done
}

trap cleanup EXIT

echo ""
echo "💻 Collecting system information..."
mkdir -p "$LOG_DIR"

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
} > "$LOG_DIR/system-info.txt"

cat "$LOG_DIR/system-info.txt"
echo ""

echo "📦 Installing dependencies..."

for name in "${!FRAMEWORKS[@]}"; do
    dir="${FRAMEWORK_DIRS[$name]}"
    install_cmd="${INSTALL_COMMANDS[$name]}"
    build_cmd="${BUILD_COMMANDS[$name]}"
    
    if [ -d "$dir" ]; then
        echo -e "${BLUE}$name:${NC} Installing dependencies"
        cd "$dir"
        
        # Run install command if not null
        if [ "$install_cmd" != "null" ] && [ ! -z "$install_cmd" ]; then
            eval "$install_cmd" > /dev/null 2>&1 || echo -e "${YELLOW}⚠${NC}  Install failed for $name"
        fi
        
        # Run build command if not null
        if [ "$build_cmd" != "null" ] && [ ! -z "$build_cmd" ]; then
            echo -e "${BLUE}$name:${NC} Building project"
            eval "$build_cmd" > /dev/null 2>&1 || echo -e "${YELLOW}⚠${NC}  Build failed for $name"
        fi
        
        cd ..
    else
        echo -e "${YELLOW}⚠${NC}  Directory not found: $dir (skipping $name)"
    fi
done

echo ""
echo "🏗️  Starting servers..."

for name in "${!FRAMEWORKS[@]}"; do
    dir="${FRAMEWORK_DIRS[$name]}"
    start_cmd="${START_COMMANDS[$name]}"
    port="${FRAMEWORKS[$name]}"
    
    if [ -d "$dir" ]; then
        echo -e "${BLUE}$name:${NC} Starting on port $port"
        cd "$dir"
        eval "$start_cmd" > "../$LOG_DIR/${name}.log" 2>&1 &
        SERVER_PIDS["$name"]=$!
        cd ..
    fi
done

echo ""
echo "⏳ Waiting for all servers to be ready..."
sleep $STARTUP_WAIT

# Wait for each server
for name in "${!FRAMEWORKS[@]}"; do
    port=${FRAMEWORKS[$name]}
    if [ ! -z "${SERVER_PIDS[$name]}" ]; then
        wait_for_server $port $name || echo "Warning: $name server may not be ready"
    fi
done

echo ""
echo "📊 Running wrk benchmarks..."
mkdir -p "$LOG_DIR"

# Run wrk for each framework
for name in "${!FRAMEWORKS[@]}"; do
    port=${FRAMEWORKS[$name]}
    if [ ! -z "${SERVER_PIDS[$name]}" ]; then
        echo -e "${BLUE}$name:${NC} Running benchmark..."
        wrk -t$THREADS -c$CONNECTIONS -d$DURATION http://localhost:$port/ > "$LOG_DIR/${name}_wrk.log" 2>&1
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

mkdir -p "$LIGHTHOUSE_DIR"

# Run Lighthouse for each framework
for name in "${!FRAMEWORKS[@]}"; do
    port=${FRAMEWORKS[$name]}
    if [ ! -z "${SERVER_PIDS[$name]}" ]; then
        echo -e "${BLUE}$name:${NC} Running Lighthouse..."
        lhci autorun \
            --collect.url="http://localhost:$port/" \
            --collect.numberOfRuns=$LIGHTHOUSE_RUNS \
            --upload.target=filesystem \
            --upload.outputDir="$LIGHTHOUSE_DIR/$name" \
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
