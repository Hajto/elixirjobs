defmodule ElixirJobs.Router do
  use ElixirJobs.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirJobs do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/job/:id", PageController, :show
    # resources "/", PageController

    get "/dev/:id", DevController, :show

  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirJobs do
  #   pipe_through :api
  # end
end
