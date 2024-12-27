defmodule RealDealApi.AccountsTest do
  use RealDealApi.DataCase
  alias RealDealApi.{Accounts, Accounts.Account}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)
  end

  describe "create_account/1" do
    test "success: it inserts an account in the db and returns the account" do
      params = Factory.string_params_for(:account)

      assert {:ok, %Account{} = returned_account} = Accounts.create_account(params)

      account_from_db = Repo.get(Account, returned_account.id)

      assert returned_account == account_from_db

      mutated = ["hash_password"]

      for {param_field, expected} <- params, param_field not in mutated do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(account_from_db, schema_field)

        assert actual == expected,
               "Values did not match for field: #{inspect(param_field)}\nexpected: #{inspect(actual)}"
      end

      assert Pbkdf2.verify_pass(params["hash_password"], returned_account.hash_password),
             "Password does not match"

      assert account_from_db.inserted_at == account_from_db.updated_at
    end

    test "error: returns an error tuple when account can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Accounts.create_account(missing_params)
    end
  end
end
