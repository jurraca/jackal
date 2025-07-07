defmodule AnubisPlug.Auth do
  @moduledoc """
  Handles JWT token creation and verification for clients who have 
  successfully completed proof-of-work challenges
  """

  @token_secret Application.compile_env(:anubis_plug, :token_secret, "default_secret_change_me")
  # 24 hours
  @token_ttl Application.compile_env(:anubis_plug, :token_ttl, 24 * 60 * 60)

  def generate_token(client_info \\ %{}) do
    now = System.system_time(:second)

    payload = %{
      "iat" => now,
      "exp" => now + @token_ttl,
      "verified" => true,
      "client" => client_info
    }

    encode_jwt(payload)
  end

  def verify_token(token) when is_binary(token) do
    case decode_jwt(token) do
      {:ok, payload} ->
        now = System.system_time(:second)

        cond do
          not Map.get(payload, "verified", false) ->
            {:error, :not_verified}

          Map.get(payload, "exp", 0) < now ->
            {:error, :expired}

          true ->
            {:ok, payload}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def verify_token(_), do: {:error, :invalid_token}

  def set_auth_cookie(conn, token) do
    cookie_opts = [
      max_age: @token_ttl,
      http_only: true,
      # Set to true in production with HTTPS
      secure: false,
      same_site: "Lax"
    ]

    Plug.Conn.put_resp_cookie(conn, "anubis_auth", token, cookie_opts)
  end

  def get_auth_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        token

      _ ->
        conn.req_cookies["anubis_auth"]
    end
  end

  # Simple JWT implementation using HMAC-SHA256
  defp encode_jwt(payload) do
    header = %{"alg" => "HS256", "typ" => "JWT"}

    encoded_header = header |> Jason.encode!() |> Base.url_encode64(padding: false)
    encoded_payload = payload |> Jason.encode!() |> Base.url_encode64(padding: false)

    message = encoded_header <> "." <> encoded_payload

    signature =
      :crypto.mac(:hmac, :sha256, @token_secret, message)
      |> Base.url_encode64(padding: false)

    message <> "." <> signature
  end

  defp decode_jwt(token) do
    case String.split(token, ".") do
      [header, payload, signature] ->
        message = header <> "." <> payload

        expected_signature =
          :crypto.mac(:hmac, :sha256, @token_secret, message)
          |> Base.url_encode64(padding: false)

        if signature == expected_signature do
          case Base.url_decode64(payload, padding: false) do
            {:ok, decoded_payload} ->
              case Jason.decode(decoded_payload) do
                {:ok, parsed_payload} -> {:ok, parsed_payload}
                {:error, _} -> {:error, :invalid_json}
              end

            :error ->
              {:error, :invalid_encoding}
          end
        else
          {:error, :invalid_signature}
        end

      _ ->
        {:error, :invalid_format}
    end
  end
end
