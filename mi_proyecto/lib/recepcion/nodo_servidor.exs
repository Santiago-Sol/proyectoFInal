

defmodule NodoServidor do
  @nombre_proceso :recividor
  def main() do
    DBU.crearBaseYTablas()
    IO.puts("Iniciando nodo secundario con gestión de salas...")
    Process.register(self(), @nombre_proceso)
    usuarios = cargar_usuarios()
    salas = DBU.cargar_salas()
    IO.inspect(salas)
    recividor(usuarios, [], salas, [])
  end

  def recividor(usuarios, clientes, salas, pantallas) do
    receive do
      {pid, {:login, user, pass}} ->
        IO.puts("Intento de login: #{user}")
        case autenticar(user, pass, cargar_usuarios()) do
          {:ok, _u} ->
            send(pid, {:respuesta_login, :ok, Map.keys(salas)})
            clientes = [{pid, user, "lobby"} | clientes]
            salas = actualizar_sala(salas, "lobby", pid)
            recividor(usuarios, clientes, salas, pantallas)

          :error ->
            send(pid, {:respuesta_login, :error})
            recividor(usuarios, clientes, salas, pantallas)
        end

      {pid, {:comando, cmd}} ->
        cond do
          cmd in ["/list", "/lista"] ->
            sala = obtener_sala(pid, clientes)
            lista = for {_, u, s} <- clientes, s == sala, do: u

            send(pid, {:lista_usuarios, [length(lista)]})
            recividor(usuarios, clientes, salas, pantallas)

          String.starts_with?(cmd, "/create ") or String.starts_with?(cmd, "/crear ") ->
            [_, sala] = String.split(cmd, " ", parts: 2)
            IO.puts("Sala creada: #{sala}")
            nuevas_salas = Map.put_new(salas, sala, [])
            DBU.agregarSala(sala)
            send(pid, {:creada, sala, Map.keys(nuevas_salas)})
            recividor(usuarios, clientes, nuevas_salas, pantallas)

          String.starts_with?(cmd, "/join ") or String.starts_with?(cmd, "/unirse ") ->
            [_, sala] = String.split(cmd, " ", parts: 2)
            if Map.has_key?(salas, sala) do
              nuevos_clientes = for {p, u, s} <- clientes do
                if p == pid, do: {p, u, sala}, else: {p, u, s}
              end
              send(pid, {:joined, sala})
              recividor(usuarios, nuevos_clientes, salas, pantallas)
            else
              send(pid, {:error_sala, "Sala no existe"})
              recividor(usuarios, clientes, salas, pantallas)
            end

          cmd in ["/history", "/historial"] ->
            #sala = obtener_sala(pid, clientes)
            mensajes_sala = DBU.cargarMensajes()  # ← Asegúrate de que esta función filtre por sala
            mensajes_struc = Mensage.empaquetar_Mensages(mensajes_sala)
            Enum.each(mensajes_struc, fn mensaje ->
              Enum.each(pantallas, fn p ->
                send(p, {:mensaje, "[#{mensaje.sala}] #{mensaje.usuario}: #{mensaje.mensaje}"})
              end)
            end)
            recividor(usuarios, clientes, salas, pantallas)


          cmd in ["/exit", "/salir"] ->
            IO.puts("#{obtener_usuario(pid, clientes)} salió de su sala")
            nuevos_clientes = for {p, u, s} <- clientes do
              if p == pid, do: {p, u, ""}, else: {p, u, s}
            end
            send(pid, {:info, "Has salido de tu sala actual. Puedes unirte a otra o crear una nueva."})
            recividor(usuarios, nuevos_clientes, salas, pantallas)

          cmd in ["/close"] ->
            IO.puts("#{obtener_usuario(pid, clientes)} ha cerrado la sesión")
            nuevos_clientes = Enum.reject(clientes, fn {p, _, _} -> p == pid end)
            send(pid, {:salir, :ok})
            recividor(usuarios, nuevos_clientes, salas, pantallas)

          String.starts_with?(cmd, "/all ") or String.starts_with?(cmd, "/todos ") ->
            [_, texto] = String.split(cmd, " ", parts: 2)
            usuario = obtener_usuario(pid, clientes)
            sala = obtener_sala(pid, clientes)
            mensaje = "[#{sala}] #{usuario}: #{texto}"
            Enum.each(clientes, fn {p,_,_} -> send(p, {:mensaje, mensaje}) end)
            Enum.each(pantallas, fn p -> send(p, {:mensaje, mensaje}) end)
            recividor(usuarios, clientes, salas, pantallas)

          true ->
            send(pid, {:error, "Comando no reconocido"})
            recividor(usuarios, clientes, salas, pantallas)
        end

      {pid, {:mensaje, texto}} ->
        sala = obtener_sala(pid, clientes)
        if sala == "" do
          send(pid, {:error, "No estás en ninguna sala. Usa /join o /create primero."})
        else
          usuario = obtener_usuario(pid, clientes)
          mensaje = "[#{sala}] #{usuario}: #{texto}"
          if texto != "" do
            DBU.agregarMensage( Mensage.crear(sala,usuario,texto))
            Enum.each(pantallas, fn p -> send(p, {:mensaje, mensaje}) end)
          end
        end
        recividor(usuarios, clientes, salas, pantallas)

      {pid, :registrar_pantalla} ->
        IO.puts("Pantalla registrada: #{inspect(pid)}")
        recividor(usuarios, clientes, salas, [pid | pantallas])

      {pid, {:listar_salas}} ->
          send(pid, {:lista_salas, Map.keys(salas)})
          recividor(usuarios, clientes, salas, pantallas)

      {_pid, {:register, user, pass}} ->
        IO.puts("Intento de login: #{user}")
        DBU.agregarUsuario(Usuario.crear(user, pass, 1))
        IO.puts("Usuario creado")
        recividor(usuarios, clientes, salas, pantallas)


    end
  end

  defp actualizar_sala(salas, sala, pid) do
    Map.update(salas, sala, [pid], fn lista -> Enum.uniq([pid | lista]) end)
  end

  defp obtener_sala(pid, clientes) do
    case Enum.find(clientes, fn {p, _, _} -> p == pid end) do
      {_, _, sala} -> sala
      _ -> ""
    end
  end

  defp obtener_usuario(pid, clientes) do
    case Enum.find(clientes, fn {p, _, _} -> p == pid end) do
      {_, usuario, _} -> usuario
      _ -> "Desconocido"
    end
  end

  defp autenticar(user, pass, usuarios) do
    IO.inspect(usuarios)
    case Enum.find(usuarios, fn u -> u.username == user and u.contraseña == pass end) do
      nil -> :error
      u   -> {:ok, u}
    end
  end

  defp cargar_usuarios do
    Usuario.empaquetar_usuarios(DBU.cargar_usuarios())

  end
end

NodoServidor.main()

#elixir --name nodoservidor@127.0.0.1 --cookie cookie.exs -S mix run lib/recepcion/nodo_servidor.exs
