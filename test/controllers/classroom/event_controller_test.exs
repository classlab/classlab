defmodule Classlab.Classroom.EventControllerTest do
  alias Classlab.Event
  use Classlab.ConnCase

  @valid_attrs Factory.params_for(:event) |> Map.take(~w[name description starts_at ends_at timezone]a)
  @invalid_attrs %{name: ""}
  @form_field "event_name"

  setup %{conn: conn} do
    user = Factory.insert(:user)
    event = Factory.insert(:event)
    Factory.insert(:membership, event: event, user: user, role_id: 1)
    {:ok, conn: Session.login(conn, user), event: event}
  end

  describe "#edit" do
    test "renders form for editing chosen resource", %{conn: conn, event: event} do
      conn = get conn, classroom_event_path(conn, :edit, event)
      assert html_response(conn, 200) =~ @form_field
    end
  end

  describe "#update" do
    test "updates chosen resource and redirects when data is valid", %{conn: conn, event: event} do
      conn = put conn, classroom_event_path(conn, :update, event), event: @valid_attrs
      event = Repo.get_by(Event, @valid_attrs)
      assert redirected_to(conn) == classroom_event_path(conn, :edit, event)
      assert event
    end

    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put conn, classroom_event_path(conn, :update, event), event: @invalid_attrs
      assert html_response(conn, 200) =~ @form_field
    end
  end

  describe "#delete" do
    test "deletes chosen resource", %{conn: conn, event: event} do
      conn = delete conn, classroom_event_path(conn, :delete, event)
      assert redirected_to(conn) == account_event_path(conn, :index)
      refute Repo.get(Event, event.id)
    end

    test "not deletes chosen resource if not owner", %{conn: conn, event: event} do
      user = Factory.insert(:user)
      Factory.insert(:membership, event: event, user: user, role_id: 2)

      conn =
        conn
        |> Session.login(user)
        |> delete(classroom_event_path(conn, :delete, event))

      assert redirected_to(conn) == page_path(conn, :index)
      assert Repo.get(Event, event.id)
    end
  end
end
