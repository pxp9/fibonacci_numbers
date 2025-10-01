defmodule FibRustElixirTest do
  use ExUnit.Case
  doctest FibRustElixir

  test "greets the world" do
    assert FibRustElixir.hello() == :world
  end
end
