defmodule AuthApiWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :auth_api,
  module: AuthApiWeb.Auth.Guardian,
  error_handler: AuthApiWeb.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
