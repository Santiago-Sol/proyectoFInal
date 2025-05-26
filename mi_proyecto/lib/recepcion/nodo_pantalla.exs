defmodule NodoPantalla do
  @servidor :"nodoservidor@127.0.0.1"
  def main do
    Node.connect(@servidor)
    send({:recividor, @servidor}, {self(), :registrar_pantalla})
    escuchar()
  end

  defp escuchar do
    receive do
      {:mensaje, texto} ->
        IO.puts(">> #{texto}")
        escuchar()
    after
      1000 -> escuchar()
    end
  end
end

NodoPantalla.main()
#nodopantalla@127.0.0.1 --cookie cookie.exs -S mix run lib/recepcion/nodo_pantalla.exs
