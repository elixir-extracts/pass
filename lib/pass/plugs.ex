defmodule Pass.Plugs do
  @moduledoc """
  The `Pass.Plugs` module is meant to be imported into a Phoenix Router
  module so that its methods can be used as plugs in the router's pipelines.

  ## Example

  ```elixir
  defmodule MyApp.Router do
    use MyApp.Web, :router
    import Pass.Plugs

    pipeline :browser do
      plug :fetch_session

      # Pass.Plugs function
      plug :authenticate_session
    end

    pipeline ::require_auth do
      # Pass.Plugs function
      plug :require_authentication, redirect_to: "/login"
    end
  end
  ```
  """

  import Plug.Conn

  alias Pass.Authenticate

  @doc """
  Extends a valid authentication session or clears that data.
  """
  def authenticate_session(%Plug.Conn{} = conn, _ops) do
    Authenticate.session(conn)
  end

  @doc """
  Ensures the current session is valid. If not, returns a 401 or redirects to
  the path specfied to by the `:redirect_to` option.

  If the session is valid, the current user will be retrieved and stored in the
  connection struct. If this is not desirable, the `:skip_user_lookup` option
  can be set to `true`. BE CAREFUL when doing this as then it doesn't ensure
  that the user hasn't been deleted
  """
  def require_authentication(%Plug.Conn{} = conn, %{} = opts) do
    user = nil
    cond do
      Authenticate.session_valid?(conn) &&
      (opts[:skip_user_lookup] || (user = Pass.DataStore.adapter.get(get_session(conn, :user_id))) != nil) ->
        assign(conn, :current_user, user)
      redirect_path = Map.get(opts, :redirect_to) ->
        conn
        |> put_session(:redirect_url, conn.request_path)
        |> put_resp_header("location", redirect_path)
        |> send_resp(302, "")
        |> halt
      true ->
        conn
        |> set_content_type(opts[:content_type])
        |> send_resp(401, Map.get(opts, :body, ""))
        |> halt
    end
  end
  def require_authentication(conn, _opts), do: require_authentication(conn, %{})

  defp set_content_type(conn, nil), do: conn
  defp set_content_type(conn, value) when is_binary(value) do
    put_resp_header(conn, "Content-Type", value)
  end
end
