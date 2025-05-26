defmodule Miembro do
  defstruct [id: nil, sala: 0, miembro: 0]
  #Función para crear un nuevo miembro con id, sala y miembro
  def crear(id ,sala , miembro) do
    %Miembro{
      id: id,
      sala: sala,
      miembro: miembro
    }
  end

  def crear(sala , miembro) do
    %Miembro{
      sala: sala,
      miembro: miembro
    }
  end
end
