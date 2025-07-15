defmodule Bookbook.RateLimit do
  use Hammer, backend: :ets
end
