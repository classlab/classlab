defmodule Classlab.EventController do
  @moduledoc false
  alias Classlab.{Event, Membership}
  alias Ecto.Query
  use Classlab.Web, :controller

  use Classlab.ErrorRescue, from: Ecto.NoResultsError, redirect_to: &page_path(&1, :index)

  def index(conn, _params) do
    events =
      Event
      |> Event.current_public()
      |> Query.preload(:location)
      |> Repo.all()

    user = current_user(conn)

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

  def show(conn, _params) do
    event = load_event(conn)
    user = current_user(conn)

    if event.public do
      memberships =
        if user do
          user
          |> assoc(:memberships)
          |> Membership.for_event(event)
          |> Repo.all()
        else
          []
        end

      render(conn, "show.html", event: event, current_memberships: memberships)
    else
      conn
      |> put_flash(:error, "Permission denied")
      |> redirect(to: page_path(conn, :index))
    end
  end

  # Private methods
  defp load_event(conn) do
    Repo.get_by!(Event, slug: conn.params["id"])
  end
end
