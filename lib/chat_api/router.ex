defmodule Chats.Router do
  use Plug.Router
  use Timex
  alias Chats.Message
  import Ecto.Query

#  @skip_token_verification %{jwt_skip: true}
#  @skip_token_verification_view %{view: DogView, jwt_skip: true}
#  @auth_url Application.get_env(:profiles, :auth_url)
#  @api_port Application.get_env(:profiles, :port)
#  @db_table Application.get_env(:profiles, :redb_db)
#  @db_name Application.get_env(:profiles, :redb_db)

  #use Profiles.Auth
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
#  plug Profiles.AuthPlug
  plug(:dispatch)

  post "/get-by-matched-contact-id" do
    matched_contact_id = Map.get(conn.params, "matched_contact_id", nil)
    chats =  Chats.Repo.all(from d in Chats.Message, where: d."MatchedContactId" == ^matched_contact_id)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(chats))
  end

  post "/get-by-message-owner" do
    message_owner = Map.get(conn.body_params, "message_owner", nil)
    Logger.debug inspect(message_owner)
    chats =  Chats.Repo.all(from d in Chats.Message, where: d."MessageOwner" == ^message_owner)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(chats))
  end

  post "/send-message" do
    Logger.debug inspect(conn.body_params)

    {matched_contact_id, message_owner, message_text} = {
      Map.get(conn.body_params, "matched_contact_id", nil),
      Map.get(conn.body_params, "message_owner", nil),
      Map.get(conn.body_params, "message_text", nil)
    }

    message_date_time = Ecto.DateTime.utc
    Logger.debug inspect(message_date_time)

    cond do
      is_nil(matched_contact_id) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'matched_contact_id' field must be provided"})
      is_nil(message_date_time) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'message_date_time' field must be provided"})
      is_nil(message_text) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'message_text' field must be provided"})
      is_nil(message_owner) ->
        conn
        |> put_status(400)
        |> assign(:jsonapi, %{"error" => "'message_owner' field must be provided"})
      true ->
        case %Message{
          MatchedContactId: matched_contact_id,
          MessageDateTime: message_date_time,
          MessageText: message_text,
          MessageOwner: message_owner
        } |> Chats.Repo.insert do
          {:ok, new_message} ->
            rabbit_url = Application.get_env(:chats, :rabbitmq_host)
            Logger.debug inspect(rabbit_url)

            case AMQP.Connection.open(rabbit_url) do
              {:ok, connection} ->
                case AMQP.Channel.open(connection) do
                  {:ok, channel} ->
                  AMQP.Basic.publish(channel, "", "matched_contact_id_#{matched_contact_id}", "Muje fa update la mesaje. ;)")
                  AMQP.Connection.close(connection)
                  {:error, unkown_host} ->
                  Logger.debug inspect(unkown_host)
              :error ->
                Logger.debug inspect("AMQP connection coould not be established")
                end
            end

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:data => new_message}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(507, Poison.encode!(%{"error" => "An unexpected error happened"}))
        end
      end

  end
end
