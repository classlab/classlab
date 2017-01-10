defmodule Classlab.User do
  @moduledoc """
  User model. A user can't access events directly but only by membership.
  The membership determines the role: owner, trainer, attendee.
  """
  alias Ecto.UUID
  alias Calendar.DateTime
  use Classlab.Web, :model

  # Fields
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :contact_url, :string
    field :access_token, :string
    field :access_token_expired_at, :utc_datetime
    field :superadmin, :boolean
    timestamps()

    has_many :chat_messages, Classlab.ChatMessage, on_delete: :nilify_all
    has_many :feedbacks, Classlab.Feedback, on_delete: :nilify_all
    has_many :memberships, Classlab.Membership, on_delete: :delete_all
  end

  # Composable Queries
  def with_valid_access_token(query) do
    from u in query,
      where: u.access_token_expired_at >= ^DateTime.now_utc
  end

  def admin_sort(query) do
    from u in query, order_by: [desc: :superadmin, desc: :inserted_at]
  end

  # Changesets & Validations
  @fields [:first_name, :last_name, :email, :contact_url, :access_token, :access_token_expired_at]
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([:email, :access_token, :access_token_expired_at])
    |> unique_constraint(:email)
    |> unique_constraint(:access_token)
  end

  @fields [:email, :first_name, :last_name]
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([:email])
    |> generate_access_token()
  end

  @fields [:first_name, :last_name, :email, :contact_url, :superadmin]
  def superadmin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([:email])
    |> unique_constraint(:email)
  end

  # Model Functions
  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    [first_name, last_name] |> Enum.join(" ") |> String.trim()
  end

  def change_superadmin(%__MODULE__{} = user) do
    if user.id == 1 && !user.superadmin do
      change(user, superadmin: true)
    end
  end

  defp generate_access_token(%Ecto.Changeset{} = changeset) do
    access_token_max_age = Application.get_env(:classlab, __MODULE__)[:access_token_max_age]
    access_token_expired_at = DateTime.add!(DateTime.now_utc, access_token_max_age)

    changeset
    |> put_change(:access_token, UUID.generate())
    |> put_change(:access_token_expired_at, access_token_expired_at)
  end
end
