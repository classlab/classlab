defmodule Classlab.Account.MembershipView do
  @moduledoc false
  use Classlab.Web, :view

  # Page Configuration
  def page("index.html", _conn), do: %{
    title: "Events",
    breadcrumb: [%{
      name: "Events"
    }]
  }

  # View functions
end
