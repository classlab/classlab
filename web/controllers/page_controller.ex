defmodule Classlab.PageController do
  @moduledoc false
  alias Classlab.Event
  alias Ecto.Query
  use Classlab.Web, :controller

  def index(conn, _params) do
    user = current_user(conn)

    events =
      Event
      |> Event.current_public()
      |> Query.limit(5)
      |> Query.preload(:location)
      |> Repo.all()

    memberships =
      if user do
        user
        |> assoc(:memberships)
        |> Repo.all()
      else
        []
      end

    render(conn, "index.html", events: events, current_memberships: memberships)
  end
end
