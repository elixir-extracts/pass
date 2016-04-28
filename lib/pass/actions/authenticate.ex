defmodule Pass.Authenticate do
  @moduledoc """
  Implements methods for adding and validating session state for a connection.
  """
  alias Plug.Conn
  alias Pass.Hash

  @config Application.get_env(:pass, __MODULE__, %{})
  @session_ttl @config[:session_ttl] || (60 * 60 * 8)

  @doc """
  Sets up and returns a connection with the session data of a user in the data
  store that matches the provided credentials. If no such match exists, it
  clears out the session.
  """
  def credentials(conn, identity, password) do
    Pass.DataStore.adapter.get_by_identity(identity)
    |> verify_user_credentials(password)
    |> create_session_for(conn)
  end

  @doc """
  Extend valid sessions, or clear out invalid ones.
  """
  def session(conn) do
    conn |> delete_or_extend_session
  end

  @doc """
  Returns true if the session is still valid, otherwise false.
  """
  def session_valid?(conn) do
    @session_ttl >= :os.system_time(:seconds) - (
      Conn.get_session(conn, :session_auth_at)  ||
      Conn.get_session(conn, :password_auth_at) ||
      0
    )
  end

  @doc """
  Clears out the session data. Used when logging out.
  """
  def delete_session(%Conn{} = conn) do
    conn
    |> Conn.put_session(:user_id         , nil)
    |> Conn.put_session(:password_auth_at, nil)
    |> Conn.put_session(:session_auth_at , nil)
  end

  defp verify_user_credentials(nil, _), do: nil
  defp verify_user_credentials(%{password: hash} = user, password) do
    if Hash.verify(password, hash), do: user, else: nil
  end

  defp create_session_for(nil, %Conn{} = conn) do
    delete_session conn
  end
  defp create_session_for(%{id: user_id}, %Conn{} = conn) do
    conn
    |> Conn.put_session(:user_id, user_id)
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
end
