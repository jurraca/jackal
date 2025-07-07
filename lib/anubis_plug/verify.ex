defmodule AnubisPlug.Verify do
  @moduledoc """
  Handles challenge verification and token issuance
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.method == "POST" and String.ends_with?(conn.request_path, "/anubis/verify") do
      handle_verification(conn)
    else
      conn
    end
  end

  defp handle_verification(conn) do
    case get_verification_params(conn) do
      {:ok, %{"nonce" => nonce, "solution" => solution}} ->
        verify_solution(conn, nonce, solution)

      {:error, _reason} ->
        send_error(conn, "Invalid request parameters")
    end
  end

  defp get_verification_params(conn) do
    case conn.body_params do
      %{} = params when map_size(params) > 0 ->
        {:ok, params}

      _ ->
        # Try to read and parse body if not already parsed
        case Plug.Conn.read_body(conn) do
          {:ok, body, _conn} ->
            Jason.decode(body)

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp verify_solution(conn, nonce, solution) do
    if AnubisPlug.Challenge.verify(nonce, solution) do
      token =
        AnubisPlug.Auth.generate_token(%{
          user_agent: get_user_agent(conn),
          verified_at: System.system_time(:second)
        })

      conn
      |> AnubisPlug.Auth.set_auth_cookie(token)
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{status: "verified", token: token}))
      |> halt()
    else
      send_error(conn, "Invalid proof-of-work solution")
    end
  end

  defp send_error(conn, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{status: "error", message: message}))
    |> halt()
  end

  defp get_user_agent(conn) do
    get_req_header(conn, "user-agent") |> List.first() || ""
  end
end
