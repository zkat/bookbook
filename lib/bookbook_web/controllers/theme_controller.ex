defmodule BookbookWeb.ThemeController do
  @moduledoc """
  Controller for the /theme endpoint
  Changes user theme via cookie
  """
  use BookbookWeb, :controller

  def update(conn, params) do
    redirect_to = case params["redirect_to"] do
      path = "/" <> _ -> path
      _ -> "/"
    end

    conn
    |> put_resp_cookie("theme", params["theme"], http_only: false)
    |> redirect(to: redirect_to)
  end
end
