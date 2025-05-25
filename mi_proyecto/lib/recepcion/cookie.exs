defmodule Cookie do
  @longitud_llave 128

  def main() do
    :crypto.strong_rand_bytes(@longitud_llave)
    |> Base.encode64()
    |> Utils.mostrar_mensaje()
  end
end
