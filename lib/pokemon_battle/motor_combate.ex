defmodule PokemonBattle.MotorCombate do

  # Traer los structs para usarlos en este módulo
  alias PokemonBattle.Estructuras.Pokemon
  alias PokemonBattle.Estructuras.Movimiento
  alias PokemonBattle.Estructuras.PokemonEnBatalla

  # Tabla de efectividades de tipos
  @efectividades %{
    "Fuego"     => %{"Planta" => 2.0, "Hielo" => 2.0, "Bicho" => 2.0},
    "Agua"      => %{"Fuego"  => 2.0, "Roca"  => 2.0, "Tierra" => 2.0},
    "Planta"    => %{"Agua"   => 2.0, "Roca"  => 2.0, "Tierra" => 2.0},
    "Electrico" => %{"Agua"   => 2.0, "Volador" => 2.0},
    "Roca"      => %{"Fuego"  => 2.0, "Hielo" => 2.0, "Volador" => 2.0, "Bicho" => 2.0}
  }


  # FUNCIÓN PRINCIPAL
  # Recibe dos PokemonEnBatalla y un Movimiento
  # Retorna el daño final como número entero

  def calcular_dano(
    %PokemonEnBatalla{pokemon: atacante},
    %PokemonEnBatalla{pokemon: defensor},
    %Movimiento{} = movimiento,
    tipos_defensor,
    tipos_atacante
  ) do
    efectividad = calcular_efectividad(movimiento.tipo, tipos_defensor)
    bono_tipo   = calcular_bono_tipo(movimiento.tipo, tipos_atacante)
    factor_azar = 0.85 + :rand.uniform() * 0.15

    dano_base  = trunc((movimiento.poder_base * (atacante.ataque / defensor.defensa)) / 5 + 2)
    dano_final = trunc(dano_base * efectividad * bono_tipo * factor_azar)

    max(dano_final, 1)
  end


  # Aplica el daño al defensor
  # Retorna un PokemonEnBatalla actualizado

  def aplicar_dano(%PokemonEnBatalla{} = pokemon_en_batalla, dano) do
    nueva_salud = max(pokemon_en_batalla.salud_actual - dano, 0)
    debilitado  = nueva_salud == 0

    %{pokemon_en_batalla |
      salud_actual: nueva_salud,
      debilitado:   debilitado
    }
  end


  # Orden por velocidad
  # Retorna :primero_a o :primero_b

  def orden_por_velocidad(%PokemonEnBatalla{pokemon: pokemon_a}, %PokemonEnBatalla{pokemon: pokemon_b}) do
    cond do
      pokemon_a.velocidad > pokemon_b.velocidad -> :primero_a
      pokemon_b.velocidad > pokemon_a.velocidad -> :primero_b
      true ->
        if :rand.uniform(2) == 1, do: :primero_a, else: :primero_b
    end
  end


  # Efectividad total del movimiento
  # Multiplica modificadores si el defensor tiene 2 tipos

  def calcular_efectividad(tipo_movimiento, tipos_defensor) do
    Enum.reduce(tipos_defensor, 1.0, fn tipo_def, acumulado ->
      modificador = obtener_modificador(tipo_movimiento, tipo_def)
      acumulado * modificador
    end)
  end


  # Bono por mismo tipo (STAB)
  # x1.5 si el movimiento es del tipo del atacante

  def calcular_bono_tipo(tipo_movimiento, tipos_atacante) do
    if tipo_movimiento in tipos_atacante, do: 1.5, else: 1.0
  end


  # PRIVADAS


  defp obtener_modificador(tipo_ataque, tipo_defensor) do
    fuerte_contra = Map.get(@efectividades, tipo_ataque, %{})

    cond do
      Map.get(fuerte_contra, tipo_defensor) == 2.0 ->
        2.0

      Map.get(@efectividades, tipo_defensor, %{})
      |> Map.get(tipo_ataque) == 2.0 ->
        0.5

      true ->
        1.0
    end
  end

end
