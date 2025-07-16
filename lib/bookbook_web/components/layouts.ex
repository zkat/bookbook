defmodule BookbookWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use BookbookWeb, :controller` and
  `use BookbookWeb, :live_view`.
  """
  use BookbookWeb, :html
  import BookbookWeb.Components.Nav
  import BookbookWeb.Components.ThemePicker

  embed_templates "layouts/*"
end
