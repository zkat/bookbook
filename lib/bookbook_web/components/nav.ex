defmodule BookbookWeb.Components.Nav do
  @moduledoc """
  Main site nav component.
  """
  use Phoenix.Component
  use Gettext, backend: BookbookWeb.Gettext

  use Phoenix.VerifiedRoutes,
    router: BookbookWeb.Router,
    endpoint: BookbookWeb.Endpoint,
    statics: ~w(images)

  @doc """
  Renders the main nav bar.
  """
  attr :current_user, :any, default: nil

  def nav(assigns) do
    ~H"""
    <nav class="main-nav">
      <ul class="menu">
        <li>
          <a href={~p"/"}>{gettext("Go Somewhere!")}</a>
        </li>
        <%= if @current_user do %>
          <li>
            {@current_user.email}
          </li>
          <li>
            <a href={~p"/users/settings"}>
              {gettext("Settings")}
            </a>
          </li>
          <li>
            <a href={~p"/users/log_out"} method="delete">
              {gettext("Log out")}
            </a>
          </li>
        <% else %>
          <li>
            <a href={~p"/users/register"}>
              {gettext("Register")}
            </a>
          </li>
          <li>
            <a href={~p"/users/log_in"}>
              {gettext("Log in")}
            </a>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
