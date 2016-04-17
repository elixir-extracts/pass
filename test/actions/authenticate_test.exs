defmodule Passport.AuthenticateTest do
	use ExUnit.Case, async: false
  use Plug.Test

  alias Passport.Authenticate
  alias Passport.Test.Repo
  alias Passport.Test.User

  @db_user_password "Password12345"

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Repo, [])
    end
    db_user = Repo.insert! %User{
      username: "ft",
      email: "frank@thomases.com",
      password: Passport.Hash.db_password(@db_user_password)
    }
    {:ok, %{db_user: db_user}}
  end

  def with_session(conn) do
    session_opts = Plug.Session.init(store: :cookie, key: "_app",
                                     encryption_salt: "abc", signing_salt: "abc")
    conn
    |> Map.put(:secret_key_base, String.duplicate("a2c4e6g8", 4))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session
  end

  test "credentials/3 with correct credentials sets session user_id and password_auth_at", %{db_user: db_user} do
    conn = conn(:get, "/")
    |> with_session
    |> Authenticate.credentials(db_user.username, @db_user_password)

    assert get_session(conn, :user_id) == db_user.id
    assert (:os.system_time(:seconds) - get_session(conn, :password_auth_at)) < 4
  end

  test "credentials/3 when the specified username can't be found doesn't set session user_id or password_auth_at" do
    conn = conn(:get, "/")
    |> with_session
    |> Authenticate.credentials("noexist", "foo")

    assert get_session(conn, :user_id) == nil
    assert get_session(conn, :password_auth_at) == nil
  end

  test "credentials/3 when the specified password doesn't match doesn't set session user_id or password_auth_at", %{db_user: db_user} do
    conn = conn(:get, "/")
    |> with_session
    |> Authenticate.credentials(db_user.username, "bad")

    assert get_session(conn, :user_id) == nil
    assert get_session(conn, :password_auth_at) == nil
  end

  test "credentials/3 when session data is set and new valid credentials are passed it replaces the session", %{db_user: db_user} do
    conn = conn(:get, "/")
    |> with_session
    |> put_session(:user_id, 42)
    |> put_session(:password_auth_at, :os.system_time(:seconds) - 100)
    |> put_session(:session_auth_at , :os.system_time(:seconds))
    |> Authenticate.credentials(db_user.username, @db_user_password)

    assert get_session(conn, :user_id) == db_user.id
    assert (:os.system_time(:seconds) - get_session(conn, :password_auth_at)) < 4
    assert get_session(conn, :session_auth_at) == nil
  end

  test "credentials/3 when session data is set and the specified username can't be found it clears the session" do
    conn = conn(:get, "/")
    |> with_session
    |> put_session(:user_id, 42)
    |> put_session(:password_auth_at, 1234)
    |> Authenticate.credentials("noexist", "foo")

    assert get_session(conn, :user_id) == nil
    assert get_session(conn, :password_auth_at) == nil
  end

  test "credentials/3 when session data is set and the specified password doesn't match it clears the session", %{db_user: db_user} do
    conn = conn(:get, "/")
    |> with_session
    |> put_session(:user_id, 42)
    |> put_session(:password_auth_at, 1234)
    |> Authenticate.credentials(db_user.username, "bad")

    assert get_session(conn, :user_id) == nil
    assert get_session(conn, :password_auth_at) == nil
  end


  def with_authenticated_session(conn, user_id) do
    conn
    |> with_session
    |> put_session(:user_id, user_id)
    |> put_session(:password_auth_at, :os.system_time(:seconds) - 100)
    |> put_session(:session_auth_at , :os.system_time(:seconds) -  50)
  end

  test "session/1 when session data isn't already set it doesn't set any session data" do
    conn = conn(:get, "/")
    |> with_session
    |> Authenticate.session

    assert get_session(conn, :user_id         ) == nil
    assert get_session(conn, :password_auth_at) == nil
    assert get_session(conn, :session_auth_at ) == nil
  end

  test "session/1 when a session has expired it clears out the session data" do
    conn = conn(:get, "/")
    |> with_authenticated_session(42)
    |> put_session(:session_auth_at, -1)
    |> Authenticate.session

    assert get_session(conn, :user_id         ) == nil
    assert get_session(conn, :password_auth_at) == nil
    assert get_session(conn, :session_auth_at ) == nil
  end

  test "session/1 when a session is still valid it bumps session_auth_at to now in UTC", %{db_user: db_user} do
    conn = conn(:get, "/")
    |> with_authenticated_session(db_user.id)
    |> Authenticate.session

    assert get_session(conn, :user_id) == db_user.id
    assert (:os.system_time(:seconds) - get_session(conn, :session_auth_at)) < 4
  end
end
