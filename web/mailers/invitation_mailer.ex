defmodule Classlab.InvitationMailer do
  @moduledoc """
  Invitation mailer. Sends out emails when inviting new people to an event.
  """
  alias Classlab.{Endpoint, Mailer, Invitation}
  use Classlab.Web, :mailer

  def invitation_email(%Invitation{invitation_token: invitation_token, email: email, first_name: _first_name, last_name: _last_name, event: event}) do
    invite_url = membership_url(Endpoint, :new, event.slug, invitation_token)

    new_email()
    |> to(email)
    |> from({Application.get_env(:classlab, Mailer)[:from_name], Application.get_env(:classlab, Mailer)[:from_email]})
    |> subject("Invitation to event #{event.name} #{invite_url}")
    |> html_body("Invitation to event #{event.name} <a href=\"#{invite_url}\" target=\"_blank\">#{invite_url}</a>")
  end
end
