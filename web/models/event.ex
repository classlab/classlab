defmodule Classlab.Event do
  @moduledoc """
  Event model. An event is connected with an user by a membership.
  Location information is a separate model.
  """
  alias Classlab.{User, Utils.Slugger}
  alias Calendar.DateTime
  use Classlab.Web, :model

  # Fields
  @derive {Phoenix.Param, key: :slug}
  schema "events" do
    field :public, :boolean, default: false
    field :slug, :string
    field :name, :string
    field :description_markdown, :string
    field :invitation_token, :string
    field :invitation_token_active, :boolean, default: false
    field :before_email_subject, :string
    field :before_email_body_text, :string
    field :after_email_subject, :string
    field :after_email_body_text, :string
    field :starts_at, Calecto.DateTimeUTC
    field :ends_at, Calecto.DateTimeUTC
    field :timezone, :string
    timestamps()

    belongs_to :location, Classlab.Location
    has_many :chat_messages, Classlab.ChatMessage, on_delete: :delete_all
    has_many :feedbacks, Classlab.Feedback, on_delete: :delete_all
    has_many :invitations, Classlab.Invitation, on_delete: :delete_all
    has_many :memberships, Classlab.Membership, on_delete: :delete_all
    has_many :materials, Classlab.Material, on_delete: :delete_all
    has_many :tasks, Classlab.Task, on_delete: :delete_all
  end

  # Composable Queries
  def current_public(query) do
    from event in query,
      where: event.ends_at < ^DateTime.now_utc(),
      where: event.public == true
  end

  def as_role(query, %User{id: user_id}, role_id) do
    from event in query,
      left_join: membership in assoc(event, :memberships),
      where: membership.user_id == ^user_id and membership.role_id == ^role_id,
      select: event
  end

  def not_feedbacked_by_user(query, %User{id: user_id}) do
    from event in query,
      left_join: membership in assoc(event, :memberships),
      left_join: feedback in assoc(event, :feedbacks),
      where:  membership.user_id == ^user_id and membership.role_id == 3 and is_nil(feedback.user_id)
  end

  @fourteen_days 60 * 60 * 24 * 14
  def within_feedback_period(query, current_time \\ DateTime.now_utc()) do
    from event in query,
      where: event.ends_at <= ^current_time,
      where: event.ends_at >= ^DateTime.subtract!(current_time, @fourteen_days)
  end

  @seven_days 60 * 60 * 24 * 7
  def within_after_email_period(query, current_time \\ DateTime.now_utc()) do
    from event in query,
      where: event.ends_at <= ^current_time,
      where: event.ends_at >= ^DateTime.subtract!(current_time, @seven_days)
  end

  # Changesets & Validations
  @fields [:public, :name, :description_markdown, :invitation_token, :invitation_token_active,
           :starts_at, :ends_at, :timezone, :before_email_subject, :before_email_body_text,
           :after_email_subject, :after_email_body_text]
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> optional_cast_location(params[:location] || params["location"])
    |> generate_invitation_token()
    |> Slugger.generate_slug(:name, random: 100_000..999_999)
    |> validate_required([:public, :slug, :name, :description_markdown, :invitation_token,
         :invitation_token_active, :starts_at, :ends_at, :timezone])
    |> unique_constraint(:slug)
    |> unique_constraint(:invitation_token)
  end

  @fields [:before_email_subject, :before_email_body_text, :after_email_subject, :after_email_body_text]
  def email_template_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_length(:before_email_subject, max: 70)
    |> validate_length(:after_email_subject, max: 70)
  end

  defp generate_invitation_token(changeset, length \\ 6) do
    token = length |> :crypto.strong_rand_bytes |> Base.url_encode64 |> binary_part(0, length)
    put_change(changeset, :invitation_token, token)
  end

  # Model methods
  @fourteen_days 60 * 60 * 24 * 14
  def within_feedback_period?(%__MODULE__{ends_at: ends_at}, current_time \\ DateTime.now_utc()) do
    fourteen_days_ago = DateTime.subtract!(current_time, @fourteen_days)

    (DateTime.after?(ends_at, fourteen_days_ago) || !DateTime.before?(ends_at, fourteen_days_ago))
    &&
    (DateTime.before?(ends_at, current_time) || !DateTime.after?(ends_at, current_time))
  end

  ## Before event email
  def before_email_subject(%__MODULE__{before_email_subject: subject}) when is_binary(subject) do
    subject
  end
  def before_email_subject(%__MODULE__{before_email_subject: _}) do
    "{{event_name}}: A warm welcome"
  end

  def before_email_body_text(%__MODULE__{before_email_body_text: text}) when is_binary(text) do
    text
  end
  def before_email_body_text(%__MODULE__{before_email_body_text: _}) do
    "Hi {{attendee_first_name}},\n\n" <>
    "Welcome to {{event_name}}\n\n" <>
    "Here is the Link to the classroom: {{classroom_link}}"
  end

  ## After event email
  def after_email_subject(%__MODULE__{after_email_subject: subject}) when is_binary(subject) do
    subject
  end
  def after_email_subject(%__MODULE__{after_email_subject: _}) do
    "{{event_name}}: Thanks for joining"
  end

  def after_email_body_text(%__MODULE__{after_email_body_text: text}) when is_binary(text) do
    text
  end
  def after_email_body_text(%__MODULE__{after_email_body_text: _}) do
    "Hi {{attendee_first_name}},\n\n" <>
    "Thanks for joining us at {{event_name}}"
  end

  defp optional_cast_location(changeset, nil), do: changeset
  defp optional_cast_location(changeset, location_params) do
    if Enum.all?(location_params, fn({_,v}) -> is_nil(v) end) do
      changeset
    else
      cast_assoc(changeset, :location, required: false)
    end
  end
end
