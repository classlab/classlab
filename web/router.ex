defmodule Classlab.Router do
  use Classlab.Web, :router
  import Classlab.PermissionPlug

  if Mix.env in [:dev, :demo] do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Classlab.AssignUserPlug
  end

  scope "/", Classlab do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/session/:id", SessionController, :show
    delete "/logout", SessionController, :delete

    resources "/events", EventController, only: [:index, :show] do
      get "/invitation", InvitationController, :new
      post "/invitation", InvitationController, :create
      pipe_through [:as_user]
      post "/memberships", MembershipController, :create
    end

    get "/membership/:event_id/:invitation_token/complete", MembershipController, :show
    get "/membership/:event_id/:invitation_token", MembershipController, :new
    post "/membership/:event_id/:invitation_token", MembershipController, :create
    get "/membership/:event_id/:invitation_token/complete", MembershipController, :show
  end

  #############################################################################
  ### Account
  #############################################################################
  pipeline :account do
    plug :put_layout, {Classlab.LayoutView, :account}
    plug :as_user
  end

  pipeline :event_copy do
    plug Classlab.AssignEventPlug, "event_id"
  end

  scope "/account", Classlab.Account, as: :account do
    pipe_through [:browser, :account]
    resources "/", DashboardController, only: [:show], singleton: true
    resources "/events", EventController, only: [:index, :new, :create] do
      pipe_through [:event_copy]
      resources "/copy", EventCopyController, only: [:new, :create], singleton: true
    end
    resources "/feedbacks", FeedbackController, only: [:index]
    resources "/invitations", InvitationController, only: [:index, :update, :delete]
    resources "/memberships", MembershipController, only: [:index, :delete]
    resources "/user", UserController, only: [:edit, :update], singleton: true
  end

  #############################################################################
  ### Classroom
  #############################################################################
  pipeline :classroom do
    plug :put_layout, {Classlab.LayoutView, :classroom}
    plug Classlab.AssignEventPlug, "event_id"
    plug Classlab.AssignMembershipsPlug
    plug :as_user # user needs to be authenticated
    plug :restrict_roles, [1, 2, 3] # user needs a membership to access classroom
  end

  scope "/classroom/:event_id", Classlab.Classroom, as: :classroom do
    pipe_through [:browser, :classroom] # Use the default browser stack
    resources "/", DashboardController, only: [:show], singleton: true
    resources "/chat_messages", ChatMessageController, except: [:show]
    resources "/feedbacks", FeedbackController, only: [:index]
    resources "/feedback", FeedbackController, except: [:index], singleton: true
    resources "/invitations", InvitationController, only: [:create, :delete, :new, :update]
    resources "/memberships", MembershipController, only: [:index, :delete, :update]
    resources "/event", EventController, only: [:edit, :update, :delete], singleton: true
    resources "/event_email_templates", EventEmailTemplateController, only: [:edit, :update], singleton: true
    post "/event_email_templates/send_test_email", EventEmailTemplateController, :send_test_email
    resources "/materials", MaterialController
    post "/materials/lock_all", MaterialController, :lock_all
    post "/materials/unlock_all", MaterialController, :unlock_all
    post "/materials/:id/toggle", MaterialController, :toggle_lock
    resources "/tasks", TaskController
    post "/tasks/unlock_all", TaskController, :unlock_all
    post "/tasks/lock_all", TaskController, :lock_all
    post "/tasks/:id/unlock_next", TaskController, :unlock_next
    post "/tasks/:id/toggle", TaskController, :toggle_lock
  end

  #############################################################################
  ### Superadmin
  #############################################################################
  pipeline :superadmin do
    plug :put_layout, {Classlab.LayoutView, :superadmin}
    plug :as_superadmin
  end

  scope "/superadmin", Classlab.Superadmin, as: :superadmin do
    pipe_through [:browser, :superadmin] # Use the default browser stack
    resources "/", DashboardController, only: [:show], singleton: true
    resources "/users", UserController
    resources "/events", EventController
  end
end
