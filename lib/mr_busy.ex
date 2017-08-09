defmodule MrBusy do
  @behaviour :gen_event

  def init(__MODULE__) do
    {:ok, %{config: get_config()}}
  end

  def handle_call({:configure, options}, state) do
    {:ok, %{state | config: get_config(options)}}
  end

  # ignore messages where the group leader is in a different node
  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, mdata}}, %{config: config} = state) do
    # IO.puts "the format and output: #{inspect fmt} :: #{inspect output} :: #{inspect state}"
    event = %{
      time: timestamp(ts),
      level: level,
      metadata: metadata(mdata, config),
      message: (Logger.Formatter.format(config[:format], level, msg, ts, mdata) |> to_string),
    } |> Poison.encode!

    if config[:output] == :console do
      IO.puts(event)
    end

    {:ok, state}
  end

  def handle_event(:flush, state) do
    # nothing to flush
    {:ok, state}
  end

  def handle_event(_, state) do
   {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp get_config(opts \\ []) do
    cnf =
      Application.get_env(:logger, :mr_busy, [])
      |> Keyword.merge(opts)

    fmt_string = Keyword.get(cnf, :format, "$message")
    output     = Keyword.get(cnf, :output, :console)

    cnf
    |> Keyword.put(:format, Logger.Formatter.compile(fmt_string))
    |> Keyword.put(:output, output)
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
