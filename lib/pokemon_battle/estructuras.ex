defmodule PokemonBattle.Estructuras do

  # ── Instancia de un Pokémon en el inventario de un entrenador ──
  defmodule Pokemon do
    defstruct [
      :id,
      :especie,
      :dueno_original,
      :rareza,
      :ataque,
      :defensa,
      :velocidad,
      :movimientos,
      salud_maxima: 100
    ]
  end

  # Movimiento asignado a un Pokémon
  defmodule Movimiento do
    defstruct [
      :nombre,
      :tipo,
      :poder_base
    ]
  end

  # Entrenador registrado en el sistema
  defmodule Entrenador do
    defstruct [
      :nombre,
      :clave,
      victorias: 0,
      monedas: 0,
      monedas_acumuladas: 0,
      inventario: [],
      sobres: [],
      equipos: []
    ]
  end

  # Sobre comprado, pendiente de abrir
  defmodule Sobre do
    defstruct [
      :id,
      :tipo
    ]
  end

  # Equipo predefinido de un entrenador
  defmodule Equipo do
    defstruct [
      :nombre,
      ids_pokemon: []
    ]
  end

  # Estado de un Pokémon dentro de una batalla
  defmodule PokemonEnBatalla do
    defstruct [
      :pokemon,
      salud_actual: 100,
      debilitado: false
    ]
  end

  # ── Sala de batalla ──
  defmodule SalaBatalla do
    defstruct [
      :id,
      :tiempo_turno,
      jugadores: [],          
      estado: :esperando
    ]
  end

end
