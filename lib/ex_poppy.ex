defmodule ExPoppy do
  use Rustler, otp_app: :ex_poppy, crate: "ex_poppy"

  @moduledoc """
  Documentation for `ExPoppy`.

  ExPoppy is a NIF wrapping the poppy RUST library https://github.com/hashlookup/poppy/ :
  - It allows for the creation and query of poppy and DCSO bloom filters
  - It comes with supervisor friendly worker that can hold a bloom filter in memory and answer client queries.
  """
  @moduledoc since: "0.1.0"

  @doc """
  Create a new bloom filter.
  Returns a `Reference` to the Bloom Filter or `{:error, "a message describing the error"}`

  ## Examples

      iex(4)> bf = ExPoppy.new(100000, 0.01)
      #Reference<0.2530677463.222167047.167339>
  """
  def new(_capacity, _false_positive_rate), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Creates a new bloom filter, specifying the filter version:
   - `1` for DCSO bloom filter format
   - `2` for poppy bloom filter format

  See https://www.misp-project.org/2024/03/25/Poppy-a-new-bloom-filter-format-and-project.html/ for a complete explanation of the differences.

  Returns a `Reference` to the Bloom Filter or `{:error, "a message describing the error"}`

  ## Examples
      iex(2)> bf = ExPoppy.with_version(1, 10000, 0.001)
      #Reference<0.362273875.1027997698.75968>

      iex(3)> bf = ExPoppy.with_version(2, 10000, 0.001)
      #Reference<0.362273875.1027997698.75988>
  """
  def with_version(_version, _capacity, _false_positive_rate),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Creates a new bloom filter, specifying the filter version, and additional parameters.
  See `with_version` for a description of the `version` parameter.
  `opt` specifies how Poppy will optimize the bloom filter:
  - 0: no optimization (default),
  - 1: optimize for space,
  - 2: optimize for speed,
  - 3: best overall.

  Returns a `Reference` to the Bloom Filter or `{:error, "a message describing the error"}`

  ## Examples
      iex(3)> bf = ExPoppy.with_params(2, 10000, 0.001, 1)
      #Reference<0.2014093505.3446538246.36083>
  """
  def with_params(_version, _capacity, _false_positive_rate, _opt),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Inserts a `String` into the bloom filter.
  Returns `true` or a `{:error, "a message describing the error"}`

  ## Example
      iex(4)> ExPoppy.insert_str(bf, "bloom filters are cool")
      true
  """
  def insert_str(_bloom_filter_reference, _string), do: :erlang.nif_error(:nif_not_loaded)
  # def insert_bytes(_a, _b), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Checks whether a `String` may be in the bloom filter.
  Return `true` or `false`
  ## Examples
      iex(6)> ExPoppy.contains_str(bf, "bloom filters are not cool.")
      false
      iex(7)> ExPoppy.contains_str(bf, "bloom filters are cool")
      true
  """
  def contains_str(_bloom_filter_reference, _string), do: :erlang.nif_error(:nif_not_loaded)
  # def contains_bytes(_a, _b), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Returns the filter version
  ## Example
      iex(8)> ExPoppy.version(bf)
      2
  """
  def version(_bloom_filter_reference), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Returns the filter capacity
  ## Example
      iex(15)> ExPoppy.capacity(hashlookup)
      405127458
  """
  def capacity(_bloom_filter_reference), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Returns the filter false positive rate
  ## Example
      iex(10)> ExPoppy.fpp(bf)
      0.001
  """
  def fpp(_bloom_filter_reference), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Returns the filter estimated number of items stored in the bloom filter.
  ## Example
      iex(11)> ExPoppy.count_estimate(bf)
      1
  """
  def count_estimate(_bloom_filter_reference), do: :erlang.nif_error(:nif_not_loaded)

  # def data(_bloom_filter_reference), do: :erlang.nif_error(:nif_not_loaded)
  @doc """
  Loads the filters located at `String`
  Returns a `Reference` to the bloom filter or `{:error, "a message describing the error"}`

  ## Example
      iex(13)> hashlookup = ExPoppy.load_filter("~/hashlookup-full.bloom")
      {:error, "IO error: No such file or directory (os error 2)"}
      iex(14)> hashlookup = ExPoppy.load_filter("/home/jlouis/hashlookup-full.bloom")
      #Reference<0.2014093505.3446538246.36262>
  """
  def load_filter(_path), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Save the bloom filter to a file `String`

  Returns `{}` or {:error, "a message describing the error"}

  ## Examples
      iex(16)> ExPoppy.save(bf, "/home/jlouis/test.bloom")
      {}
      iex(17)> ExPoppy.save(bf, "/root/test.boom")
      {:error, "IO error: Permission denied (os error 13)"}
  """
  def save(_bloom_filter_reference, _path), do: :erlang.nif_error(:nif_not_loaded)
end
