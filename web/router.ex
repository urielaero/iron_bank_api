defmodule IronBank.Router do
  use IronBank.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IronBank do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api/v1", IronBank do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]

    resources "/cards", CardController, except: [:new, :edit]

    resources "/banks", BankController, except: [:new, :edit]

  end

  # Other scopes may use custom stacks.
  # scope "/api", IronBank do
  #   pipe_through :api
  # end
end
