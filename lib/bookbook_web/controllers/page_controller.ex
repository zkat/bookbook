defmodule BookbookWeb.PageController do
  use BookbookWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def dashboard(conn, _params) do
    render(conn, :dashboard)
  end
end
