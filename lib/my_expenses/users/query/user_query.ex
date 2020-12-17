defmodule MyExpenses.Users.Query.UserQuery do
  @moduledoc false

  import Ecto.Query

  alias MyExpenses.Users.Schema.User

  def all_users() do
    from user in User, where: is_nil(user.deleted_at)
  end

  def get_user(user_id) do
    from user in User, where: user.id == ^user_id and is_nil(user.deleted_at)
  end

  def only_trash() do
    from user in User, where: not is_nil(user.deleted_at)
  end

  def get_user_deleted(user_id) do
    from user in User, where: user.id == ^user_id and not is_nil(user.deleted_at)
  end
end
