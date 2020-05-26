defmodule Chats.Message do
  use Ecto.Schema

  @primary_key {:MessageId, :id, autogenerate: true}
#  @derive {Poison.Encoder, only: [:name, :age]}
  schema "Message" do
    field :MatchedContactId, :integer
    field :MessageDateTime, Ecto.DateTime
    field :MessageText, :string
    field :MessageOwner, :integer
  end

end