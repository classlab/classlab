defmodule Classlab.MembershipController do
  @moduledoc false
  alias Classlab.{Repo, Session, Event, Invitation, User, Membership, MembershipMailer}
  alias Ecto.Query
  use Classlab.Web, :controller
  use Classlab.ErrorRescue, from: Ecto.NoResultsError, redirect_to: &page_path(&1, :index)

  def new(conn, %{"invitation_token" => invitation_token}) do
    event = load_event(conn)
    res =
      Invitation
      |> Invitation.for_event(event)
      |> Invitation.not_completed()
      |> Repo.get_by(invitation_token: invitation_token)

    case res do
      %Invitation{} = invitation ->
        invitation = Repo.preload(invitation, [:event, :role])

        render(conn, "new.html", invitation: invitation)
      nil -> handle_error(conn, "Invalid invitation.")
    end
  end

  def create(conn, %{"invitation_token" => invitation_token}) do
    event = load_event(conn)
    invitation_res =
      Invitation
      |> Invitation.for_event(event)
      |> Invitation.not_completed()
      |> Query.preload(:event)
      |> Repo.get_by(invitation_token: invitation_token)

    case invitation_res do
      %Invitation{} = invitation ->
        user = create_user(invitation)
        if invitation_has_membership?(invitation, user) do
          handle_error(conn, "Already accepted the invitation.")
        else
          membership = create_membership(invitation, user)
          send_event_before_email(membership)
          invitation_changeset = Invitation.completion_changeset(invitation, %{
            completed_at: membership.inserted_at
          })
          Repo.update!(invitation_changeset)

          conn =
            conn
            |> Session.logout()
            |> Session.login(user)

          redirect(conn, to: classroom_dashboard_path(conn, :show, event))
        end
      nil -> handle_error(conn, "Invalid invitation.")
    end
  end

  # Private methods
  defp load_event(conn) do
    Repo.get_by!(Event, slug: conn.params["event_id"])
  end

  defp handle_error(conn, flash_message) do
    conn
    |> put_flash(:error, flash_message)
    |> redirect(to: page_path(conn, :index))
  end

  defp create_user(%Invitation{} = invitation) do
    user_res =
      User
      |> Query.where(email: ^invitation.email)
      |> Repo.one()

    case user_res do
      %User{} = user ->
        user
      nil ->
        user_changeset = User.registration_changeset(%User{},
          %{email: invitation.email, first_name: invitation.first_name, last_name: invitation.last_name}
        )
        Repo.insert!(user_changeset)
    end
  end

  defp invitation_has_membership?(invitation, user) do
    membership_res =
      Membership
      |> Membership.for_event(invitation.event)
      |> Query.where(user_id: ^user.id)
      |> Query.where(role_id: ^invitation.role_id)
      |> Repo.one()

    case membership_res do
      %Membership{} = _ -> true
      nil -> false
    end
  end

  defp create_membership(invitation, user) do
    membership_changeset =
      user
      |> build_assoc(:memberships)
      |> Membership.changeset(%{
        event_id: invitation.event.id,
        role_id: invitation.role_id
      })

    Repo.insert!(membership_changeset)
  end

  defp send_event_before_email(%Membership{role_id: 3} = membership) do
    membership
    |> Repo.preload([:user, :event])
    |> MembershipMailer.before_event_email()
    |> Mailer.deliver_now()

    membership |> Membership.touch(:before_email_sent_at) |> Repo.update!()
    %{ok: :sent}
  end
  defp send_event_before_email(%Membership{role_id: _}), do: %{ok: :not_sent}
end
