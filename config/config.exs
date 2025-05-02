
import Config

config :anubis_plug, :policies, %{
  good: AnubisPlug.Policy.create("good_bots", [
    "googlebot",
    "bingbot"
  ], :allow),
  
  bad: AnubisPlug.Policy.create("bad_bots", [
    "semrush",
    "ahrefs",
    "openai"
  ], :block)
}
