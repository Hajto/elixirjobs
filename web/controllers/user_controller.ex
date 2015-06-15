defmodule ElixirJobs.UserController do
  use ElixirJobs.Web, :controller

  alias Exrethinkdb.Query
  alias ElixirJobs.Repo

  plug :attach_sessions
  plug :authenticate when action in [:new_profile, :edit_profile]
  plug :action

  def login(conn, _params) do

    render conn, "login.html"
  end

  def create(conn, params) do

    hash_password = Comeonin.Bcrypt.hashpwsalt(params["password"])

    user = %{
      email: params["email"],
      password: hash_password

      }

    q = Query.table("users")
    |> Query.insert(user)
    Repo.run(q)

    conn
    |> put_flash(:info, "Super! Your account created.")
    |> redirect to: "/"
  end

  def process_login(conn, params) do
    if is_nil(do_login(params["email"], params["password"])) do
      conn
      |> put_flash(:error, "Login failed") |> redirect(to: "/users/login") |> halt
    else
      conn = put_session(conn, :user, params["email"])
      conn
        |> put_flash(:info, "Thanks for logging in!") |> redirect(to: "/")
    end
  end

  def do_login(email, password) do
    q = Query.table("users")
    |> Query.filter(%{email: email})

    user = Repo.run(q).data |> List.first

    if Comeonin.Bcrypt.checkpw(password, user["password"]) do
      user
    else
      nil
    end


  end

  def logout(conn, _params) do
    conn = delete_session(conn, :user)
    conn |> put_flash(:info, "You're logged out!") |> redirect(to: "/")
  end

  def new_profile(conn, _params) do
    render conn, "new_profile.html"
  end

  def create_profile(conn, params) do
    array_of_interest = []

    if params["fulltime"] == "on" do
      array_of_interest = List.insert_at(array_of_interest, -1, "fulltime")
    end

    if params["hourly"] == "on" do
      array_of_interest = List.insert_at(array_of_interest, -1, "hourly")
    end

    if params["term"] == "on" do
      array_of_interest = List.insert_at(array_of_interest, -1, "term")
    end

    if params["mentoring"] == "on" do
      array_of_interest = List.insert_at(array_of_interest, -1, "mentoring")
    end

    if params["volunteer"] == "on" do
      array_of_interest = List.insert_at(array_of_interest, -1, "volunteer")
    end

    if params["other"] == "on" do
      array_of_interest = List.insert_at(array_of_interest, -1, "other")
    end


    interest = Query.make_array(array_of_interest)

    dev = %{
      name: params["name"],
      short_desc: params["short_desc"],
      description: params["description"],
      picture_url: params["picture_url"],
      interest: interest,
      location: params["location"],
      website: params["website"],
      resume_url: params["resume_url"],
      github_url: params["github_url"],
      linkedin_url: params["linkedin_url"],
      email: get_session(conn, :user)
      }


    q = Query.table("devs")
      |> Query.insert(dev)

    Repo.run(q)


    conn
    |> put_flash(:info, "Super! Your profile added.")
    |> redirect to: "/"

  end

  def edit_profile(conn, _params) do
    q = Query.table("devs")
      |> Query.filter(%{email: get_session(conn, :user)})

    profile = Repo.run(q).data |> List.first
    IO.inspect profile

    conn
      |> assign(:profile, profile)
      |> render "edit_profile.html"

  end


  # Private Room
  defp authenticate(conn, _params) do
    if is_nil(get_session(conn, :user)) do
        conn |> put_flash(:error, "You need to login first") |> redirect(to: "/users/login") |> halt
    else
      conn
    end
  end

  defp attach_sessions(conn, _params) do
    conn |> assign(:user, get_session(conn, :user))
  end

end
