# Jackal Usage Guide

Jackal is an Elixir port of [Anubis](https://github.com/TecharoHQ/anubis) that protects your Phoenix/Plug applications from AI crawlers and unwanted bots using proof-of-work challenges.

## Installation

Add `jackal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jackal, "~> 0.1.0"}
  ]
end
```

## Basic Usage

### In a Phoenix Application

Add the plug to your endpoint or router:

```elixir
# In your endpoint.ex
plug Jackal

# Or in your router.ex
pipeline :protected do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_live_flash
  plug :put_root_layout, {MyAppWeb.Layouts, :root}
  plug :protect_from_forgery
  plug :put_secure_browser_headers
  plug Jackal  # Add this line
end
```

### In a Plug Application

```elixir
defmodule MyApp.Router do
  use Plug.Router

  plug :match
  plug Jackal  # Add this line
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello World!")
  end
end
```

## Configuration

Configure Jackal in your `config/config.exs`:

```elixir
import Config

config :jackal,
    # Configure bot policies
    :policies, {Jackal.DefaultPolicies, :all}
    # Configure challenge difficulty (number of leading zeros required)
    :challenge_difficulty, 4
    # Configure JWT token settings
    :token_secret, "your-secret-key-change-this-in-production"
    :token_ttl, 24 * 60 * 60  # 24 hours
```

## Custom Bot Policies

You can define custom bot policies:

```elixir
defmodule MyApp.CustomPolicies do
  alias Jackal.Policy

  def my_policies do
    %{
      good: Policy.create(
        "search_engines",
        ["googlebot", "bingbot", "duckduckbot"],
        :allow
      ),
      bad: Policy.create(
        "scrapers",
        ["scrapy", "curl", "wget", "python-requests"],
        :block
      )
    }
  end
end

# In config.exs
config :jackal, :policies, {MyApp.CustomPolicies, :my_policies}
```

## How It Works

1. **Request Analysis**: When a request comes in, Jackal checks if the client has a valid authentication token
2. **Policy Matching**: If no valid token exists, it analyzes the User-Agent against configured policies
3. **Action Execution**:
   - **Good bots** (search engines): Allowed through immediately
   - **Bad bots** (scrapers/crawlers): Blocked with 403 status
   - **Unknown clients**: Challenged with proof-of-work
4. **Challenge Resolution**: Unknown clients must solve a computational puzzle
5. **Token Issuance**: Successful challenge completion results in a JWT token for future requests

## API Endpoints

### Challenge Verification

Clients can POST to `/anubis/verify` with:

```json
{
  "nonce": "challenge_nonce_from_initial_response",
  "solution": "computed_proof_of_work_solution"
}
```

Success response:
```json
{
  "status": "verified",
  "token": "jwt_token_for_future_requests"
}
```

## Response Formats

### Challenge Response (403)
```json
{
  "status": "challenge",
  "nonce": "abc123...",
  "target": "0000"
}
```

### Blocked Response (403)
```json
{
  "status": "denied"
}
```

## Production Considerations

1. **Secret Key**: Always use a strong, unique secret key in production
2. **Difficulty**: Adjust challenge difficulty based on your security needs vs. user experience
3. **Token TTL**: Configure appropriate token expiration times
4. **HTTPS**: Use secure cookies in production with HTTPS
5. **Monitoring**: Monitor challenge completion rates and adjust policies as needed

## Testing

Jackal includes tests. Run them with:

```bash
mix test
```

