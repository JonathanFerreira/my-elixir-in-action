# user = %{"login" => "jferreira", "email" => "jferreira@kazap.com", "password" => "qwerty", "other_info" => "foo"}

# Let's suppose we need to extract login, email and password
defmodule ExtractorCase do
  def extract_user(user) do
    case extract_login(user) do
      # Somethings goes wrong to extract login
      {:error, reason} -> {:error, reason}

      # Pattern matching assuming success to extract login
      {:ok, login} ->

        case extract_email(user) do
          {:error, reason} -> {:error, reason}
          {:ok, email} ->
            case extract_password(user) do
              {:error, reason} -> {:error, reason}
              {:ok, password} ->
                {:ok, %{login: login, email: email, password: password}}
            end
        end
    end
  end

  defp extract_login(%{"login" => login}), do: {:ok, login}
  defp extract_login(_), do: {:error, "login missing"}

  defp extract_email(%{"email" => email}), do: {:ok, email}
  defp extract_email(_), do: {:error, "email missing"}

  defp extract_password(%{"password" => password}), do: {:ok, password}
  defp extract_password(_), do: {:error, "password missing"}
end

defmodule ExtractorWith do
  def extract_user(user) do
    with(
      {:ok, login} <- extract_login(user),
      {:ok, email} <- extract_email(user),
      {:ok, password} <- extract_password(user)
    ) do
        {:ok, %{login: login, email: email, password: password}}
    end
  end


  # Same functions above
  defp extract_login(%{"login" => login}), do: {:ok, login}
  defp extract_login(_), do: {:error, "login missing"}

  defp extract_email(%{"email" => email}), do: {:ok, email}
  defp extract_email(_), do: {:error, "email missing"}

  defp extract_password(%{"password" => password}), do: {:ok, password}
  defp extract_password(_), do: {:error, "password missing"}
end


defmodule ExtractFilter do
  def extract_user(user) do
    case Enum.filter(["login", "email", "password"],
                     &(not Map.has_key?(user, &1))) do
      [] ->
        {:ok, %{
          login: user["login"],
          email: user["email"],
          password: user["password"]
        }}
      missing_fields ->
        {:error, "missing fields: #{Enum.join(missing_fields, ", ") }"}
    end
  end
end
