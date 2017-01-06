defmodule Classlab.MembershipMailer do
  @moduledoc """
  Sends out emails when the membership to an event is created and
  when the event ended.

  Also replaces the placeholders with real information.
  """
  alias Classlab.{Endpoint, Mailer, Membership, Event}
  use Classlab.Web, :mailer

  def before_event_email(%Membership{user: user, event: event} = membership) do
    new_email()
    |> to(user.email)
    |> from({Application.get_env(:classlab, Mailer)[:from_name], Application.get_env(:classlab, Mailer)[:from_email]})
    |> subject(resolve_variables(Event.before_email_subject(event), membership))
    |> text_body(resolve_variables(Event.before_email_body_text(event), membership))
  end

  def after_event_email(%Membership{user: user, event: event} = membership) do
    new_email()
    |> to(user.email)
    |> from({Application.get_env(:classlab, Mailer)[:from_name], Application.get_env(:classlab, Mailer)[:from_email]})
    |> subject(resolve_variables(Event.after_email_subject(event), membership))
    |> text_body(resolve_variables(Event.after_email_body_text(event), membership))
  end

  # Private methods
  defp resolve_variables(text, %Membership{user: user, event: event}) do
    classroom_link = classroom_dashboard_url(Endpoint, :show, event.slug)

    text
    |> String.replace("{{attendee_first_name}}", user.first_name || "")
    |> String.replace("{{attendee_last_name}}", user.last_name || "")
    |> String.replace("{{event_name}}", event.name)
    |> String.replace("{{classroom_link}}", classroom_link)
  end
end
