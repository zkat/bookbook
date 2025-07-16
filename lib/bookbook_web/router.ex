defmodule BookbookWeb.Router do
  use BookbookWeb, :router

  import BookbookWeb.UserAuth

  @host Application.compile_env!(:bookbook, [BookbookWeb.Endpoint, :url, :host])

  @enable_ssr Application.compile_env!(:bookbook, [Bookbook.LitSSRWorker, :enable_ssr])

  @content_security_policy (case Application.compile_env!(:bookbook, :env) do
                              :prod ->
                                "default-src 'self' 'unsafe-eval' 'unsafe-inline';" <>
                                  "child-src 'self';" <>
                                  "connect-src wss://#{@host} https://#{@host} blob:;" <>
                                  "img-src 'self' blob: data:;" <>
                                  "font-src data:;"

                              _ ->
                                "default-src 'self' 'unsafe-eval' 'unsafe-inline';" <>
                                  "child-src 'self';" <>
                                  "connect-src ws://#{@host}:* http://#{@host}:* blob:;" <>
                                  "img-src 'self' blob: data:;" <>
                                  "font-src data:;"
                            end)

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BookbookWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" => @content_security_policy
    }

    plug :fetch_current_user
    plug :put_current_route
    plug BookbookWeb.Plugs.Locale, "en"
    plug :check_ajax_request
    plug :put_user_token
    plug :lit_ssr_content
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :app do
    plug :put_layout, html: {BookbookWeb.Layouts, :app}
  end

  pipeline :site do
    plug :put_layout, html: {BookbookWeb.Layouts, :site}
  end

  defp put_current_route(conn, _) do
    case Phoenix.Router.route_info(BookbookWeb.Router, "GET", current_path(conn), "any") do
      :error -> conn
      info -> assign(conn, :current_route, info.route)
    end
  end

  # Set things up for the `<ajax-it>` component.
  defp check_ajax_request(conn, _) do
    if get_req_header(conn, "ajax-it") == ["true"] do
      conn
      |> assign(:ajax, true)
      |> put_root_layout(html: false)
      |> put_layout(html: false)
    else
      conn
    end
  end

  defp lit_ssr_content(conn, _) do
    if @enable_ssr do
      register_before_send(conn, fn conn ->
        {:ok, rendered} = Bookbook.LitSSRWorker.prerender_html(conn.resp_body |> to_string())
        resp(conn, conn.status, rendered)
      end)
    else
      conn
    end
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "bookbook user token", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  # "Minimal" site routes. These don't involve much, if any, JS
  scope "/", BookbookWeb do
    pipe_through [:browser, :site]

    get "/", PageController, :home
  end

  # App routes. These are for dashboard etc which might require some frontent JS work.
  scope "/", BookbookWeb do
    pipe_through [:browser, :app]
  end

  # Misc routes
  scope "/", BookbookWeb do
    pipe_through :browser

    post "/theme", ThemeController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", BookbookWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", BookbookWeb do
    pipe_through [:browser, :site, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", BookbookWeb do
    pipe_through [:browser, :site, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", BookbookWeb do
    pipe_through [:browser, :site]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bookbook, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BookbookWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
