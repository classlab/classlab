defmodule Classlab.Classroom.FeedbackView do
  @moduledoc false
  use Classlab.Web, :view
  import Classlab.StarHelpers

  # Page Configuration
  def page("index.html", _conn), do: %{
    title: "Feedbacks"
  }

  def page("show.html", _conn), do: %{
    title: "Feedback"
  }
  def page("new.html", _conn), do: %{
    title: "New feedback"
  }
  def page("edit.html", _conn), do: %{
    title: "Edit feedback"
  }

  # View functions
end
