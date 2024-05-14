defmodule ExPoppy.Native do
  @moduledoc false
  # use Rustler, otp_app: :ex_poppy, crate: "ex_poppy"
  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]

  use RustlerPrecompiled,
    otp_app: :ex_poppy,
    crate: "ex_poppy",
    version: version,
    base_url: "#{github_url}/releases/download/#{version}",
    force_build: System.get_env("EXPOPPY_BUILD") in ["1", "true"],
    version: version

  def new(_capacity, _false_positive_rate), do: err()

  def with_version(_version, _capacity, _false_positive_rate),
    do: err()

  def with_params(_version, _capacity, _false_positive_rate, _opt),
    do: err()

  def insert_str(_bloom_filter_reference, _string), do: err()
  # def insert_bytes(_a, _b), do: err()
  def contains_str(_bloom_filter_reference, _string), do: err()
  # def contains_bytes(_a, _b), do: err()
  def version(_bloom_filter_reference), do: err()
  def capacity(_bloom_filter_reference), do: err()
  def fpp(_bloom_filter_reference), do: err()
  def count_estimate(_bloom_filter_reference), do: err()
  # def data(_bloom_filter_reference), do: err()
  def load_filter(_path), do: err()
  def save(_bloom_filter_reference, _path), do: err()

  defp err(), do: :erlang.nif_error(:nif_not_loaded)
end
