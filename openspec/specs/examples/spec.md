# Examples

## Purpose

Self-contained usage examples in the `examples/` directory demonstrating common APXY workflows: basic debugging, API mocking, and AI agent integration.

## Requirements

### Requirement: Basic debugging example
The `examples/` directory MUST contain a basic-debugging example that demonstrates capturing and inspecting HTTP traffic.

#### Scenario: User runs basic-debugging example
- **GIVEN** APXY is installed and running
- **WHEN** a user follows the basic-debugging example
- **THEN** they MUST be able to capture requests, inspect headers/body, and filter by host/path

#### Scenario: Example is self-contained
- **GIVEN** the basic-debugging example exists
- **WHEN** a user reads it
- **THEN** it MUST include all commands needed to run end-to-end without external dependencies beyond APXY

### Requirement: API mocking example
The `examples/` directory MUST contain an api-mocking example that demonstrates creating mock rules and verifying mock responses.

#### Scenario: User runs api-mocking example
- **GIVEN** APXY is installed and running
- **WHEN** a user follows the api-mocking example
- **THEN** they MUST be able to create a mock rule, send a request, and verify the mocked response is returned

#### Scenario: Example covers pattern matching
- **GIVEN** the api-mocking example exists
- **WHEN** a user reads it
- **THEN** it MUST demonstrate at least exact match and wildcard pattern matching

### Requirement: AI agent workflow example
The `examples/` directory MUST contain an ai-agent-workflow example that demonstrates using APXY with an AI coding agent via MCP.

#### Scenario: User runs ai-agent-workflow example
- **GIVEN** APXY is installed and an MCP-compatible agent is available
- **WHEN** a user follows the ai-agent-workflow example
- **THEN** they MUST be able to configure MCP, have the agent capture traffic, and inspect results

#### Scenario: Example shows token optimization
- **GIVEN** the ai-agent-workflow example exists
- **WHEN** a user reads it
- **THEN** it MUST demonstrate using output optimization (trim/markdown/TOON) to reduce token usage
