ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Pass.Test.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Pass.Test.Repo --quiet)
Pass.Test.Repo.start_link
Ecto.Adapters.SQL.begin_test_transaction(Pass.Test.Repo)
