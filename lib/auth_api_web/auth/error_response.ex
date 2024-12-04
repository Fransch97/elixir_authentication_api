defmodule AuthApiWeb.Auth.ErrorResponse.Unauthorized do
  defexception [message: "Unauthorized", plug_status: 401]
end

defmodule AuthApiWeb.Auth.ErrorResponse.Forbidden do
  defexception [message: "No permissions for this action", plug_status: 403]
end
