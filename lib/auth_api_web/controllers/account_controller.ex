defmodule AuthApiWeb.AccountController do
  use AuthApiWeb, :controller

  alias AuthApiWeb.Auth.Guardian
  alias AuthApi.{Accounts, Accounts.Account, Users, Users.User}
  alias AuthApiWeb.{Auth.Guardian, Auth.ErrorResponse}

  action_fallback AuthApiWeb.FallbackController
  plug :put_view, json: AuthApiWeb.Json.AccountJSON

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
      {:ok, token, _claims} <- Guardian.encode_and_sign(account),
      {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/accounts/#{account}")
      |> render(:account_token, account: account, token: token)
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Wrong request"})
  end

  def sign_in(conn, %{"email" => email, "hash_password" => password}) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        conn
        |> put_status(:ok)
        |> render(:account_token, account: account, token: token)
      {:error, :unauthorized} -> raise ErrorResponse.Unauthorized, message: "email or password wrong."
    end
  end


  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, :show, account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
