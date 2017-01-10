defmodule Classlab.Account.EventCopyController do
  @moduledoc false
  alias Classlab.{Event, Location, Material, Membership, Task}
  use Classlab.Web, :controller
  use Classlab.ErrorRescue, from: Ecto.NoResultsError, redirect_to: &page_path(&1, :index)

  plug :restrict_roles, [1, 2]

  def new(conn, _params) do
    event = load_event(conn)
    changeset = Event.changeset(%Event{name: event.name})

    render(conn, "new.html", event: event, changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event = load_event(conn)

    # Copy tasks
    tasks =
      event
      |> assoc(:tasks)
      |> Repo.all()
      |> Enum.map(fn(task) ->
          %Task{
            body_markdown: task.body_markdown,
            bonus_markdown: task.bonus_markdown,
            external_app_url: task.external_app_url,
            hint_markdown: task.hint_markdown,
            position: task.position,
            title: task.title
          }
        end)

    # Copy materials
    materials =
      event
      |> assoc(:materials)
      |> Repo.all()
      |> Enum.map(fn(material) ->
          %Material{
            type: material.type,
            description_markdown: material.description_markdown,
            url: material.url,
            position: material.position,
            title: material.title
          }
        end)

    # Create owner
    memberships = [%Membership{user: current_user(conn), role_id: 1}]

    # Copy possible location
    location =
      if event.location do
        %Location{
          name: event.location.name,
          address_line_1: event.location.address_line_1,
          address_line_2: event.location.address_line_2,
          zipcode: event.location.zipcode,
          city: event.location.city,
          country: event.location.country,
          external_url: event.location.external_url,
        }
      else
        nil
      end

    changeset = Event.changeset(
      %Event{
        description_markdown: event.description_markdown,
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        timezone: event.timezone,
        location: location,
        before_email_subject: event.before_email_subject,
        before_email_body_text: event.before_email_body_text,
        after_email_subject: event.after_email_subject,
        after_email_body_text: event.after_email_body_text,
        tasks: tasks,
        materials: materials,
        memberships: memberships
      }, event_params)

    new_event = Repo.insert!(changeset)

    redirect(conn, to: classroom_event_path(conn, :edit, new_event))
  end

  # Private methods
  defp load_event(conn) do
    conn
    |> current_event()
    |> Repo.preload(:location)
  end
end
