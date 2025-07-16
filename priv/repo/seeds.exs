# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bookbook.Repo.insert!(%Bookbook.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Bookbook.Accounts
alias Bookbook.Repo

if Application.fetch_env!(:bookbook, :env) == :dev do
  {:ok, user} =
    Accounts.register_user(%{
      handle: "sampleuser",
      email: "example@bookbook.ink",
      password: "foobarbazquux",
      password_confirmation: "foobarbazquux"
    })

  {:ok, _} = Repo.transaction(Accounts.confirm_user_multi(user))
end
