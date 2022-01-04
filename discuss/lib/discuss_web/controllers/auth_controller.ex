defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  alias Discuss.User
  alias Discuss.Repo
  plug Ueberauth

  def callback(%{assigns: assigns} = conn, %{"provider" => provider}) do
    case assigns do
      %{ueberauth_auth: %{credentials: %{token: token}, info: %{email: email}}} ->
        case insert_or_update_user(%{email: email, token: token, provider: provider}) do
          {:ok, user} -> signin(conn, user)
          {:error, _changeset} -> error(conn)
        end

      %{ueberauth_failure: _failure} ->
        error(conn)
    end
  end

  defp signin(conn, user) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> put_session(:user_id, user.id)
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  defp error(conn) do
    conn
    |> put_flash(:error, "Error signing in")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  defp insert_or_update_user(%{email: email} = params) do
    case Repo.get_by(User, email: email) do
      nil ->
        Repo.insert(User.changeset(%User{}, params))

      user ->
        Repo.update(User.changeset(user, params))
    end
  end
end
