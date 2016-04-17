defmodule Passport.Authenticate do
  alias Plug.Conn
  alias Passport.Hash
  alias Passport.Test.Repo
  alias Passport.Test.User

  @config Application.get_env(:passport, __MODULE__, %{})
  @session_ttl @config[:session_ttl] || (60 * 60 * 2)

  def credentials(conn, username, password) do
    Repo.get_by(User, username: username)
    |> verify_user_credentials(password)
    |> create_session_for(conn)
  end

  def session(conn) do
    conn |> delete_or_extend_session
  end

  def session_valid?(conn) do
    @session_ttl >= :os.system_time(:seconds) - (
      Conn.get_session(conn, :session_auth_at)  ||
      Conn.get_session(conn, :password_auth_at) ||
      0
    )
  end

  defp verify_user_credentials(nil, _), do: nil
  defp verify_user_credentials(%User{} = user, password) do
    if Hash.verify(password, user.password), do: user, else: nil
  end

  defp create_session_for(nil, %Conn{} = conn) do
    delete_session conn
  end
  defp create_session_for(%User{} = user, %Conn{} = conn) do
    conn
    |> Conn.put_session(:user_id, user.id)
    |> Conn.put_session(:password_auth_at, :os.system_time(:seconds))
    |> Conn.put_session(:session_auth_at, nil)
  end

  defp delete_or_extend_session(%Conn{} = conn) do
    if session_valid?(conn),
      do: extend_session(conn),
      else: delete_session(conn)
  end

  defp extend_session(%Conn{} = conn) do
    conn |> Conn.put_session(:session_auth_at, :os.system_time(:seconds))
  end

  defp delete_session(%Conn{} = conn) do
    conn
    |> Conn.put_session(:user_id         , nil)
    |> Conn.put_session(:password_auth_at, nil)
    |> Conn.put_session(:session_auth_at , nil)
  end
end
