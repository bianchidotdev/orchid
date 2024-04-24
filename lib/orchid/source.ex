defmodule Orchid.Source do
  defstruct [
    type: nil,
    url: nil,
    path: "orchid.yml",
    git_ref: "v0.1.0",
    interval: 60_000
  ]

  require Logger

  def fetch(%{type: "file"} = source) do
    case File.exists?(source.url) do
      true -> {:ok, source}
      false -> {:error, "File does not exist"}
    end
  end

  # if repo exists, verify remote url, fetch and reset
  # if repo does not exist, clone repo, fetch and reset
  # if path exists but is not repo or if not the correct repo,
  #   return error
  def fetch(%{type: "git"} = source) do
    case File.exists?(local_path(source.url)) do
      true -> fetch_repo(source)
      false -> clone_repo(source)
    end
  end

  defp repo_name(url) do
    url
    |> Path.basename()
    |> String.replace_trailing(".git", "")
  end

  # TODO: handle local repo
  defp fetch_repo(source) do
    reference_url = source.url
    with repo <- Git.new(local_path(source.url)),
      {:ok, _} <- Git.rev_parse(repo, ["--is-inside-work-tree"]),
      # I don't know why a string trim is needed - also unsure if this is a reasonable check
      {:ok, remote_url} <- Git.remote(repo, ["get-url", "origin"]),
      ^reference_url <- String.trim(remote_url),
      {:ok, _} <- fetch_and_reset_to_ref(repo, source.git_ref) do
      {:ok, repo}
    else
      {:ok, output} -> Logger.warning("Unexpected output: #{output}") && {:error, "Unexpected output"}
      {:error, error} -> {:error, error}
      url -> Logger.warning("Remote URL mismatch: #{url}") && {:error, "Remote URL mismatch"}
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
    with {:ok, _} <- Git.fetch(repo, ["origin", ref]),
      {:ok, _} <- Git.reset(repo, ["--hard", ref]) do
      {:ok, repo}
    else
      error -> error
    end
  end
end
