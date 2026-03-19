# Public Documentation

## Purpose

User-facing documentation in the `docs/` directory. Covers getting started, user guides, troubleshooting, and FAQ for APXY users.

## Requirements

### Requirement: Getting Started guide
The `docs/` directory MUST contain a getting-started guide that walks new users through installation, first proxy session, and basic traffic inspection.

#### Scenario: New user follows getting-started
- **GIVEN** a user has never used APXY
- **WHEN** they follow the getting-started guide
- **THEN** they MUST be able to install APXY, start the proxy, and capture their first request

#### Scenario: Getting-started covers prerequisites
- **GIVEN** the getting-started guide exists
- **WHEN** a user reads the prerequisites section
- **THEN** it MUST list supported platforms (macOS, Linux), required tools, and minimum versions

### Requirement: User guide
The `docs/` directory MUST contain a user guide covering core features: traffic capture, inspection, mocking, interceptors, export/replay, and MCP integration.

#### Scenario: User guide covers traffic capture
- **GIVEN** the user guide exists
- **WHEN** a user reads the traffic capture section
- **THEN** it MUST explain how to start/stop capture, filter traffic, and manage sessions

#### Scenario: User guide covers MCP integration
- **GIVEN** the user guide exists
- **WHEN** a user reads the MCP integration section
- **THEN** it MUST explain how to connect APXY to AI coding agents (Claude Code, Cursor) via MCP

### Requirement: Troubleshooting guide
The `docs/` directory MUST contain a troubleshooting guide with common issues and solutions.

#### Scenario: Troubleshooting covers SSL errors
- **GIVEN** the troubleshooting guide exists
- **WHEN** a user encounters SSL certificate errors
- **THEN** the guide MUST provide steps to install and trust the APXY CA certificate

#### Scenario: Troubleshooting covers proxy connection issues
- **GIVEN** the troubleshooting guide exists
- **WHEN** a user cannot connect through the proxy
- **THEN** the guide MUST provide diagnostic steps (port conflicts, firewall, env variables)

### Requirement: FAQ
The `docs/` directory MUST contain a FAQ addressing common questions about APXY capabilities, limitations, and usage patterns.

#### Scenario: FAQ answers basic questions
- **GIVEN** the FAQ exists
- **WHEN** a user reads it
- **THEN** it MUST cover at minimum: what APXY is, how it differs from Proxyman/Charles, supported platforms, and pricing
