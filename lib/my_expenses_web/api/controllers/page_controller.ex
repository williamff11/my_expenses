defmodule MyExpensesWeb.PageController do
  use MyExpensesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
