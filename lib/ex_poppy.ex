defmodule ExPoppy do
  use Rustler, otp_app: :ex_poppy, crate: "ex_poppy"

  @moduledoc """
  Documentation for `ExPoppy`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExPoppy.hello()
      :world

  """

  # When your NIF is loaded, it will override this function.
  # @spec add(integer(), integer()) :: integer()
  def new(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def with_version(_a, _b, _c), do: :erlang.nif_error(:nif_not_loaded)
  def with_params(_a, _b, _c, _d), do: :erlang.nif_error(:nif_not_loaded)
  def insert_str(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def insert_bytes(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def contains_str(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def contains_bytes(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def version(_bf), do: :erlang.nif_error(:nif_not_loaded)
  def capacity(_bf), do: :erlang.nif_error(:nif_not_loaded)
  def fpp(_bf), do: :erlang.nif_error(:nif_not_loaded)
  def count_estimate(_bf), do: :erlang.nif_error(:nif_not_loaded)
  def data(_bf), do: :erlang.nif_error(:nif_not_loaded)
  def load_filter(_path), do: :erlang.nif_error(:nif_not_loaded)
  def save(_a, _path), do: :erlang.nif_error(:nif_not_loaded)
end
