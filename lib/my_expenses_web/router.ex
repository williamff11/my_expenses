defmodule MyExpensesWeb.Router do
  use MyExpensesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug MyExpensesWeb.Auth
  end

  scope "/", MyExpensesWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api/v1", MyExpensesWeb.Api.V1.Controllers do
    pipe_through :api
    pipe_through :auth

    resources "accounts", AccountController, only: [:index, :show, :create, :update, :delete]

    get "/expense_categories", ExpenseController, :index_expense_categories
    get "/expense_categories/:id", ExpenseController, :show_expense_category
    post "/expense_categories", ExpenseController, :create_expense_category
    put "/expense_categories/:id", ExpenseController, :update_expense_category
    delete "/expense_categories/:id", ExpenseController, :delete_expense_category

    get "/expenses", ExpenseController, :index_expenses
    get "/expenses/:id", ExpenseController, :show_expense
    post "/expenses", ExpenseController, :create_expense
    put "/expenses/:id", ExpenseController, :update_expense
    delete "/expenses/:id", ExpenseController, :delete_expense

    get "/gain_categories", GainController, :index_gain_categories
    get "/gain_categories/:id", GainController, :get_gain_category
    post "/gain_categories", GainController, :create_gain_category
    put "/gain_categories/:id", GainController, :update_gain_category
    delete "/gain_categories/:id", GainController, :delete_gain_category

    get "/gains", GainController, :index_gains
    get "/gains/:id", GainController, :show_gain
    post "/gains", GainController, :create_gain
    put "/gains/:id", GainController, :update_gain
    delete "/gains/:id", GainController, :delete_gain
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyExpensesWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MyExpensesWeb.Telemetry
    end
  end
end
