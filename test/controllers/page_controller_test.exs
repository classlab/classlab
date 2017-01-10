defmodule Classlab.PageControllerTest do
  use Classlab.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Classlab"
  end
end
