defmodule PoppyPlug do
  @behaviour Plug
  import Plug.Conn

  @moduledoc """
  Documentation for `PoppyPlug`.

  PoppyPlug filters out requests that match an `ExPoppy` bloom filter served by
  an `ExPoppyServer`. The fields to match on are passed to the plug through `opt`.

  For instance to filter every requests for which the host may appear in the bloom filter:

  `plug(PoppyPlug, poppy_server: :plugfestpoppy, filter: :host)`

  """

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{} = conn, opts) do
    {process_name, opts} = Keyword.pop_first(opts, :poppy_server)

    poppy_server =
      case process_name do
        nil ->
          GenServer.whereis(ExPoppyServer)

        name ->
          GenServer.whereis(name)
      end

    case poppy_server do
      nil ->
        # we fail silently
        conn

      _ ->
        # it means business
        Enum.reduce(opts, conn, fn x, acc_conn ->
          case x do
            {:filter, :host} ->
              if ExPoppyServer.contains(poppy_server, Map.get(acc_conn, :host)) do
                acc_conn
                |> send_resp(403, "Forbidden request")
                |> halt()
              else
                acc_conn
              end

            {:filter, _} ->
              acc_conn

            _ ->
              acc_conn
          end
        end)
    end
  end
end
