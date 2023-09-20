defmodule IslandsEngine.Iex.Processes do
  @moduledoc false

  def loop do
    receive do
      message ->
        IO.puts("Received message: #{message}")
    end

    loop()
  end

  def run do
    # loop = spawn(Processes, :loop, [])
    # Process.link(loop)

    Process.flag(:trap_exit, true)
    spawn_link(__MODULE__, :loop, [])

    # Caller can run Process.flag(:trap_exit, true) # {:EXIT, ​pid, reason}
  end
end
