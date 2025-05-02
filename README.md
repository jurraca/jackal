# README

A port of Anubis to Elixir.

Core Components of the Go implementation:

Main Service Components:
- Server (lib/anubis.go): The core server implementation handling HTTP requests
- Policy Engine (lib/policy/): Handles bot detection rules and challenge policies
- Challenge System: Implements proof-of-work verification (web/js/proof-of-work.mjs)

Configuration & Rules:
- Bot Policies (data/bots/): YAML definitions for different bot types
- Policy Configuration (lib/policy/config/): Policy parsing and validation
- Environment Configuration (cmd/anubis/main.go): Server settings and flags

Protection Features:
- DNS Blacklist (internal/dnsbl/): Checks IPs against known bad actors
- OpenGraph Tags Cache (internal/ogtags/): Caches metadata for allowed bots
- Decay Map (decaymap/): Time-based cache for temporary data

Frontend Components:
- Challenge UI (web/): HTML templates and JavaScript for the challenge page
- Static Assets (web/static/): Images and other static resources
- CSS Styling (xess/): Custom CSS framework

Key Integrations:
- Reverse Proxy Support: Works behind Nginx/Apache
- Cookie-based Authentication: JWT tokens for verified clients
- Metrics: Prometheus metrics for monitoring

Flow:

Request comes in -> Policy Engine checks rules
If challenge needed -> Serves challenge page
Client solves proof-of-work -> Validates solution
If valid -> Sets cookie and forwards to protected resource
Future requests with valid cookie -> Direct access
Design Patterns:

Configuration as Code (YAML policies)
Middleware Architecture (HTTP handlers)
Cache Management (DecayMap)
Worker System (JavaScript proof-of-work)