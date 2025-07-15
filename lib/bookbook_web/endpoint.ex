defmodule BookbookWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :bookbook

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_bookbook_key",
    signing_salt: "B+Avo1St",
    same_site: "Lax"
  ]

  @scale Application.compile_env!(:bookbook, [Bookbook.RateLimit, :scale])
  @limit Application.compile_env!(:bookbook, [Bookbook.RateLimit, :limit])

  plug RemoteIp
  plug :rate_limit
  plug :theme_picker
  
  
  socket "/socket", BookbookWeb.UserSocket,
    websocket: [connect_info: [session: @session_options]]
    
  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :bookbook,
    gzip: false,
    only: BookbookWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :bookbook
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug BookbookWeb.Router
  
  defp rate_limit(conn, _opts) do
    key = "web_requests:#{:inet.ntoa(conn.remote_ip)}"

    case Bookbook.RateLimit.hit(key, @scale, @limit) do
      {:allow, _count} ->
        conn

      {:deny, retry_after} ->
        retry_after_seconds = div(retry_after, 1000)

        conn
        |> put_resp_header("retry-after", Integer.to_string(retry_after_seconds))
        |> send_resp(429, [])
        |> halt()
    end
  end

  defp theme_picker(conn, _opts) do
    conn = fetch_cookies(conn)
    conn
    |> fetch_cookies
    |> assign(:theme, conn.cookies["theme"] || "system")
  end
end
