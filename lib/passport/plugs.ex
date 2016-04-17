defmodule Passport.Plugs do
  @moduledoc """
  The `Passport.Plugs` module is meant to be imported into a Phoenix Router
  module so that its methods can be used as plugs in the router's pipelines.

  ## Example

  ```elixir
  defmodule MyApp.Router do
    use MyApp.Web, :router
    import Passport.Plugs

    pipeline :browser do
      plug :fetch_session

      # Passport.Plugs function
      plug :authenticate_session
    end

    pipeline ::require_auth do
      # Passport.Plugs function
      plug :require_authentication
    end
  end
  ```
  """

  import Plug.Conn

  alias Passport.Authenticate

  @doc """
  Extends a valid authentication session or clears that data.
  """
  def authenticate_session(%Plug.Conn{} = conn, _options) do
    Authenticate.session(conn)
  end

  @doc """
  Redirects to sign in path if the current authentication session isn't valid
  """
  def require_authentication(%Plug.Conn{} = conn, %{} = opts) do
    cond do
      Authenticate.session_valid?(conn) ->
        conn
      redirect_path = Map.get(opts, :redirect_to) ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> put_resp_header("Location", redirect_path)
        |> put_status(302)
        |> halt
      true ->
        conn
        |> put_status(401)
        |> halt
    end
  end
  def require_authentication(conn, _opts), do: require_authentication(conn, %{})
end
