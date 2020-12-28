defmodule MyExpenses.Debts.CategoryDebts do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Support.Debts

  alias MyExpenses.Debts
  alias MyExpenses.Debts.Schema

  describe "list_category_debts" do
    setup :setup_categoty_debts

    test "listagem das categorias de dívidas", context do
      %{category: category} = context

      category_id = category.id

      assert [
               %Schema.CategoryDebts{
                 id: category_id,
                 name: _,
                 description: _,
                 icon: _,
                 color: _
               }
             ] = Debts.list_category_debts()
    end

    @tag :skip
    test "lista somente as categorias onde o usuário possui gastos" do
      :not_implemeted
    end
  end

  describe "show_category_debt" do
    setup :setup_categoty_debts

    test "retorna nil ao passar uma categoria que não existe" do
      refute Debts.show_category_debt(0)
    end

    test "mostra determinada categoria de dívidas, filtrando por id", context do
      %{category: category} = context

      category_id = category.id

      assert %Schema.CategoryDebts{
               id: category_id,
               name: _,
               description: _,
               icon: _,
               color: _
             } = Debts.show_category_debt(category_id)
    end
  end

  describe "create_category_debt" do
    test "retorna erro ao tentar criar uma categoria com os parâmetros inválidos" do
      params = %{
        color: "#E80345",
        description: "Categoria destinada para gastos em restaurantes e deliverys de comida",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: ""
      }

      assert {:error, errors} = Debts.create_category_debt(params)

      assert errors = [name: {"can't be blank", [validation: :required]}]
    end

    test "cria categoria conforme parametros passados" do
      params = %{
        color: "#FFF",
        description: "Categoria destinada para gastos em restaurantes e deliverys de comida",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: "Alimentação"
      }

      category = Debts.create_category_debt(params)

      assert {:ok,
              %Schema.CategoryDebts{
                id: _,
                color: _,
                description: _,
                icon: _,
                name: "Alimentação"
              }} = category
    end
  end

  describe "update_category_debt" do
    setup :setup_categoty_debts

    test "edita a categoria conforme os dados passados", context do
      %{category: category} = context

      category_id = category.id

      params_update = %{color: "#6bc5d2", description: "description"}

      assert {:ok,
              %Schema.CategoryDebts{
                id: category_id,
                name: _,
                description: "description",
                icon: _,
                color: "#6bc5d2"
              }} = Debts.update_category_debt(category, params_update)
    end

    test "erro ao tentar editar categoria com os parâmetros inválidos", context do
      %{category: category} = context

      category_id = category.id

      params_update = %{color: "#6bc5d2", name: "ar"}

      assert {:error, errors} = Debts.update_category_debt(category, params_update)

      assert errors = [
               name:
                 {"should be at least %{count} character(s)",
                  [count: 3, validation: :length, kind: :min, type: :string]}
             ]
    end
  end

  describe "delete_category_debt" do
    setup :setup_categoty_debts

    test "deleta a categoria passada", context do
      %{category: category} = context

      category_id = category.id

      Debts.delete_category_debt(category_id)

      refute Debts.show_category_debt(category_id)
    end
  end

  defp setup_categoty_debts(_) do
    %{category: create_category_debts()}
  end
end
