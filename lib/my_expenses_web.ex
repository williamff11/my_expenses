defmodule MyExpensesWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use MyExpensesWeb, :controller
      use MyExpensesWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: MyExpensesWeb

      import Plug.Conn
      import MyExpensesWeb.Gettext
      import MyExpensesWeb.Phoenix.Controller

      alias MyExpensesWeb.Router.Helpers, as: Routes

      def get_user_id_by_conn(%Plug.Conn{assigns: assigns}) do
        with jwt when not is_nil(jwt) <- Map.get(assigns, :jwt),
             fields when not is_nil(fields) <- Map.get(jwt, :fields),
             user_id <- Map.get(fields, "user") do
          user_id
        else
          _ -> {:error, "invalid_jwt"}
        end
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/my_expenses_web/templates",
        namespace: MyExpensesWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import MyExpensesWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import MyExpensesWeb.ErrorHelpers
      import MyExpensesWeb.Gettext
      alias MyExpensesWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
