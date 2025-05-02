defmodule AnubisPlugTest do
  use ExUnit.Case
  doctest AnubisPlug

  test "greets the world" do
    assert AnubisPlug.hello() == :world
  end
end
