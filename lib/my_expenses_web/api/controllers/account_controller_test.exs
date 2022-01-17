defmodule MyExpensesWeb.Api.Controllers.AccountControllerTest do
  use MyExpensesWeb.ConnCase

  import MyExpenses.Factories

  @endpoint "/api/v1/accounts"

  describe "authentication" do
    test "should return unauthorized" do
      build_conn()
      |> get(@endpoint)
      |> json_response(401)
    end
  end
end
