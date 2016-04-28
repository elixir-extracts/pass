defmodule Pass.Hash do
  @moduledoc """
  Implements methods for password hashing, verification, and formatting for data
  storage.
  """

  defp config, do: Application.get_env(:pass, __MODULE__, %{})

  @doc """
  Given a plaintext string it generates a new salt, hashes the string, and
  returns a string formatted for data storage. The formatted string is broken up
  into multiple sections with the "$" delimiter. The current format is:
  "hash_algorithm$#blocks$#interations$salt$hash". Both the salt and the hash
  are unpadded, URL-safe, Base 64 encoded values.
  """
  def db_password(password) do
    blocks = config[:blocks] || 2
    cost   = config[:cost]   || 160_000
    salt   = new_salt
    hash   = password(password, salt, blocks, cost)

    "pbkdf2_sha512$#{blocks}$#{cost}$#{Base.url_encode64 salt, padding: false}$#{Base.url_encode64 hash, padding: false}"
  end

  @doc """
  Implements the PBKDF2 algorithm with SHA512 to hash a password.
  """
	def password(password, salt, blocks \\ 2, cost \\ 96_000) when is_binary(password) do
    block_iterations(%{
      block:    1,
      blocks:   blocks,
      cost:     cost,
      salt:     salt,
      password: password
    })
  end

  @doc """
  Takes in a plaintext and a string formatted using the db_password/1 function
  and returns true if the formatted string is the derived key for the plaintext
  string provided.
  """
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
