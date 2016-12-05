defmodule Classlab.PageControllerTest do
  use Classlab.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Classlab"
  end

  test "shows next public events and if attending", %{conn: conn} do
    now = Calendar.DateTime.now_utc();
    event = Factory.insert(:event, public: true, starts_at: Calendar.DateTime.add!(now, 20000), ends_at: Calendar.DateTime.add!(now, 123000))
    user = Factory.insert(:user)
    Factory.insert(:membership, user: user, event: event)
    conn = Session.login(conn, user)

    conn = get conn, "/"
    assert html_response(conn, 200) =~ event.name
    assert html_response(conn, 200) =~ "attending"
  end
end
