defmodule Classlab.UserMailer do
  alias Classlab.{Endpoint, User}
  use Classlab.Web, :mailer

  def token_email(%User{email: email, access_token: access_token}) do
    login_url = session_url(Endpoint, :show, access_token)

    new_email
    |> to(email)
    |> from("me@example.com")
    |> subject("Your access token")
    |> html_body("Token: <a href=\"#{login_url}\" target=\"_blank\">#{login_url}</a>")
    |> text_body("Token: #{login_url}")
  end
end
