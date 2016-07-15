defmodule MrBusy do
  use GenEvent

  def init(__MODULE__) do
    IO.puts "initing"
    {:ok, %{config: get_config}}
  end

  def handle_call({:configure, options}, state) do
    IO.puts "configuring"
    {:ok, %{state | config: get_config(options)}}
  end

  # ignore messages where the group leader is in a different node
  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, mdata}}, state) do
    config = get_config
    # message = Logger.Formatter.format(config[:format], level, msg, ts, mdata)
    event = %{
      time: timestamp(ts),
      level: level,
      metadata: metadata(mdata, config),
      message: (Logger.Formatter.format(config[:format], level, msg, ts, mdata) |> to_string),
    } |> Poison.encode!

    IO.puts(event)
    {:ok, state}
  end

  defp get_config(opts \\ []) do
    cnf =
      Application.get_env(:logger, :mr_busy, [])
      |> Keyword.merge(opts)

    fmt_string = Keyword.get(cnf, :format, "$message")

    Keyword.put(cnf, :format, Logger.Formatter.compile(fmt_string))
  end

  defp timestamp({{y, m, d},{h, mn, s, ms}}) do
    %NaiveDateTime{
      year: y,
      month: m,
      day: d,
      hour: h,
      minute: mn,
      second: s,
      microsecond: {ms * 1000, 3},
    } |> NaiveDateTime.to_iso8601
  end

  defp metadata(data, config) do
    keys = Keyword.get(config, :metadata, [])
    Keyword.take(data, keys) |> Enum.into(%{})
  end
end
