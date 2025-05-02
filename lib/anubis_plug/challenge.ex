
defmodule AnubisPlug.Challenge do
  @moduledoc """
  Implements proof of work challenge generation and verification
  """
  
  @difficulty 4  # Number of leading zeros required
  
  def generate do
    nonce = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
    {nonce, calculate_target(@difficulty)}
  end
  
  def verify(nonce, solution) do
    hash = :crypto.hash(:sha256, nonce <> solution) |> Base.encode16(case: :lower)
    String.starts_with?(hash, String.duplicate("0", @difficulty))
  end
  
  defp calculate_target(difficulty) do
    String.duplicate("0", difficulty)
  end
end
