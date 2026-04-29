defmodule PokemonBattle.Estructuras do

  # ── Instancia de un Pokémon en el inventario de un entrenador ──
  defmodule Pokemon do
    defstruct [
      :id,               # número entero único, ej: 48291
      :especie,          # string, ej: "charmander"
      :dueno_original,   # string, nombre del entrenador que lo obtuvo
      :rareza,           # átomo: :comun, :raro o :epico
      :ataque,           # calculado con factor_rareza
      :defensa,          # calculado con factor_rareza
      :velocidad,        # calculado con factor_rareza
      :movimientos,      # lista de 4 structs Movimiento
      salud_maxima: 100  # siempre 100, valor por defecto
    ]
  end

  # ── Movimiento asignado a un Pokémon ──
  defmodule Movimiento do
    defstruct [
      :nombre,      # string, ej: "impactrueno"
      :tipo,        # string, ej: "Electrico"
      :poder_base   # número entero, ej: 65
    ]
  end

  # ── Entrenador registrado en el sistema ──
  defmodule Entrenador do
    defstruct [
      :nombre,                      # string, ej: "Ana"
      :clave,                       # string
      victorias: 0,                 # número de batallas ganadas
      monedas: 0,                   # saldo actual
      monedas_acumuladas: 0,        # total histórico (para clasificación)
      inventario: [],               # lista de structs Pokemon
      sobres: [],                   # lista de structs Sobre
      equipos: []                   # lista de structs Equipo
    ]
  end

  # ── Sobre comprado, pendiente de abrir ──
  defmodule Sobre do
    defstruct [
      :id,      # número entero único
      :tipo     # string: "basico" o "avanzado"
    ]
  end

  # ── Equipo predefinido de un entrenador ──
  defmodule Equipo do
    defstruct [
      :nombre,        # string, ej: "rapido"
      ids_pokemon: [] # lista de ids de Pokémon del equipo (1 a 3)
    ]
  end

  # ── Estado de un Pokémon dentro de una batalla ──
  defmodule PokemonEnBatalla do
    defstruct [
      :pokemon,             # struct Pokemon completo
      salud_actual: 100,    # va bajando con los ataques
      debilitado: false     # true cuando salud_actual llega a 0
    ]
  end

  # ── Sala de batalla ──
  defmodule SalaBatalla do
    defstruct [
      :id,                    # string, ej: "S-1001"
      :tiempo_turno,          # segundos por turno, por defecto 20
      jugadores: [],          # lista con los nombres de los jugadores
      estado: :esperando      # :esperando | :en_curso | :finalizada
    ]
  end

end
