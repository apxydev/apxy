# Install Scripts

## Purpose

Installation scripts in `scripts/` that handle downloading, installing, uninstalling, and checking the status of APXY across supported platforms.

## Requirements

### Requirement: Platform detection
The install script MUST detect the current platform (macOS/Linux) and architecture (amd64/arm64) to download the correct binary.

#### Scenario: macOS ARM detection
- **GIVEN** the script runs on macOS with Apple Silicon
- **WHEN** platform detection executes
- **THEN** it MUST identify the platform as `darwin` and architecture as `arm64`

#### Scenario: Linux x86_64 detection
- **GIVEN** the script runs on Linux with x86_64 CPU
- **WHEN** platform detection executes
- **THEN** it MUST identify the platform as `linux` and architecture as `amd64`

#### Scenario: Unsupported platform
- **GIVEN** the script runs on an unsupported platform (e.g., Windows)
- **WHEN** platform detection executes
- **THEN** it MUST exit with a clear error message listing supported platforms

### Requirement: Install command
The install script MUST download the latest APXY release binary and place it in a directory on the user's PATH.

#### Scenario: Fresh install
- **GIVEN** APXY is not installed
- **WHEN** the user runs the install command
- **THEN** it MUST download the correct binary, make it executable, and place it in a PATH directory (e.g., `/usr/local/bin`)

#### Scenario: Install with existing version
- **GIVEN** APXY is already installed
- **WHEN** the user runs the install command
- **THEN** it MUST replace the existing binary with the latest version

### Requirement: Uninstall command
The install script MUST support an uninstall flag that removes the APXY binary.

#### Scenario: Uninstall removes binary
- **GIVEN** APXY is installed at a known path
- **WHEN** the user runs the script with the uninstall flag
- **THEN** it MUST remove the binary and confirm removal

### Requirement: Status command
The install script MUST support a status flag that checks whether APXY is installed and reports the version.

#### Scenario: Status when installed
- **GIVEN** APXY is installed
- **WHEN** the user runs the script with the status flag
- **THEN** it MUST print the installed version and binary path

#### Scenario: Status when not installed
- **GIVEN** APXY is not installed
- **WHEN** the user runs the script with the status flag
- **THEN** it MUST print a message indicating APXY is not found

### Requirement: Script syntax validity
The install script MUST pass bash syntax checking (`bash -n scripts/install.sh`).

#### Scenario: Script has valid syntax
- **GIVEN** the install script exists
- **WHEN** `bash -n scripts/install.sh` is run
- **THEN** it MUST exit with code 0 (no syntax errors)
