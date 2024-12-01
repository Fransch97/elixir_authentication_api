defmodule AuthApiWeb.DefaultController do
  use AuthApiWeb, :controller

  def index(conn, _params) do
    text conn, "The Auth API is LIVE - #{Mix.env()}"
  end
end
