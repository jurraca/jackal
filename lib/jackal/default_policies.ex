defmodule Jackal.DefaultPolicies do
  alias Jackal.Policy

  def good_bots do
    Policy.create(
      "good_bots",
      [
        "googlebot",
        "bingbot"
      ],
      :allow
    )
  end

  def bad_bots do
    Policy.create(
      "bad_bots",
      [
        "semrush",
        "ahrefs",
        "openai",
        "badbot"
      ],
      :block
    )
  end

  def all do
    %{
      good: good_bots(),
      bad: bad_bots()
    }
  end
end
