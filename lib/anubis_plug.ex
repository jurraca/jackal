
defmodule AnubisPlug do
  import Plug.Conn
  
  # Policies will be loaded at runtime instead of compile time
    apply(module, function, [])
  )
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    case verify_bot(conn) do
      :allow -> conn
      :block -> deny_access(conn)
      :challenge -> issue_challenge(conn)
    end
  end
  
  defp verify_bot(conn) do
    user_agent = get_req_header(conn, "user-agent") |> List.first() || ""
    
    cond do
      matches_policy?(user_agent, :good) -> :allow
      matches_policy?(user_agent, :bad) -> :block
      true -> :challenge
    end
  end
  
  defp issue_challenge(conn) do
    {nonce, target} = AnubisPlug.Challenge.generate()
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, Jason.encode!(%{
      status: "challenge",
      nonce: nonce,
      target: target
    }))
    |> halt()
  end
  
  defp deny_access(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, Jason.encode!(%{status: "denied"}))
    |> halt()
  end
  
  defp matches_policy?(user_agent, type) do
    policies = get_policies()
    policy = Map.get(policies, type)
    AnubisPlug.Policy.match?(policy, user_agent)
  end

  defp get_policies do
    case Application.get_env(:anubis_plug, :policies) do
      {module, function} -> apply(module, function, [])
      _ -> AnubisPlug.DefaultPolicies.get_policies()
    end
  end
end
