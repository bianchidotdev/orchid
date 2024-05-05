defmodule Orchid.Source do
  require Logger

  def fetch(%{type: "file"} = source) do
    url = Path.expand(source.url)

    with true <- File.dir?(url),
         path = Path.join(url, source.path),
         {:ok, config} <- read_config(path, format(path)) do
      {:ok, config}
    else
      false -> {:error, "URL is not a directory"}
      error -> error
    end
  end

  def fetch(%{type: "git"} = source) do
    with {:ok, repo} <- fetch_repo(source),
         path = Path.join(repo.path, source.path),
         {:ok, config} <- read_config(path, format(path)) do
      {:ok, config}
    else
      error -> error
    end
  end

  def parse(configs) do
    cluster_configs = Enum.filter(configs, fn config_map -> config_map["type"] == "cluster" end)
    service_configs = Enum.filter(configs, fn config_map -> config_map["type"] == "service" end)

    case cluster_configs do
      [] -> {:error, "No cluster config found"}
      [cluster_config] -> {:ok, {cluster_config, service_configs}}
      _ -> {:error, "Multiple cluster configs found"}
    end
  end

  # defp find_config(path) do
  #   possible_file_list = for base <- @base_filenames, type <- @file_types, do: Path.join(path, "#{base}.#{type}")

  #   case Enum.find(possible_file_list, &File.exists?/1) do
  #     nil -> {:error, "No valid config file found"}
  #     file -> {:ok, file}
  #   end
  # end

  defp read_config(path, :yaml), do: YamlElixir.read_all_from_file(path)

  # if repo exists, verify remote url, fetch and reset
  # if repo does not exist, clone repo, fetch and reset
  # if path exists but is not repo or if not the correct repo,
  #   return error
  defp fetch_repo(%{type: "git"} = source) do
    case File.exists?(local_path(source.url)) do
      true -> update_repo(source)
      false -> clone_repo(source)
    end
  end

  defp repo_name(url) do
    url
    |> Path.basename()
    |> String.replace_trailing(".git", "")
  end

  # TODO: handle local repo?
  defp update_repo(source) do
    reference_url = source.url

    with repo <- Git.new(local_path(source.url)),
         {:ok, _} <- Git.rev_parse(repo, ["--is-inside-work-tree"]),
         # I don't know why a string trim is needed - also unsure if this is a reasonable check
         {:ok, remote_url} <- Git.remote(repo, ["get-url", "origin"]),
         ^reference_url <- String.trim(remote_url),
         {:ok, _} <- fetch_and_reset_to_ref(repo, source.git_ref) do
      {:ok, repo}
    else
      {:ok, output} ->
        Logger.warning("Unexpected output: #{output}") && {:error, "Unexpected output"}

      {:error, error} ->
        {:error, error}

      url ->
        Logger.warning("Remote URL mismatch: expected: #{reference_url}, got: #{url}") &&
          {:error, "Remote URL mismatch"}
    end
  end

  defp local_path(url) do
    Path.join(Application.fetch_env!(:orchid, :local_repo_storage_path), repo_name(url))
  end

  defp clone_repo(%{url: url, git_ref: git_ref}) do
    with {:ok, repo} <- Git.clone(["--depth=1", url, local_path(url)]),
         {:ok, _} <- fetch_and_reset_to_ref(repo, git_ref) do
      {:ok, repo}
    else
      error -> error
    end
  end

  defp fetch_and_reset_to_ref(repo, ref) do
    Logger.info("Updating repo to ref: #{ref}")

    with {:ok, _} <- Git.fetch(repo, ["origin", ref]),
         {:ok, _} <- Git.reset(repo, ["--hard", ref]) do
      {:ok, repo}
    else
      error -> error
    end
  end

  defp format(path) do
    case Path.extname(path) do
      ".json" ->
        :json

      ".toml" ->
        :toml

      extension when extension in [".yaml", ".yml"] ->
        :yaml

      _ ->
        raise("Unsupported file type: #{path}")
    end
  end
end
