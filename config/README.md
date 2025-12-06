# Benchmark Configuration

This directory contains configuration files for the performance benchmark system.

## Files

### `benchmark-config.json`

The main configuration file for all benchmark parameters and framework settings.

## Configuration Structure

### `benchmark`

Controls the main benchmark parameters for wrk (HTTP load testing tool).

- **duration** (string): How long to run each benchmark test (e.g., "30s", "1m")
- **threads** (number): Number of threads to use for wrk
- **connections** (number): Number of concurrent connections to maintain
- **results_dir** (string): Directory where final reports will be saved

Example:
```json
"benchmark": {
  "duration": "30s",
  "threads": 12,
  "connections": 400,
  "results_dir": "reports/latest"
}
```

### `frameworks`

Defines each framework to be benchmarked. Each framework is a key with the following properties:

- **port** (number): Port number the server will run on
- **directory** (string): Path to the framework's project directory
- **install_command** (string|null): Command to install dependencies (null to skip)
- **build_command** (string|null): Command to build the project (null to skip)
- **start_command** (string): Command to start the server
- **health_check_path** (string): Path to use for health check (usually "/")

Example:
```json
"frameworks": {
  "tuono": {
    "port": 3000,
    "directory": "tuono-test",
    "install_command": "npm install",
    "build_command": null,
    "start_command": "cargo run --release",
    "health_check_path": "/"
  }
}
```

### `lighthouse`

Configuration for Lighthouse CI performance audits.

- **number_of_runs** (number): How many times to run Lighthouse for each framework (results are averaged)
- **output_dir** (string): Directory to store Lighthouse results
- **collect_settings** (object): Additional Lighthouse collection settings
  - **preset** (string): "desktop" or "mobile"
  - **throttling** (object): Network and CPU throttling settings

Example:
```json
"lighthouse": {
  "number_of_runs": 3,
  "output_dir": ".lighthouseci",
  "collect_settings": {
    "preset": "desktop",
    "throttling": {
      "rttMs": 40,
      "throughputKbps": 10240,
      "cpuSlowdownMultiplier": 1
    }
  }
}
```

### `server`

Controls server startup and health check behavior.

- **startup_wait_seconds** (number): Initial wait time after starting all servers before health checks
- **health_check_max_attempts** (number): Maximum number of attempts to check if server is ready
- **health_check_interval_seconds** (number): Seconds to wait between health check attempts
- **graceful_shutdown_wait_seconds** (number): Seconds to wait for graceful shutdown before force kill

Example:
```json
"server": {
  "startup_wait_seconds": 5,
  "health_check_max_attempts": 30,
  "health_check_interval_seconds": 1,
  "graceful_shutdown_wait_seconds": 2
}
```

### `system_info`

Controls system information collection.

- **enabled** (boolean): Whether to collect system information
- **output_file** (string): Where to save system information

Example:
```json
"system_info": {
  "enabled": true,
  "output_file": "logs/system-info.txt"
}
```

### `logging`

Controls logging behavior.

- **directory** (string): Directory to store all log files
- **server_logs** (boolean): Whether to save server output logs
- **benchmark_logs** (boolean): Whether to save benchmark result logs

Example:
```json
"logging": {
  "directory": "logs",
  "server_logs": true,
  "benchmark_logs": true
}
```

## Adding a New Framework

To add a new framework to the benchmarks:

1. Create the framework project directory
2. Add a new entry under `frameworks` in `benchmark-config.json`:

```json
"myframework": {
  "port": 3004,
  "directory": "myframework-test",
  "install_command": "npm install",
  "build_command": "npm run build",
  "start_command": "npm start",
  "health_check_path": "/"
}
```

3. The benchmark script will automatically detect and test the new framework

## Tuning Performance Tests

### For faster testing (development):
```json
{
  "benchmark": {
    "duration": "10s",
    "threads": 4,
    "connections": 100
  },
  "lighthouse": {
    "number_of_runs": 1
  }
}
```

### For comprehensive testing (CI/production):
```json
{
  "benchmark": {
    "duration": "60s",
    "threads": 12,
    "connections": 1000
  },
  "lighthouse": {
    "number_of_runs": 5
  }
}
```

## Requirements

The benchmark script requires the following tools to be installed:

- **jq**: JSON processor for parsing config file
  ```bash
  sudo apt-get install jq  # Ubuntu/Debian
  brew install jq          # macOS
  ```

- **wrk**: HTTP benchmarking tool
  ```bash
  sudo apt-get install wrk  # Ubuntu/Debian
  brew install wrk          # macOS
  ```

- **Lighthouse CI**: Installed automatically by the script
  ```bash
  npm install -g @lhci/cli
  ```

## Validation

To validate your configuration file:

```bash
jq empty config/benchmark-config.json && echo "Valid JSON" || echo "Invalid JSON"
```

To test configuration loading:

```bash
jq -r '.benchmark.duration' config/benchmark-config.json
```
