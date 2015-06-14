defmodule ElixirJobs.UserController do
  use ElixirJobs.Web, :controller

  alias Exrethinkdb.Query
  alias ElixirJobs.Repo

  plug :attach_sessions
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
