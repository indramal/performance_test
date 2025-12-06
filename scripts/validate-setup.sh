#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔍 Validating Performance Testing Setup"
echo "========================================"
echo ""

# Check 1: Configuration files exist
echo -e "${BLUE}[1/7]${NC} Checking configuration files..."
if [ -f "config/benchmark-config.json" ]; then
    echo -e "  ${GREEN}✓${NC} config/benchmark-config.json exists"
else
    echo -e "  ${RED}✗${NC} config/benchmark-config.json not found"
    exit 1
fi

if [ -f "config/benchmark-config.dev.json" ]; then
    echo -e "  ${GREEN}✓${NC} config/benchmark-config.dev.json exists"
else
    echo -e "  ${YELLOW}⚠${NC} config/benchmark-config.dev.json not found (optional)"
fi

# Check 2: Validate JSON syntax
echo -e "${BLUE}[2/7]${NC} Validating JSON syntax..."
if command -v jq &> /dev/null; then
    if jq empty config/benchmark-config.json 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} benchmark-config.json is valid JSON"
    else
        echo -e "  ${RED}✗${NC} benchmark-config.json has syntax errors"
        exit 1
    fi
else
    echo -e "  ${YELLOW}⚠${NC} jq not installed, skipping JSON validation"
fi

# Check 3: Required tools
echo -e "${BLUE}[3/7]${NC} Checking required tools..."
MISSING_TOOLS=0

if command -v jq &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} jq installed ($(jq --version))"
else
    echo -e "  ${RED}✗${NC} jq not installed (required)"
    MISSING_TOOLS=1
fi

if command -v wrk &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} wrk installed"
else
    echo -e "  ${YELLOW}⚠${NC} wrk not installed (required for benchmarking)"
fi

if command -v lhci &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Lighthouse CI installed"
else
    echo -e "  ${YELLOW}⚠${NC} Lighthouse CI not installed (will be installed by script)"
fi

# Check 4: Scripts are executable
echo -e "${BLUE}[4/7]${NC} Checking script permissions..."
if [ -x "scripts/run-benchmarks.sh" ]; then
    echo -e "  ${GREEN}✓${NC} run-benchmarks.sh is executable"
else
    echo -e "  ${YELLOW}⚠${NC} run-benchmarks.sh is not executable, fixing..."
    chmod +x scripts/run-benchmarks.sh
    echo -e "  ${GREEN}✓${NC} Fixed permissions"
fi

# Check 5: Framework directories
echo -e "${BLUE}[5/7]${NC} Checking framework directories..."
FRAMEWORKS=("tuono-test" "bun-test" "nextjs-test" "deno-test")
for fw in "${FRAMEWORKS[@]}"; do
    if [ -d "$fw" ]; then
        echo -e "  ${GREEN}✓${NC} $fw exists"
    else
        echo -e "  ${YELLOW}⚠${NC} $fw not found (you may need to create it)"
    fi
done

# Check 6: GitHub Actions workflow
echo -e "${BLUE}[6/7]${NC} Checking GitHub Actions workflow..."
if [ -f ".github/workflows/performance-benchmark.yml" ]; then
    echo -e "  ${GREEN}✓${NC} GitHub Actions workflow exists"
    
    # Check if it's set to workflow_dispatch
    if grep -q "workflow_dispatch:" ".github/workflows/performance-benchmark.yml"; then
        echo -e "  ${GREEN}✓${NC} Manual trigger (workflow_dispatch) configured"
    else
        echo -e "  ${YELLOW}⚠${NC} Manual trigger may not be configured"
    fi
else
    echo -e "  ${RED}✗${NC} GitHub Actions workflow not found"
fi

# Check 7: Reports directory
echo -e "${BLUE}[7/7]${NC} Checking reports directory structure..."
mkdir -p reports/latest reports/history logs
echo -e "  ${GREEN}✓${NC} Created reports/latest, reports/history, and logs directories"

echo ""
echo "========================================"
if [ $MISSING_TOOLS -eq 0 ]; then
    echo -e "${GREEN}✅ Validation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Install missing tools if any (wrk, Lighthouse CI)"
    echo "  2. Test configuration reading:"
    echo -e "     ${BLUE}jq -r '.benchmark.duration' config/benchmark-config.json${NC}"
    echo "  3. Test the benchmark script locally (if all frameworks are ready)"
    echo "  4. Push to GitHub and test the workflow manually"
else
    echo -e "${YELLOW}⚠ Validation complete with warnings${NC}"
    echo ""
    echo "Please install jq to continue:"
    echo -e "  ${BLUE}sudo apt-get install jq${NC}"
fi
