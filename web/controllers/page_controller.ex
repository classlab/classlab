defmodule Classlab.PageController do
  @moduledoc false
  use Classlab.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
