defmodule Classlab.SessionControllerTest do
  alias Classlab.User
  use Classlab.ConnCase

  @valid_attrs Factory.params_for(:session)
  @invalid_attrs %{email: ""}
  @form_field "email"

  test "#new renders form for new resources", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ @form_field
  end

  describe "#show" do
    test "VALID TOKEN +++++++++ change me +++++++++++", %{conn: conn} do
      access_token_expired_at = Calendar.DateTime.add!(Calendar.DateTime.now_utc, 60 * 15)
      user = Factory.insert(:user, access_token_expired_at: access_token_expired_at)
      conn = get conn, session_path(conn, :show, user.access_token)
      assert html_response(conn, 200) =~ @form_field
    end

    test "EXPIRED TOKEN redirects to new session page", %{conn: conn} do
      access_token_expired_at = Calendar.DateTime.add!(Calendar.DateTime.now_utc, -60)
      user = Factory.insert(:user, access_token_expired_at: access_token_expired_at)
      conn = get conn, session_path(conn, :show, user.access_token)
      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "INVALID TOKEN redirects to new session page", %{conn: conn} do
      conn = get conn, session_path(conn, :show, "invalid")
      assert redirected_to(conn) == session_path(conn, :new)
    end
  end

  test "#create creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)

    user = Repo.one(User)
    assert user
    assert_delivered_email Classlab.UserMailer.token_email(user)
  end

  test "#create does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert html_response(conn, 200) =~ @form_field
  end
end