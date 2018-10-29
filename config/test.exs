use Mix.Config

config :junit_formatter,
  report_dir: System.get_env("JUNIT_DIR")
