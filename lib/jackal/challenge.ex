defmodule Jackal.Challenge do
  @moduledoc """
  Implements proof of work challenge generation and verification with enhanced
  fingerprinting based on the original Anubis design
  """

  def generate(conn \\ nil) do
    difficulty = Application.get_env(:jackal, :challenge_difficulty, 4)

    if conn do
      # Generate challenge string based on request metadata (original Anubis style)
      challenge_string = generate_challenge_string(conn)
      nonce = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
      {nonce, calculate_target(difficulty), challenge_string}
    else
      # Fallback to simple generation for backwards compatibility
      nonce = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
      {nonce, calculate_target(difficulty)}
    end
  end

  def verify(nonce, solution, challenge_string \\ nil) do
    difficulty = Application.get_env(:jackal, :challenge_difficulty, 4)

    input =
      if challenge_string do
        challenge_string <> nonce <> solution
      else
        nonce <> solution
      end

    hash = :crypto.hash(:sha256, input) |> Base.encode16(case: :lower)
    String.starts_with?(hash, String.duplicate("0", difficulty))
  end

  defp generate_challenge_string(conn) do
    # Extract request metadata as per original Anubis design
    accept_encoding = get_header_value(conn, "accept-encoding")
    x_real_ip = get_header_value(conn, "x-real-ip") || get_header_value(conn, "x-forwarded-for")
    user_agent = get_header_value(conn, "user-agent")

    # Current time rounded to nearest week (original Anubis behavior)
    week_timestamp = get_week_timestamp()

    # Server fingerprint (simplified - using app name instead of ED25519 key)
    server_fingerprint = get_server_fingerprint()

    # Combine all metadata
    metadata = [
      accept_encoding || "",
      x_real_ip || "",
      user_agent || "",
      Integer.to_string(week_timestamp),
      server_fingerprint
    ]

    # Create SHA-256 checksum of combined metadata
    metadata
    |> Enum.join("|")
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end

  defp get_header_value(conn, header_name) do
    case Plug.Conn.get_req_header(conn, header_name) do
      [value | _] -> value
      [] -> nil
    end
  end

  defp get_week_timestamp do
    # Get current Unix timestamp and round to nearest week
    now = System.system_time(:second)
    week_in_seconds = 7 * 24 * 60 * 60
    div(now, week_in_seconds) * week_in_seconds
  end

  defp get_server_fingerprint do
    # Simplified server fingerprint - in production this could be based on
    # a persistent ED25519 key as in original Anubis
    app_name = Application.get_env(:jackal, :app_name, "jackal")
    :crypto.hash(:sha256, app_name) |> Base.encode16(case: :lower) |> String.slice(0, 16)
  end

  defp calculate_target(difficulty) do
    String.duplicate("0", difficulty)
  end
end
