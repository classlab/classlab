defmodule Classlab.Repo.Migrations.RemovePublicFromEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      remove :public
    end
  end
end
