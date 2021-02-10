defmodule MyExpenses.Support.Accounts do
  @moduledoc false

  alias MyExpenses.Accounts.Schema

  @doc """
  Cria uma instituição Fake.
  """
  def create_institution(params \\ %{}) do
    default_params = %{
      name: Faker.Person.PtBr.first_name(),
      legal_name: Faker.Person.PtBr.name(),
      logo: Faker.Avatar.image_url()
    }

    params = Map.merge(default_params, params)

    Schema.Institution
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end

  @doc """
  Cria uma conta Fake.
  """
  def create_account(user, params \\ %{}) do
    account =
      1..9_999_999
      |> Enum.random()
      |> to_string()
      |> String.pad_leading(7, "0")

    dv_account = Enum.random(0..8)

    initial_amount_value =
      0..1000
      |> Enum.random()
      |> to_string()
      |> Decimal.new()

    institution = create_institution()

    default_params = %{
      name: Faker.Dog.PtBr.name(),
      num_account: "#{account}-#{dv_account}",
      description: Faker.Dog.PtBr.characteristic(),
      initial_amount_value: initial_amount_value,
      type_account: Enum.random([:corrente, :poupanca, :salario, :investimento]),
      user_id: user.id,
      institution_id: institution.id
    }

    params = Map.merge(default_params, params)

    Schema.Account
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
    |> MyExpenses.Repo.preload(:institution)
  end
end
