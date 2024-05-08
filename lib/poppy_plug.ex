defmodule ExPoppy.PoppyPlug do
  @behaviour Plug
  import Plug.Conn
  alias ExPoppy.ExPoppyServer

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{} = conn, opts) do
    {pid, _opts} = Keyword.pop(opts, :poppy_server)

    poppy_server =
      case pid do
        nil ->
          GenServer.whereis(ExPoppy.ExPoppyServer)

        pid ->
          pid
      end

    case poppy_server do
      nil ->
        # we fail silently
        conn

      _ ->
        nil
        # it means business
        Enum.each(opts[:filter], fn x ->
          if ExPoppyServer.contains(poppy_server, conn[x]) do
            conn
            |> send_resp(403, "Bad Request")
            |> halt()
          else
            conn
          end
        end)
    end
  end
end
