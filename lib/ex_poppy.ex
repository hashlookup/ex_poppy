defmodule ExPoppy do
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

      ExPoppy.new(100000, 0.01)
      #Reference<0.2530677463.222167047.167339>
  """
  defdelegate new(capacity, false_positive_rate), to: ExPoppy.Native, as: :new

  @doc """
  Creates a new bloom filter, specifying the filter version:
   - `1` for DCSO bloom filter format
   - `2` for poppyV2 bloom filter format

  See https://www.misp-project.org/2024/03/25/Poppy-a-new-bloom-filter-format-and-project.html/ for a complete explanation of the differences.

  Returns a `Reference` to the Bloom Filter or `{:error, "a message describing the error"}`

  ## Examples
      ExPoppy.with_version(1, 10000, 0.001)
      #Reference<0.362273875.1027997698.75968>

      ExPoppy.with_version(2, 10000, 0.001)
      #Reference<0.362273875.1027997698.75988>
  """
  defdelegate with_version(version, capacity, false_positive_rate),
    to: ExPoppy.Native,
    as: :with_version

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
      ExPoppy.with_params(2, 10000, 0.001, 1)
      #Reference<0.2014093505.3446538246.36083>
  """
  defdelegate with_params(version, capacity, false_positive_rate, opt),
    to: ExPoppy.Native,
    as: :with_params

  @doc """
  Inserts a `String` into the bloom filter.
  Returns `true` or a `{:error, "a message describing the error"}`

  ## Example
      iex(3)> bf = ExPoppy.new(100000, 0.01)
      iex(4)> ExPoppy.insert_str(bf, "bloom filters are cool")
      true
  """
  defdelegate insert_str(bloom_filter_reference, string), to: ExPoppy.Native, as: :insert_str

  @doc """
  Checks whether a `String` may be in the bloom filter.
  Return `true` or `false`
  ## Examples
      iex(3)> bf = ExPoppy.new(100000, 0.01)
      iex(4)> ExPoppy.insert_str(bf, "bloom filters are cool")
      iex(6)> ExPoppy.contains_str(bf, "bloom filters are not cool.")
      false
      iex(7)> ExPoppy.contains_str(bf, "bloom filters are cool")
      true
  """
  defdelegate contains_str(bloom_filter_reference, string), to: ExPoppy.Native, as: :contains_str

  @doc """
  Returns the filter version
  ## Example
      iex(3)> bf = ExPoppy.new(100000, 0.01)
      iex(8)> ExPoppy.version(bf)
      2
  """
  defdelegate version(bloom_filter_reference), to: ExPoppy.Native, as: :version

  @doc """
  Returns the filter capacity
  ## Example
      ExPoppy.capacity(hashlookup)
      405127458
  """
  defdelegate capacity(bloom_filter_reference), to: ExPoppy.Native, as: :capacity

  @doc """
  Returns the filter false positive rate
  ## Example
      iex(3)> bf = ExPoppy.new(1000, 0.001)
      iex(10)> ExPoppy.fpp(bf)
      0.001
  """
  defdelegate fpp(bloom_filter_reference), to: ExPoppy.Native, as: :fpp

  @doc """
  Returns the filter estimated number of items stored in the bloom filter.
  ## Example
      iex(3)> bf = ExPoppy.new(1000, 0.001)
      iex(4)> ExPoppy.insert_str(bf, "bloom filters are cool")
      iex(11)> ExPoppy.count_estimate(bf)
      1
  """
  defdelegate count_estimate(bloom_filter_reference), to: ExPoppy.Native, as: :count_estimate

  # def data(_bloom_filter_reference), do: err()
  @doc """
  Loads the filters located at `String`
  Returns a `Reference` to the bloom filter or `{:error, "a message describing the error"}`

  ## Example
      hashlookup = ExPoppy.load_filter("~/hashlookup-full.bloom")
      {:error, "IO error: No such file or directory (os error 2)"}
      hashlookup = ExPoppy.load_filter("/home/jlouis/hashlookup-full.bloom")
      #Reference<0.2014093505.3446538246.36262>
  """
  defdelegate load_filter(path), to: ExPoppy.Native, as: :load_filter

  @doc """
  Save the bloom filter to a file `String`

  Returns `{}` or {:error, "a message describing the error"}

  ## Examples
      ExPoppy.save(bf, "/home/jlouis/test.bloom")
      {}
      ExPoppy.save(bf, "/root/test.boom")
      {:error, "IO error: Permission denied (os error 13)"}
  """
  defdelegate save(bloom_filter_reference, path), to: ExPoppy.Native, as: :save
end
