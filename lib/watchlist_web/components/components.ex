defmodule WatchlistWeb.Components do
  use Phoenix.Component

  slot :inner_block, required: true

  def movie_layout(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-3xl">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
