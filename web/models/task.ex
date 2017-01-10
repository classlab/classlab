defmodule Classlab.Task do
  @moduledoc """
  Connects a task with an event. All event tasks are
  visible to the attendees of an event.
  """
  use Classlab.Web, :model

  # Fields
  schema "tasks" do
    field :body_markdown, :string
    field :bonus_markdown, :string
    field :external_app_url, :string
    field :hint_markdown, :string
    field :position, :integer
    field :title, :string
    field :unlocked_at, :utc_datetime
    timestamps()

    belongs_to :event, Classlab.Event
  end

  # Composable Queries
  def unlocked(query) do
    from task in query,
      where: not is_nil(task.unlocked_at)
  end

  def locked(query) do
    from task in query,
      where: is_nil(task.unlocked_at)
  end

  def next_via_unlocked_at(query, %__MODULE__{} = current_task) do
    from task in query,
      order_by: [asc: :unlocked_at, asc: :position],
      where: task.unlocked_at > ^current_task.unlocked_at,
      limit: 1
  end

  def previous_via_unlocked_at(query, %__MODULE__{} = current_task) do
    from task in query,
      order_by: [desc: :unlocked_at, desc: :position],
      where: task.unlocked_at < ^current_task.unlocked_at,
      limit: 1
  end

  def next_via_position(query, %__MODULE__{} = current_task) do
    from task in query,
      order_by: [asc: :position],
      where: task.position > ^current_task.position,
      limit: 1
  end

  def previous_via_position(query, %__MODULE__{} = current_task) do
    from task in query,
      order_by: [desc: :position],
      where: task.position < ^current_task.position,
      limit: 1
  end

  # Changesets & Validations
  @fields [:body_markdown, :bonus_markdown, :event_id, :external_app_url, :hint_markdown, :position, :title]
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([:body_markdown, :position, :title])
    |> unique_constraint(:position, name: :tasks_position_event_id_index)
  end
end
