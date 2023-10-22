defmodule ErrorReporter do
  require Logger
  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta.job
      |> Map.take([:id, :args, :meta, :queue, :worker])
      |> Map.merge(measure)

    Logger.error(oban_error: %{
      reason: meta.reason, stacktrace: meta.stacktrace, extra: extra
    })

    # Sentry.capture_exception(meta.reason, stacktrace: meta.stacktrace, extra: extra)
  end
end
