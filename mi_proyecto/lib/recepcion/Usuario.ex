defmodule Usuario do
  defstruct [id: nil, username: "", contraseña: "", estado: 0]

  # Función para crear una nueva estructura de usuario
  def crear(username, contraseña, estado) do
    %Usuario{
      username: username,
      contraseña: contraseña,
      estado: estado
    }
  end

  def crear(id, username, contraseña, estado) do
    %Usuario{
      id: id,
      username: username,
      contraseña: contraseña,
      estado: estado
    }
  end

  def empaquetar_usuarios(matriz) do
    lista = Enum.map(matriz, fn [id, username, contraseña, estado] ->
      Usuario.crear(id, username, contraseña, estado)
    end)
    IO.inspect(lista)
    lista
  end
end
