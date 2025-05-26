defmodule Sala do
  defstruct [id: nil, nombre: ""]
  #Función para crear una nueva sala con id y nombre
  def crear(nombre) do
    %Sala{
      nombre: nombre
    }
  end

  def crear(id, nombre) do
    %Sala{
      id: id,
      nombre: nombre
    }
  end


end
