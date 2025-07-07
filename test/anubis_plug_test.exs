defmodule AnubisPlugTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  describe "AnubisPlug" do
    test "allows good bots" do
      conn =
        :get
        |> conn("/")
        |> put_req_header("user-agent", "Googlebot")
        |> AnubisPlug.call([])

      refute conn.halted
    end

    test "blocks bad bots" do
      conn =
        :get
        |> conn("/")
        |> put_req_header("user-agent", "BadBot")
        |> AnubisPlug.call([])

      assert conn.halted
      assert conn.status == 403
      {:ok, response} = Jason.decode(conn.resp_body)
      assert response["status"] == "denied"
    end

    test "challenges unknown user agents" do
      conn =
        :get
        |> conn("/")
        |> put_req_header("user-agent", "UnknownBot")
        |> AnubisPlug.call([])

      assert conn.halted
      assert conn.status == 403
      {:ok, response} = Jason.decode(conn.resp_body)
      assert response["status"] == "challenge"
      assert Map.has_key?(response, "nonce")
      assert Map.has_key?(response, "target")
    end

    test "challenges requests with no user agent" do
      conn =
        :get
        |> conn("/")
        |> AnubisPlug.call([])

      assert conn.halted
      assert conn.status == 403
      {:ok, response} = Jason.decode(conn.resp_body)
      assert response["status"] == "challenge"
    end

    test "init returns options unchanged" do
      opts = [some: :option]
      assert AnubisPlug.init(opts) == opts
    end
  end
end
