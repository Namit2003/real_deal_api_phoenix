defmodule RealDealApi.Support.SchemaCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Changeset
      import RealDealApi.Support.SchemaCase
    end
  end

  setup _ do
    Ecto.Adapters.SQL.Sandbox.mode(RealDealApi.Repo, :manual)
  end

  def valid_params(fields_with_types) do
    valid_value_by_type = %{
      binary_id: fn -> Faker.UUID.v4() end,
      string: fn -> Faker.Lorem.word() end,
      utc_datetime: fn ->
        Faker.DateTime.forward(365)
        |> DateTime.truncate(:second)
      end
    }

    for {field, type} <- fields_with_types, into: %{} do
      case field do
        :email ->
          {Atom.to_string(field), Faker.Internet.email()}

        _ ->
          {Atom.to_string(field), valid_value_by_type[type].()}
      end
    end
  end
end
