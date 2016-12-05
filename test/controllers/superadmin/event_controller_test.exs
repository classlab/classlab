defmodule Classlab.Superadmin.EventControllerTest do
  alias Classlab.Event
  use Classlab.ConnCase

  setup %{conn: conn} do
    user = Factory.insert(:user, superadmin: true)
    {:ok, conn: Session.login(conn, user)}
  end

  describe "#index" do
    test "lists all entries on index", %{conn: conn} do
      event = Factory.insert(:event)
      conn = get conn, superadmin_event_path(conn, :index)
      assert html_response(conn, 200) =~ event.name
    end
  end

  describe "#show" do
    test "shows chosen resource", %{conn: conn} do
      event = Factory.insert(:event)
      conn = get conn, superadmin_event_path(conn, :show, event)
      assert html_response(conn, 200) =~ event.name
    end

    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, superadmin_event_path(conn, :show, -1)
      end
    end
  end

  describe "#delete" do
    test "deletes chosen resource", %{conn: conn} do
      event = Factory.insert(:event)
      conn = delete conn, superadmin_event_path(conn, :delete, event)
      assert redirected_to(conn) == superadmin_event_path(conn, :index)
      refute Repo.get(Event, event.id)
    end
  end
end
