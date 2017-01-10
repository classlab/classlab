defmodule Classlab.JWT.UserToken do
  @moduledoc """
  Encodes/Decodes user parameters for session handling.
  Possible parameters: [:user_id]
  """
  defstruct user_id: nil

  @doc """
  encode takes an UserToken struct and return an JWT
  Example:
  encode(%UserToken{user_id: 1})
  """
  def encode(%__MODULE__{} = params) do
    params
    |> Joken.token()
    |> Joken.with_signer(Joken.hs256(jwt_secret()))
    |> Joken.sign()
    |> Joken.get_compact()
  end

  def decode(nil) do nil end
  def decode(token) when is_binary(token) do
    result =
      token
      |> Joken.token()
      |> Joken.with_signer(Joken.hs256(jwt_secret()))
      |> Joken.verify()

    case result do
      %Joken.Token{claims: claims, error: nil} -> to_struct(__MODULE__, claims)
      %Joken.Token{error: _}                   -> nil
    end
  end

  defp jwt_secret do
    Application.get_env(:classlab, :jwt_secret)
  end

  defp to_struct(kind, attrs) do
    struct = struct(kind)
    Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end
  end
end
