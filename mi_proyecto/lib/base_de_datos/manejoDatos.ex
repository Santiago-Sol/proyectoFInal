defmodule DBU do
  alias Exqlite.Sqlite3

  @db_path "baseDatosChat.sqlite3"

  #funcion para crear todo lo de db
  def crearBaseYTablas do
    IO.inspect([crear_base_datos(),
    crear_tabla_usuarios(),
    crear_tabla_registro_mensajes(),
    crear_tabla_salas(),
    crear_tabla_miembros()
    ])

  end

  #agrega usuario con todo
  def agregarUsuario(%Usuario{} = usuario) do
    query = "INSERT INTO usuarios (username, password, estado) VALUES (?, ?, ?);"
    values = [usuario.username, usuario.contraseña, usuario.estado]
    IO.inspect(queryExc(query, values, :insert))
  end

  #agrega mesage con todo
  def agregarMensage(%Mensage{} = mensage) do
    query = "INSERT INTO registroMensages (sala, fecha, usuario, mensage) VALUES (?, ?, ?, ?);"
    data = [mensage.sala, NaiveDateTime.to_string(mensage.fecha), mensage.usuario, mensage.mensaje]
    queryExc(query, data, :insert)
  end

  #agrega sala con todo
  def agregarSala(sala)do
    query = "INSERT INTO Sala (nombre) VALUES (?)"
    data = [sala]
    queryExc(query, data, :insert)
  end

  #agregaMiembros de una sala con todo
  def agregarSalaMiembro(%Miembro{} = miembro)do
    query = "INSERT INTO miembrosDeSala (Sala, Miembro) VALUES (?, ?)"
    param = [miembro.sala, miembro.miembro]
    queryExc(query, param, :insert)
  end


  def cargar_salas() do
    query = "SELECT * FROM Sala;"
    lista = queryExc(query, nil, :select)


    mapa = Enum.reduce(lista, %{}, fn [_id, contraseña], acc -> Map.put_new(acc, contraseña, []) end)
    Map.put_new(mapa, "lobby", [])
    IO.inspect(mapa)


    mapa
  end

  def cargarMensajes() do
    query = "SELECT * FROM registroMensages;"
    data = []
    queryExc(query, data, :select)
  end

  def cargar_usuarios() do
    query = "SELECT * FROM usuarios;"
    queryExc(query, nil, :select)
  end
  #
  def obtenerUsuario(username, password)do
    query = "SELECT * FROM usuarios WHERE username = ? AND password = ?;"
    data = [username, password]
    queryExc(query, data, :select)
  end

  def obtenerSalas(nombre)do
    query = "SELECT * FROM Sala WHERE nombre = ?"
    data = [nombre]
    queryExc(query, data, :select)
  end

  def obtenerMiembrosDeSala(_sala)do
    query = """
    SELECT usuarios.username
    FROM miembrosDeSala
    JOIN Sala ON miembrosDeSala.Sala = Sala.id
    JOIN usuarios ON miembrosDeSala.Miembro = usuarios.id
    WHERE Sala.nombre = ?;
    """
  queryExc(query,nil, :select)
  end





  # Función para crear la base de datos
  defp crear_base_datos do
    case Sqlite3.open(@db_path) do
      {:ok, db} ->
        Sqlite3.close(db)
        {:ok, "Base de datos creada exitosamente."}
      {:error, reason} ->
        {:error, "Error al crear la base de datos: #{reason}"}
    end
  end

  # Función para crear la tabla registroMensages
  defp crear_tabla_registro_mensajes do
    query = """
        CREATE TABLE IF NOT EXISTS "registroMensages" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
          "sala" TEXT NOT NULL,
          "fecha" TEXT NOT NULL,
          "usuario" TEXT NOT NULL,
          "mensage" TEXT NOT NULL,
          FOREIGN KEY("usuario") REFERENCES "usuarios"("id")
        );
        """
    queryExc(query, nil, :exec)
  end

  # Función para crear la tabla usuarios
  defp crear_tabla_usuarios do
    query = """
        CREATE TABLE IF NOT EXISTS "usuarios" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
          "username" TEXT NOT NULL UNIQUE,
          "password" TEXT NOT NULL,
          "estado" INTEGER NOT NULL
        );
        """
    queryExc(query, nil, :exec)
  end

  defp crear_tabla_salas()do
    query = """
        CREATE TABLE "Sala" (
	        "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	        "nombre"	TEXT NOT NULL
        );
        """
    queryExc(query, nil, :exec)
  end

  defp crear_tabla_miembros()do
    query = """
            CREATE TABLE "miembrosDeSala" (
	            "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	            "Sala"	INTEGER NOT NULL,
	            "Miembro"	TEXT NOT NULL,
	            FOREIGN KEY("Sala") REFERENCES "Sala"("id"),
	            FOREIGN KEY("Miembro") REFERENCES "usuarios"("id")
            );
        """
    queryExc(query, nil, :exec)
  end

  # Función para ejecutar consultas SQL
  defp queryExc(query, param, mode)do
    with {:ok, db} <- Sqlite3.open(@db_path),
         {:ok, stmt} <- Sqlite3.prepare(db, query),
         :ok <- Sqlite3.bind(db, stmt, param)
         do
          resultado =
            case mode do
              :insert ->
                with :done <- Sqlite3.step(db, stmt) do
                  :nice
                else
                  {:error, reason} ->
                    IO.puts("error al insertar, con error -> #{reason}")
                    {:error, reason}

                  other ->
                    IO.puts("paso algo inesperado -> #{other}")
                    other
                end
              :select ->
                acoplar([], db, stmt)
              #probar
              :exec ->
                case Sqlite3.step(db, stmt) do
                  :done -> {:ok, "ejecucion correcta"}
                  {:error, reason} ->
                    IO.puts("ha ocurrido un error en execute")
                    {:error, reason}
                  other -> other
                end
            end

            :ok = Sqlite3.release(db, stmt)
            :ok = Sqlite3.close(db)

            resultado

    else
      {:error, reason} ->
        IO.puts("Error al ejecutar query #{query} con parámetros #{inspect(param)} -> #{inspect(reason)}")
        {:error, reason}
    end
  end
  defp acoplar(list, db, stmt) do
    case Sqlite3.step(db, stmt) do
      {:row, data} ->
        acoplar([data | list], db, stmt)

      {:error, reason} ->
        IO.puts("Ha ocurrido un error en acoplar -> #{reason}")
        {:error, reason}

      :done ->
        Enum.reverse(list)

      other ->
        IO.puts("Ocurrió un error inesperado en acoplar -> #{other}")
        other
    end
  end


end
