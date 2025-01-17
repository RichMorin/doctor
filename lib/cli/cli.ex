defmodule Doctor.CLI do
  @moduledoc """
  Provides the various CLI task entry points and CLI arg parsing.
  """

  alias Mix.Project
  alias Doctor.{ModuleInformation, ModuleReport, ReportUtils}

  @doc """
  Given the CLI arguments, run the report on the project,
  """
  def run_report(args) do
    # Using the project's app name, fetch all the modules associated with the app
    module_report_list =
      Project.config()
      |> Keyword.get(:app)
      |> get_application_modules()

      # Fetch the module information from the list of application modules
      |> Enum.map(&generate_module_entry/1)

      # Filter out any files/modules that were specified in the config
      |> Enum.reject(fn module_info -> module_info.module in args.ignore_modules end)
      |> Enum.reject(fn module_info -> filter_ignore_paths(module_info, args.ignore_paths) end)

      # Asynchronously get the user defined functions from the modules
      |> Enum.map(&async_fetch_user_defined_functions/1)
      |> Enum.map(&Task.await(&1, 15_000))

      # Build report struct for each module
      |> Enum.sort(&(&1.file_relative_path < &2.file_relative_path))
      |> Enum.map(&ModuleReport.build/1)

    # Invoke the configured module reporter and return whether Doctor validation passed/failed
    args.reporter.generate_report(module_report_list, args)
    ReportUtils.doctor_report_passed?(module_report_list, args)
  end

  defp generate_module_entry(module) do
    module
    |> Code.fetch_docs()
    |> ModuleInformation.build(module)
  end

  defp async_fetch_user_defined_functions(%ModuleInformation{} = module_info) do
    Task.async(fn ->
      module_info
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
    end)
  end

  defp get_application_modules(application) do
    # Compile and load the application
    Mix.Task.run("compile")
    Application.load(application)

    # Get all the modules in the application
    {:ok, modules} = :application.get_key(application, :modules)

    modules
  end

  defp filter_ignore_paths(module_info, ignore_paths) do
    Enum.reduce_while(ignore_paths, false, fn pattern, _acc ->
      if Regex.match?(pattern, module_info.file_relative_path) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end
end
