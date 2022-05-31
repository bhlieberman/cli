defmodule Files.Options do
  @moduledoc false
  defstruct contents: nil, text: nil, ignore_case: :false
end

defmodule Errors do
  defmodule InvalidFlag do
    defexception message: "Not a valid flag"
  end
end

defmodule Files do
  alias Files.Options

  @moduledoc """
  Logic for opening and reading and parsing files
  """
  def opts() do
    %Options{}
  end

  def rem_flags([flag | val], opts) do
    case flag do
      "-f" ->
        [filename | rem] = val
        opts = %{opts | contents: File.stream!(filename, [:trim_bom])}
        rem_flags(rem, opts)

      "-h" ->
        [match_on | rem] = val
        opts = %{opts | text: match_on}
        rem_flags(rem, opts)

      "-i" ->
        [ignore_case | rem] = val
        opts = %{opts | ignore_case: String.to_existing_atom(ignore_case)}
        rem_flags(rem, opts)

      _ ->
        raise Errors.InvalidFlag
    end
  end

  def rem_flags([], opts) do
    regex(opts)
  end

  defp regex(opts) do
    with opts.ignore_case do
      opts.contents
        |> Stream.map(&String.trim/1)
        |> Stream.with_index
        |> Stream.filter(fn ({line, index}) -> String.contains?(line, opts.text) end)
        |> Stream.each(fn ({line, index}) -> IO.puts "#{index+1}: #{line}" end)
        |> Stream.run
    end
  end
end


defmodule Cli do
  import Files

  @moduledoc """
  This is a very basic implementation
  of GREP lacking most features
  """
  def args(args) do
    rem_flags(args, opts())
  end

  @doc """
  Retrieves command line args for parsing
  """
  def get_args() do
    args(System.argv())
  end
end

Cli.get_args()
