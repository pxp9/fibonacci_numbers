defmodule FibRustElixir do
  @moduledoc """
  Implements Fibo in Elixir
  """
  import Bitwise
  require ExUnit.Assertions

  @phi 1.618033988749895

  def slow_fib(0), do: 0
  def slow_fib(1), do: 1

  def slow_fib(n) do
    slow_fib(n) + slow_fib(n - 1)
  end

  def slow_golden_ratio(n) do
    b = slow_fib(n)
    a = slow_fib(n - 1)

    b / a
  end

  def fast_inverse_square_root(number) do
    x2 = number * 0.5
    <<i::integer-size(64)>> = <<number::float-size(64)>>
    <<y::float-size(64)>> = <<0x5FE6EB50C7B537A9 - (i >>> 1)::integer-size(64)>>
    y = y * (1.5 - x2 * y * y)
    y = y * (1.5 - x2 * y * y)
    y = y * (1.5 - x2 * y * y)
    y
  end

  def phi_formula(n),
    do: round((:math.pow(@phi, n) - :math.pow(-@phi, -n)) * fast_inverse_square_root(5.0))

  def fib(0), do: 0
  def fib(1), do: 1

  def fib(n), do: fib(n, 0, 1)

  defp fib(1, _a, b), do: b

  defp fib(n, a, b), do: fib(n - 1, b, a + b)

  def golden_ratio(n), do: golden_ratio(n, 0, 1)

  defp golden_ratio(1, a, b), do: b / a

  defp golden_ratio(n, a, b), do: golden_ratio(n - 1, b, a + b)

  def bench_large_shit() do
    Benchee.run(
      %{
        "Elixir O(N) Algorithm" => &fib/1,
        "Rust O(N) Algorithm expanding nums" => &TurboFibonacci.fib_bignums/1
      },
      inputs: %{
        "200_000" => 200_000,
        "1 Million" => 1_000_000
      },
      parallel: 2
    )
  end

  def bench() do
    Benchee.run(
      %{
        "Elixir O(N) Algorithm" => &fib/1,
        "Elixir O(1) Algorithm Phi formula" => &phi_formula/1,
        "Rust O(1) Algorithm Phi formula" => &TurboFibonacci.phi_formula/1,
        "Rust O(N) Algorithm" => &TurboFibonacci.fib/1,
        "Rust O(N) Algorithm expanding nums" => &TurboFibonacci.fib_bignums/1
      },
      inputs: %{
        "1" => 1,
        "75" => 75,
        "100" => 100
      },
      after_each: fn result -> result in [1, 2111485077978050, 354224848179261915075] end,
      parallel: 2
    )
  end
end
