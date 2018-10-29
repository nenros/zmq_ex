formatters =
  case System.get_env("CI") do
    true -> [JUnitFormatter, ExUnit.CLIFormatter]
    _ -> [ExUnit.CLIFormatter]
  end

ExUnit.configure(formatters: formatters)

ExUnit.start()
