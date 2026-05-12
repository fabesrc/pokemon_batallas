defmodule PokemonBattle.Persistencia do

  alias PokemonBattle.Estructuras.{
    Pokemon,
    Movimiento,
    Entrenador,
    Sobre,
    Equipo
  }

  # Rutas de los archivos
  @ruta_entrenadores "data/trainers.json"
  @ruta_especies     "data/pokemon.json"
  @ruta_movimientos  "data/moves.json"
  @ruta_tienda       "data/tienda.json"
  @ruta_batallas     "data/battles.log"

  # ──────────────────────────────────────────────
  # LEER ARCHIVOS
  # ──────────────────────────────────────────────

  # Lee las especies del catálogo (pokemon.json)
  # Retorna lista de mapas con las stats base
  def cargar_especies do
    leer_json(@ruta_especies)
  end

  # Lee el pool de movimientos (moves.json)
  # Retorna lista de mapas con nombre, tipo y poder_base
  def cargar_movimientos do
    leer_json(@ruta_movimientos)
  end

  # Lee los tipos de sobre y probabilidades (tienda.json)
  def cargar_tienda do
    leer_json(@ruta_tienda)
  end

  # Lee los entrenadores y los convierte en structs
  def cargar_entrenadores do
    leer_json(@ruta_entrenadores)
    |> Enum.map(&mapear_entrenador/1)
  end

  # ──────────────────────────────────────────────
  # GUARDAR ARCHIVOS
  # ──────────────────────────────────────────────

  # Guarda la lista de entrenadores en trainers.json
  def guardar_entrenadores(entrenadores) do
    datos = Enum.map(entrenadores, &entrenador_a_mapa/1)
    escribir_json(@ruta_entrenadores, datos)
  end

  # Agrega una línea al log de batallas
  def registrar_batalla(resumen) do
    linea = Jason.encode!(resumen) <> "\n"
    File.write!(@ruta_batallas, linea, [:append])
  end

  # ──────────────────────────────────────────────
  # CONVERSIÓN: JSON → STRUCTS
  # Convierte mapas crudos del JSON en structs tipados
  # ──────────────────────────────────────────────

  defp mapear_entrenador(mapa) do
    %Entrenador{
      nombre:             mapa["nombre"],
      clave:              mapa["clave"],
      victorias:          mapa["victorias"] || 0,
      monedas:            mapa["monedas"] || 0,
      monedas_acumuladas: mapa["monedas_acumuladas"] || 0,
      inventario:         Enum.map(mapa["inventario"] || [], &mapear_pokemon/1),
      sobres:             Enum.map(mapa["sobres"] || [], &mapear_sobre/1),
      equipos:            Enum.map(mapa["equipos"] || [], &mapear_equipo/1)
    }
  end

  defp mapear_pokemon(mapa) do
    %Pokemon{
      id:             mapa["id"],
      especie:        mapa["especie"],
      dueno_original: mapa["dueno_original"],
      rareza:         String.to_atom(mapa["rareza"]),
      ataque:         mapa["ataque"],
      defensa:        mapa["defensa"],
      velocidad:      mapa["velocidad"],
      movimientos:    Enum.map(mapa["movimientos"] || [], &mapear_movimiento/1)
    }
  end

  defp mapear_movimiento(mapa) do
    %Movimiento{
      nombre:     mapa["nombre"],
      tipo:       mapa["tipo"],
      poder_base: mapa["poder_base"]
    }
  end

  defp mapear_sobre(mapa) do
    %Sobre{
      id:   mapa["id"],
      tipo: mapa["tipo"]
    }
  end

  defp mapear_equipo(mapa) do
    %Equipo{
      nombre:      mapa["nombre"],
      ids_pokemon: mapa["ids_pokemon"] || []
    }
  end

  # ──────────────────────────────────────────────
  # CONVERSIÓN: STRUCTS → JSON
  # Convierte structs en mapas simples para guardar
  # ──────────────────────────────────────────────

  defp entrenador_a_mapa(%Entrenador{} = e) do
    %{
      "nombre"             => e.nombre,
      "clave"              => e.clave,
      "victorias"          => e.victorias,
      "monedas"            => e.monedas,
      "monedas_acumuladas" => e.monedas_acumuladas,
      "inventario"         => Enum.map(e.inventario, &pokemon_a_mapa/1),
      "sobres"             => Enum.map(e.sobres, &sobre_a_mapa/1),
      "equipos"            => Enum.map(e.equipos, &equipo_a_mapa/1)
    }
  end

  defp pokemon_a_mapa(%Pokemon{} = p) do
    %{
      "id"             => p.id,
      "especie"        => p.especie,
      "dueno_original" => p.dueno_original,
      "rareza"         => Atom.to_string(p.rareza),
      "ataque"         => p.ataque,
      "defensa"        => p.defensa,
      "velocidad"      => p.velocidad,
      "movimientos"    => Enum.map(p.movimientos, &movimiento_a_mapa/1)
    }
  end

  defp movimiento_a_mapa(%Movimiento{} = m) do
    %{
      "nombre"     => m.nombre,
      "tipo"       => m.tipo,
      "poder_base" => m.poder_base
    }
  end

  defp sobre_a_mapa(%Sobre{} = s) do
    %{
      "id"   => s.id,
      "tipo" => s.tipo
    }
  end

  defp equipo_a_mapa(%Equipo{} = e) do
    %{
      "nombre"      => e.nombre,
      "ids_pokemon" => e.ids_pokemon
    }
  end

  # ──────────────────────────────────────────────
  # PRIVADAS — Lectura y escritura de JSON
  # ──────────────────────────────────────────────

  defp leer_json(ruta) do
    case File.read(ruta) do
      {:ok, contenido} ->
        case Jason.decode(contenido) do
          {:ok, datos}    -> datos
          {:error, _}     -> []
        end
      {:error, _} ->
        []
    end
  end

  defp escribir_json(ruta, datos) do
    contenido = Jason.encode!(datos, pretty: true)
    File.write!(ruta, contenido)
  end

end
