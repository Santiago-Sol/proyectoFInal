# archivo: nodo_cliente.exs

defmodule NodoCliente do
  @servidor :"nodoservidor@127.0.0.1"
  # Nombre del nodo al que se conectará el cliente

  # Función principal del cliente
  def main do
    Node.connect(@servidor)
    IO.inspect(Node.self(), label: "Este nodo es")
    IO.inspect(Node.list(), label: "Nodos conectados")
    inicio()
    ciclo_chat()
  end
  # Inicia el cliente, solicitando al usuario si quiere ingresar o registrar un nuevo usuario
  def inicio() do
  n = IO.gets("Presiona 1 para ingresar y 2 para registrar un nuevo usuario: ") |> String.trim()
  cond do
    n == "1" -> solicitar_credenciales()
    n == "2" -> registrar_usuario()
    true ->
      IO.puts("Opción no reconocida")
      inicio()
  end
end
  # Solicita al usuario registrar un nuevo usuario
  def registrar_usuario() do
    IO.puts("Registro de nuevo usuario")
    username = IO.gets("Ingrese Usuario: ") |> String.trim()
    password = IO.gets("Ingrese Contraseña: ") |> String.trim()
    send({:recividor, @servidor}, {self(), {:register, username, password}})
    solicitar_credenciales()
  end

  # Solicita credenciales al usuario e intenta autenticarse en el servidor
  defp solicitar_credenciales do
    IO.puts("Por favor, ingrese sus credenciales:")
    user = IO.gets("Usuario: ") |> String.trim()
    pass = IO.gets("Contraseña: ") |> String.trim()
    send({:recividor, @servidor}, {self(), {:login, user, pass}})

    receive do
      {:respuesta_login, :ok, salas} ->
        IO.puts("Bienvenido. Salas disponibles: #{Enum.join(salas, ", ")}")

      {:respuesta_login, :error} ->
        IO.puts("Credenciales incorrectas.")
        solicitar_credenciales()
    after
      5_000 ->
        IO.puts("No hay respuesta del servidor.")
        exit(:timeout)
    end
  end

  # Bucle principal del cliente, escucha y envía mensajes
  defp ciclo_chat do
    receive do
      {:mensaje, texto} ->
        IO.puts("\r#{texto}")
        ciclo_chat()

      {:lista_usuarios, lista} ->
        IO.puts("\rUsuarios en tu sala: #{Enum.join(lista, ", ")}")
        ciclo_chat()

      {:creada, sala, salas} ->
        IO.puts("\rSala creada: #{sala}. Ahora: #{Enum.join(salas, ", ")}")
        ciclo_chat()

      {:joined, sala} ->
        IO.puts("\rTe uniste a: #{sala}")
        ciclo_chat()

      {:error_sala, msg} ->
        IO.puts("\rError: #{msg}")
        ciclo_chat()

      {:salir, :ok} ->
        IO.puts("\rDesconectado.")
        exit(:normal)
    after
      100 ->
        # Espera de entrada del usuario para enviar comando o mensaje
        line = IO.gets("> ") |> String.trim()

        cond do
          String.starts_with?(line, "/") ->
            send({:recividor, @servidor}, {self(), {:comando, line}})

          true ->
            send({:recividor, @servidor}, {self(), {:mensaje, line}})
        end

        ciclo_chat()
    end
  end
end

NodoCliente.main()

#elixir --name nodocliente@127.0.0.1 --cookie cookie.exs -S mix run lib/recepcion/nodo_cliente.exs
