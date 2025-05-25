defmodule Mensage do
  defstruct [sala: nil, fecha: nil, usuario: nil, mensaje: ""]

  # Función para crear una nueva estructura de mensaje en el instante que se escribio
  def crear(sala, usuario, mensaje) do
    %Mensage{
      sala: sala,
      fecha: NaiveDateTime.utc_now(),
      usuario: usuario,
      mensaje: mensaje
    }
  end

  #suponiendo que fecha es una estructura de tipo native date time
  def crear(sala, fecha , usuario, mensaje) do
    %Mensage{
      sala: sala,
      fecha: fecha,
      usuario: usuario,
      mensaje: mensaje
    }
  end

def empaquetar_Mensages(matriz) do
  Enum.map(matriz, fn
    [_id, sala, fecha, usuario, mensaje] ->
      Mensage.crear(sala, fecha, usuario, mensaje)
  end)
end


end
