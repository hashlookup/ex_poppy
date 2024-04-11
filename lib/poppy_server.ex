defmodule ExPoppy.ExPoppyServer do
  use GenServer

  # Client API
  @doc """
  Starts genserver with module name.
  ## Examples
      iex(1)> {:ok, pid} = ExPoppyServer.start_link([])
      {:ok, #PID<0.188.0>}
      iex(4)> {:ok, pid2} = ExPoppyServer.start_link([])
      ** (MatchError) no match of right hand side value: {:error, {:already_started, #PID<0.188.0>}}
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Starts genserver with a name
  ## Examples
      iex(2)> {:ok, pid1} = ExPoppyServer.start_link([], :mon_poppy_serveur)
      {:ok, #PID<0.190.0>}
      iex(3)> GenServer.whereis(:mon_poppy_serveur)
      #PID<0.190.0>
  """
  def start_link(opts, name) do
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Inserts a `string` into the bloomfilter.
  Returns `:ok` or `{:error, "a message describing the error}`
  ## Examples
      iex(4)> ExPoppyServer.insert(pid, "toto")
     :ok
  """
  def insert(bf_pid, string) when is_pid(bf_pid) and is_binary(string) do
    GenServer.call(bf_pid, {:insert, string})
  end

  @doc """
  Checks whether a `string` may be preesnt in the bloom filter.
  Returns `true` or `false`
  ## Examples
      iex(5)> ExPoppyServer.contains(pid, "toto")
      true
      iex(6)> ExPoppyServer.contains(pid, "tata")
      false
  """
  def contains(bf_pid, string) when is_pid(bf_pid) and is_binary(string) do
    GenServer.call(bf_pid, {:contains, string})
  end

  @doc """
  Returns the filter's version
  ## Examples
      iex(7)> ExPoppyServer.version(pid)
      2
  """
  def version(bf_pid) when is_pid(bf_pid) do
    GenServer.call(bf_pid, {:version})
  end

  @doc """
  Returns the filter's capacity
  ## Examples
      iex(8)> ExPoppyServer.capacity(pid)
      10000
  """
  def capacity(bf_pid) when is_pid(bf_pid) do
    GenServer.call(bf_pid, {:capacity})
  end

  @doc """
  Returns the filter's false positive rate
  ## Examples
      iex(8)> ExPoppyServer.fpp(pid)
      0.001
  """
  def fpp(bf_pid) when is_pid(bf_pid) do
    GenServer.call(bf_pid, {:fpp})
  end

  @doc """
  Returns the estimate count of elements in the bloom filter
  ## Examples
      iex(2)> ExPoppyServer.insert(pid, "toto")
      :ok
      iex(3)> ExPoppyServer.insert(pid, "tata")
      :ok
      iex(4)> ExPoppyServer.count_estimate(pid)
      2
  """
  def count_estimate(bf_pid) when is_pid(bf_pid) do
    GenServer.call(bf_pid, {:count_estimate})
  end

  @doc """
  Loads the bloom filter located at `path`.
  Returns `:ok` or `{:error, "a message describing the error"}`
  # Examples
      iex(5)> ExPoppyServer.load(pid, "toto")
      :ok
      iex(6)> ExPoppyServer.load(pid, "/root/toto")
      {:error, "IO error: Permission denied (os error 13)"}
      iex(8)> ExPoppyServer.load(pid, "/home/jlouis/tata")
      {:error, "IO error: No such file or directory (os error 2)"}
  """
  def load(bf_pid, path) when is_pid(bf_pid) and is_binary(path) do
    GenServer.call(bf_pid, {:load, path})
  end

  @doc """
  Saves the bloom filter to a file located at `path`
  Returns `:ok` or `{:error, "a message describing the error"}`
  ## Examples
      iex(4)> ExPoppyServer.save(pid, "toto")
      :ok
      iex(6)> ExPoppyServer.save(pid, "/root/toto")
      {:error, "IO error: Permission denied (os error 13)"}
  """
  def save(bf_pid, path) when is_pid(bf_pid) and is_binary(path) do
    GenServer.call(bf_pid, {:save, path})
  end

  # Server callbacks
  @doc false
  def init(opts) do
    opts =
      opts
      |> Keyword.put_new(:capacity, 10000)
      |> Keyword.put_new(:fpp, 0.001)
      |> Keyword.put_new(:version, 2)

    # loading can take time so we return init to activate the mailbox
    # and continue
    {:ok, opts, {:continue, :load_or_create_bloom_filter}}
  end

  @doc false
  def handle_continue(:load_or_create_bloom_filter, opts) do
    case load_or_create_bloom_filter(opts) do
      {:error, reason} -> {:stop, reason}
      bloom_filter -> {:noreply, bloom_filter}
    end
  end

  @doc false
  def handle_call({:insert, string}, _from, bloom_filter) do
    case ExPoppy.insert_str(bloom_filter, string) do
      true -> {:reply, :ok, bloom_filter}
      {:error, _} -> {:reply, :error, bloom_filter}
    end
  end

  @doc false
  def handle_call({:contains, string}, _from, bloom_filter) do
    case ExPoppy.contains_str(bloom_filter, string) do
      true -> {:reply, true, bloom_filter}
      false -> {:reply, false, bloom_filter}
    end
  end

  @doc false
  def handle_call({:version}, _from, bloom_filter) do
    {:reply, ExPoppy.version(bloom_filter), bloom_filter}
  end

  @doc false
  def handle_call({:capacity}, _from, bloom_filter) do
    {:reply, ExPoppy.capacity(bloom_filter), bloom_filter}
  end

  @doc false
  def handle_call({:fpp}, _from, bloom_filter) do
    {:reply, ExPoppy.fpp(bloom_filter), bloom_filter}
  end

  @doc false
  def handle_call({:count_estimate}, _from, bloom_filter) do
    {:reply, ExPoppy.count_estimate(bloom_filter), bloom_filter}
  end

  @doc false
  def handle_call({:load, path}, _from, bloom_filter) do
    case ExPoppy.load_filter(path) do
      {:error, msg} -> {:reply, {:error, msg}, bloom_filter}
      bloom_filter -> {:reply, :ok, bloom_filter}
    end
  end

  @doc false
  def handle_call({:save, path}, _from, bloom_filter) do
    case ExPoppy.save(bloom_filter, path) do
      {} -> {:reply, :ok, bloom_filter}
      {:error, msg} -> {:reply, {:error, msg}, bloom_filter}
    end
  end

  @doc false
  defp load_or_create_bloom_filter(opts) do
    case Keyword.pop(opts, :path) do
      {nil, opts} ->
        case Keyword.pop(opts, :parameter) do
          {nil, opts} ->
            ExPoppy.with_version(opts[:version], opts[:capacity], opts[:fpp])

          {parameter, opts} ->
            ExPoppy.with_params(opts[:version], opts[:capacity], opts[:fpp], parameter)
        end

      {path, _} ->
        ExPoppy.load_filter(path)
    end
  end
end
