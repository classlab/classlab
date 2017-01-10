defmodule Classlab.MembershipControllerTest do
  alias Classlab.{Invitation, Membership, User, MembershipMailer}
  use Classlab.ConnCase

  describe "#new" do
    test "renders form for new resources", %{conn: conn} do
      invitation = Factory.insert(:invitation)
      conn = get conn, membership_path(conn, :new, invitation.event, invitation.invitation_token)
      assert html_response(conn, 200) =~ membership_path(conn, :create, invitation.event, invitation.invitation_token)
    end

    test "shows error if invalid invitation token", %{conn: conn} do
      invitation = Factory.insert(:invitation)
      conn = get conn, membership_path(conn, :new, invitation.event, "asdf")
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) =~ "Invalid invitation"
    end
  end

  describe "#create" do
    test "creates user, membership, sends before event email, and completes invitation", %{conn: conn} do
      invitation = Factory.insert(:invitation, role_id: 3, first_name: "Martin", last_name: "Schurig")
      conn = post conn, membership_path(conn, :create, invitation.event, invitation.invitation_token)
      assert redirected_to(conn) == classroom_dashboard_path(conn, :show, invitation.event)

      user = Repo.get_by(User, email: invitation.email)
      membership = Membership |> Repo.get_by(user_id: user.id) |> Repo.preload([:event, :user])
      completed_invitation = Repo.get(Invitation, invitation.id)

      assert user
      assert user.email == invitation.email
      assert user.first_name == invitation.first_name
      assert user.last_name == invitation.last_name
      assert membership
      assert membership.role_id == 3
      assert membership.before_email_sent_at
      assert completed_invitation.completed_at
      assert_delivered_email MembershipMailer.before_event_email(membership)
    end

    test "creates membership, sends before event email, and completes invitation", %{conn: conn} do
      user = Factory.insert(:user, first_name: "Martin", last_name: "Schurig")
      invitation = Factory.insert(:invitation, email: user.email, role_id: 3)
      conn = post conn, membership_path(conn, :create, invitation.event, invitation.invitation_token)
      assert redirected_to(conn) == classroom_dashboard_path(conn, :show, invitation.event)

      membership = Membership |> Repo.get_by(user_id: user.id) |> Repo.preload([:event, :user])
      completed_invitation = Repo.get(Invitation, invitation.id)

      assert membership
      assert membership.role_id == 3
      assert completed_invitation.completed_at
      assert_delivered_email MembershipMailer.before_event_email(membership)
    end

    test "does not send before event email if not attendee", %{conn: conn} do
      user = Factory.insert(:user, first_name: "Martin", last_name: "Schurig")
      invitation = Factory.insert(:invitation, email: user.email, role_id: 2)
      conn = post conn, membership_path(conn, :create, invitation.event, invitation.invitation_token)
      assert redirected_to(conn) == classroom_dashboard_path(conn, :show, invitation.event)

      membership = Membership |> Repo.get_by(user_id: user.id) |> Repo.preload([:event, :user])
      refute_delivered_email MembershipMailer.before_event_email(membership)
    end

    test "does not create resource and redirects when membership already exists", %{conn: conn} do
      user = Factory.insert(:user)
      event = Factory.insert(:event)
      Factory.insert(:membership, user: user, event: event, role_id: 3)
      invitation = Factory.insert(:invitation, email: user.email, event: event, role_id: 3)
      conn = post conn, membership_path(conn, :create, invitation.event, invitation.invitation_token)
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) =~ "Already accepted the invitation"
    end

    test "does not create resource and redirects when token is invalid", %{conn: conn} do
      invitation = Factory.insert(:invitation)
      conn = post conn, membership_path(conn, :create, invitation.event, "asdf")
      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :error) =~ "Invalid invitation"
    end
  end
end
