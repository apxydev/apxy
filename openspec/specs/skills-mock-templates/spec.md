# Skills & Mock Templates

## Purpose

Skill definitions (`skills/SKILL.md`) that describe APXY's capabilities for AI agents, and pre-built mock template sets (`mock-templates/`) that provide ready-to-use API mock rules for common services.

## Requirements

### Requirement: Skill definition format
The `skills/SKILL.md` file MUST define APXY's capabilities in a format consumable by AI agents. It MUST include a description, available tools/commands, and usage examples.

#### Scenario: AI agent reads skill definition
- **GIVEN** an AI agent loads `skills/SKILL.md`
- **WHEN** it parses the skill definition
- **THEN** it MUST find a clear description of APXY's purpose, a list of available MCP tools, and example usage patterns

#### Scenario: Skill definition covers core capabilities
- **GIVEN** the skill definition exists
- **WHEN** an AI agent reads it
- **THEN** it MUST describe at minimum: traffic capture, inspection, mocking, and export capabilities

### Requirement: Mock template structure
Each mock template in `mock-templates/` MUST be a self-contained directory with a README and one or more mock rule files.

#### Scenario: Template directory structure
- **GIVEN** a mock template directory exists (e.g., `mock-templates/stripe-api/`)
- **WHEN** a user inspects it
- **THEN** it MUST contain a README.md describing the template and at least one mock rule file

#### Scenario: Template README describes usage
- **GIVEN** a mock template README exists
- **WHEN** a user reads it
- **THEN** it MUST explain what APIs are mocked, how to load the rules into APXY, and any customization options

### Requirement: Mock templates cover common services
The `mock-templates/` directory SHALL include templates for commonly mocked API services.

#### Scenario: Templates exist for common APIs
- **GIVEN** the mock-templates directory exists
- **WHEN** a user lists available templates
- **THEN** there SHOULD be templates for at least 2 common API patterns (e.g., REST CRUD, OAuth token endpoint)

### Requirement: Mock rule file format
Mock rule files MUST use a format compatible with APXY's `apxy mock import` command.

#### Scenario: Import mock rules from template
- **GIVEN** a mock template with rule files exists
- **WHEN** a user runs `apxy mock import <rule-file>`
- **THEN** the mock rules MUST be loaded and active in APXY
