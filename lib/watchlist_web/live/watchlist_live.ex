defmodule WatchlistWeb.WatchlistLive do
  use WatchlistWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    ok(socket)
  end
end
