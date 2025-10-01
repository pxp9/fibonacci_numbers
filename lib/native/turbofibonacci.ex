defmodule TurboFibonacci do
  use Rustler,
    otp_app: :fib_rust_elixir,
    crate: :turbofibonacci

  # When loading a NIF module, dummy clauses for all NIF function are required.
  # NIF dummies usually just error out when called when the NIF is not loaded, as that should never normally happen.
  def fib(_arg2), do: :erlang.nif_error(:nif_not_loaded)
  def phi_formula(_arg2), do: :erlang.nif_error(:nif_not_loaded)
  def fib_bignums(_arg2), do: :erlang.nif_error(:nif_not_loaded)
  def golden_ratio(_arg2), do: :erlang.nif_error(:nif_not_loaded)

end
