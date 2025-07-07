
defmodule Jackal.Policy do
  @moduledoc """
  Defines policies for bot classification and handling
  """
  
  defstruct [:name, :rules, :action]
  
  def create(name, rules, action) when action in [:allow, :challenge, :block] do
    %__MODULE__{
      name: name,
      rules: rules,
      action: action
    }
  end
  
  def match?(policy, user_agent) do
    Enum.any?(policy.rules, fn rule -> 
      String.match?(String.downcase(user_agent), ~r/#{String.downcase(rule)}/)
    end)
  end
end
