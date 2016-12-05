defmodule Classlab.Superadmin.EventController do
  @moduledoc false
  alias Classlab.Event
  use Classlab.Web, :controller

  plug :scrub_params, "event" when action in [:create, :update]

  def index(conn, _params) do
    events =
      Event
      |> Repo.all()

    render(conn, "index.html", events: events)
  end

  def show(conn, %{"id" => id}) do
    event =
      Event
      |> Repo.get_by!(slug: id)

    render(conn, "show.html", event: event)
  end

  def delete(conn, %{"id" => id}) do
    event =
      Event
      |> Repo.get_by!(slug: id)

    Repo.delete!(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: superadmin_event_path(conn, :index))
  end
end
