defmodule Passport.Hash do
  @config Application.get_env(:passport, __MODULE__, %{})

  def db_password(password) do
    blocks = @config[:blocks] || 2
    cost   = @config[:cost]   || 160_000
    salt   = new_salt
    hash   = password(password, salt, blocks, cost)

    "pbkdf2_sha512$#{blocks}$#{cost}$#{Base.url_encode64 salt, padding: false}$#{Base.url_encode64 hash, padding: false}"
  end

  # Attempts to implement the PBKDF2 algorithm
	def password(password, salt, blocks \\ 2, cost \\ 96_000) when is_binary(password) do
    block_iterations(%{
      block:    1,
      blocks:   blocks,
      cost:     cost,
      salt:     salt,
      password: password
    })
  end

  def verify(password, hash) when is_binary(password) and is_binary(hash) do
    [_, blocks, cost, salt, hash] = String.split(hash, "$")

    password(
      password,
      Base.url_decode64!(salt, padding: false),
      String.to_integer(blocks),
      String.to_integer(cost)
    ) == Base.url_decode64!(hash, padding: false)
  end



  defp new_salt(size \\ 32) do
    :crypto.strong_rand_bytes(size)
  end

  defp block_iterations(%{block: block, blocks: blocks, password: password, salt: salt, cost: cost})
  when block >= blocks do
    hash_iterations(cost, password, salt <> <<block::big-integer-size(32)>>)
  end

  defp block_iterations(%{block: block, blocks: blocks, password: password, salt: salt, cost: cost}) do
    hash_iterations(cost, password, salt <> <<block::big-integer-size(32)>>) <>
    block_iterations(%{block: block + 1, blocks: blocks, password: password, salt: salt, cost: cost})
  end

  defp hash_iterations(1, key, data) do
    hash_function(key, data)
  end

  defp hash_iterations(cost, key, data) do
    first = hash_function(key, data)
    :crypto.exor(first, hash_iterations(cost - 1, key, first))
  end

  defp hash_function(key, data) do
    :crypto.hmac(:sha512, key, data)
  end
end
