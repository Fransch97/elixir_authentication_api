defmodule AuthApiWeb.AccountController do
  use AuthApiWeb, :controller

  alias AuthApiWeb.Auth.Guardian
  alias AuthApi.{Accounts, Accounts.Account, Users, Users.User}
  alias AuthApiWeb.{Auth.Guardian, Auth.ErrorResponse}

  action_fallback AuthApiWeb.FallbackController
  plug :put_view, json: AuthApiWeb.Json.AccountJSON
  plug :is_authorized_account when action in [:update, :delete]

  defp is_authorized_account(conn, _opts) do
    %{params: %{"account" => params}} = conn
    IO.inspect(params)
    account = Accounts.get_account!(params["id"])
    if conn.assigns.account.id == account.id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
      {:ok, %User{} = _user} <- Users.create_user(account, account_params)
    do
      authorize_account(conn, account.email, account_params["hash_password"])
    end
  end

  def sign_in(conn, %{"email" => email, "hash_password" => password}) do
    authorize_account(conn, email, password)
  end

  defp authorize_account(conn, email, password) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:account_token, account: account, token: token)
      {:error, :unauthorized} -> raise ErrorResponse.Unauthorized, message: "email or password wrong."
    end
  end

  def sign_out(conn, %{}) do
    account = conn.assigns[:account]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> Plug.Conn.clear_session()
    |> put_status(:ok)
    |> render(:account_token, account: account, token: nil)
  end

  def refresh_session(conn, %{}) do
    token = Guardian.Plug.current_token(conn)
    {:ok, account, new_token} = Guardian.authenticate(token)
    conn
    |> Plug.Conn.put_session(:account_id, account.id)
    |> put_status(:ok)
    |> render(:account_token, account: account, token: new_token)
  end

  def show(conn, _shit) do
    render(conn, :show, account: conn.assigns.account)
  end

  def update(conn, %{"account" => account_params}) do
    account = Accounts.get_account!(account_params["id"])

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"account" => account_params}) do
    account = Accounts.get_account!(account_params["id"])

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
