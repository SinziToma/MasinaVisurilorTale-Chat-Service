defmodule Chats.Endpoint do
  require Logger
  use Plug.Router

  alias Chats.Auth

  plug(:match)

  @skip_token_verification %{jwt_skip: true}

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
#  plug Profiles.AuthPlug
  plug(:dispatch)

  forward("/chat", to: Chats.Router)

  match _ do
    send_resp(conn, 404, "Page not found!")
  end

end
