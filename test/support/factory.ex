defmodule Classlab.Factory do
  alias Calecto.DateTimeUTC
  use ExMachina.Ecto, repo: Classlab.Repo

  def chat_message_factory do
    %Classlab.ChatMessage{
      body: "A new chat message",
      event: build(:event),
      user: build(:user)
    }
  end

  def event_factory do
    %Classlab.Event{
      name: sequence(:name, &"My Event #{&1}"),
      slug: sequence(:slug, &"event-#{&1}"),
      description_markdown: "My awesome event!",
      invitation_token: sequence(:invitation_token, &"inivitation-token-#{&1}"),
      invitation_token_active: false,
      starts_at: DateTimeUTC.cast!("2001-07-29T01:02:03"),
      ends_at: DateTimeUTC.cast!("2001-07-29T01:02:03"),
      timezone: "Europe/Berlin"
    }
  end

  def event_copy_factory do
     %Classlab.EventCopy{
       name: "Workshop",
       copy_tasks: false,
       copy_materials: false
     }
  end

  def feedback_factory do
    %Classlab.Feedback{
      content_rating: 4,
      content_comment: "Awesome content",
      trainer_rating: 5,
      location_rating: 5,
      testimonial: "Awesome, very very great job!",
      user: build(:user),
      event: build(:event)
    }
  end

  def invitation_factory do
    %Classlab.Invitation{
      email: sequence(:email, &"john-#{&1}@example.com"),
      invitation_token: sequence(:invitation_token, &"inivitation-token-#{&1}"),
      event: build(:event),
      role_id: 1,
    }
  end

  def location_factory do
    %Classlab.Location{
      name: "Meet and Greet with Sascha and Martin",
      address_line_1: "Kopstadtplatz 24/25",
      city: "Essen",
      zipcode: "45127",
      country: "Germany"
    }
  end

  def membership_factory do
    %Classlab.Membership{
      user: build(:user),
      event: build(:event),
      role_id: 1,
    }
  end

  def role_factory do
    %Classlab.Role{
      name: sequence(:name, &"Role #{&1}"),
    }
  end

  def session_factory do
    %Classlab.Session{
      email: sequence(:email, &"john-#{&1}@example.com")
    }
  end

  def material_factory do
    %Classlab.Material{
      event: build(:event),
      type: 1,
      description_markdown: "This is a material element.",
      position: 1,
      title: sequence(:title, &"Material-#{&1}"),
      url: "http://example.com"
    }
  end

  def task_factory do
    %Classlab.Task{
      event: build(:event),
      body_markdown: "This is a task.",
      position: 1,
      title: sequence(:title, &"Task-#{&1}")
    }
  end

  def user_factory do
    %Classlab.User{
      first_name: "John",
      last_name: "Doe",
      email: sequence(:email, &"john-#{&1}@example.com"),
      access_token: sequence(:access_token, &"access-token-#{&1}"),
      access_token_expired_at: DateTimeUTC.cast!("2001-07-29T01:02:03"),
      superadmin: false
    }
  end
end
