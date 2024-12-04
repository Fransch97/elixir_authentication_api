defmodule AuthApiWeb.Auth.SetAccount do
  import Plug.Conn
  alias AuthApi.Accounts
  alias AuthApiWeb.Auth.ErrorResponse

  def init(_opts) do

  end

  def call(conn, _opts) do
    if conn.assigns[:account] do
      conn
    else
      account_id = get_session(conn, :account_id)

      if account_id == nil, do: raise ErrorResponse.Unauthorized

      account = Accounts.get_account!(account_id)
      cond do
        account_id && account -> assign(conn, :account, account)
        true -> assign(conn, :account, nil)

      end
    end
  end
end
