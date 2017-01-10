defmodule Classlab.Membership do
  @moduledoc """
  A membership connects users with events.
  The role determines access rights.
  Possible roles: owner, trainer, attendee
  """
  alias Classlab.{Event}
  alias Calendar.DateTime
  use Classlab.Web, :model

  # Fields
  schema "memberships" do
    field :seat_position_x, :integer, default: 0
    field :seat_position_y, :integer, default: 0
    field :before_email_sent_at, :utc_datetime
    field :after_email_sent_at, :utc_datetime
    timestamps()

    belongs_to :event, Classlab.Event
    belongs_to :role, Classlab.Role
    belongs_to :user, Classlab.User
  end

  # Composable Queries
  def for_event(query, %Event{id: event_id}) do
    from membership in query, where: membership.event_id == ^event_id
  end

  def not_as_role(query, role_id) do
    from membership in query, where: membership.role_id != ^role_id
  end

  def as_role(query, nil), do: query
  def as_role(query, role_id) do
    from membership in query, where: membership.role_id == ^role_id
  end

  def as_roles(query, role_ids) do
    from membership in query, where: membership.role_id in ^role_ids
  end

  def no_after_email_sent(query) do
    from membership in query, where: is_nil(membership.after_email_sent_at)
  end

  # Changesets & Validations
  @fields ~w(role_id event_id seat_position_x seat_position_y)
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(~w(role_id event_id seat_position_x seat_position_y)a)
  end

  def touch(%Ecto.Changeset{} = changeset, field) do
    put_change(changeset, field, DateTime.now_utc)
  end

  # Model Functions
  def touch(%__MODULE__{} = membership, field) do
    params = Map.put(%{}, field, DateTime.now_utc)
    membership |> cast(params, [field])
  end
end
