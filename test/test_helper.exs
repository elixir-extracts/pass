ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Passport.Test.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Passport.Test.Repo --quiet)
Passport.Test.Repo.start_link
Ecto.Adapters.SQL.begin_test_transaction(Passport.Test.Repo)
