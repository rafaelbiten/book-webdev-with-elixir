defmodule Protocols.JsonEncoders do
  alias IslandsEngine.Impl.Coordinate
  alias IslandsEngine.Impl.Island
  require Protocol

  defimpl Jason.Encoder, for: [MapSet, Range, Stream] do
    def encode(struct, opts) do
      Jason.Encode.list(Enum.to_list(struct), opts)
    end
  end

  Protocol.derive(Jason.Encoder, Island)

  defimpl Jason.Encoder, for: Coordinate do
    def encode(%Coordinate{col: col, row: row}, opts) do
      Jason.Encode.map(%{col: col, row: row}, opts)
    end
  end
end
