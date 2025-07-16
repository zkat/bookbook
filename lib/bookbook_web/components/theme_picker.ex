defmodule BookbookWeb.Components.ThemePicker do
  @moduledoc """
  Progressively-enhanced theme picker.
  """
  use Phoenix.Component
  use BookbookWeb, :html

  use Phoenix.VerifiedRoutes,
    router: BookbookWeb.Router,
    endpoint: BookbookWeb.Endpoint,
    statics: ~w(images)

  @doc """
  Renders the theme picker.
  """
  attr :conn, :any, required: true, doc: "The connection associated with this request."

  def theme_picker(assigns) do
    ~H"""
    <.simple_form class="theme-picker" for={@conn.params} action={~p"/theme"}>
      <input type="hidden" name="redirect_to" value={@conn.request_path} />
      <.button name="theme" value="light" id="theme-picker-light">Light</.button>
      <.button name="theme" value="dark" id="theme-picker-dark">Dark</.button>
      <.button name="theme" value="system" id="theme-picker-system">System</.button>
    </.simple_form>
    """
  end
end
