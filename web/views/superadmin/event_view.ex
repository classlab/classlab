defmodule Classlab.Superadmin.EventView do
  @moduledoc false
  use Classlab.Web, :view

  # Page Configuration
  def page("index.html", _conn), do: %{
    title: "events"
  }
  def page("show.html", conn), do: %{
    title: "event #{conn.assigns.event.name}"
  }

  # View functions
end
