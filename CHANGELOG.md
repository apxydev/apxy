# Changelog

## [1.0.0] - 2026-03-01

### Initial Release
- Domain layer with `NetworkRecord`, `MockRule` structs
- Certificate management (CA generation, leaf certificates, trust)
- HTTP/HTTPS MITM proxy with concurrent request handling
- SQLite storage with WAL mode
- Mock rule engine (exact, wildcard, regex matching)
- Token optimization (trim, markdown, toon formats)
- CLI with 30+ commands via Cobra
- System proxy management on macOS
