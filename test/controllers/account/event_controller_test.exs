defmodule Classlab.Account.EventControllerTest do
  alias Classlab.Event
  use Classlab.ConnCase

  @valid_attrs Factory.params_for(:event) |> Map.take(~w[name description_markdown starts_at ends_at timezone]a)

  @invalid_attrs %{name: ""}
  @form_field "event_name"

  setup %{conn: conn} do
    user = Factory.insert(:user)
    {:ok, conn: Session.login(conn, user)}
  end

  describe "#new" do
    test "renders form for new resources", %{conn: conn} do
      conn = get conn, account_event_path(conn, :new)
      assert html_response(conn, 200) =~ @form_field
    end
  end

  describe "#create" do
    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post conn, account_event_path(conn, :create), event: Map.put(@valid_attrs, :location, Factory.params_for(:location))
      event = Repo.get_by(Event, @valid_attrs)
      assert event
      assert redirected_to(conn) == classroom_dashboard_path(conn, :show, event)
    end

    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, account_event_path(conn, :create), event: @invalid_attrs
      assert html_response(conn, 200) =~ @form_field
    end
  end
end
