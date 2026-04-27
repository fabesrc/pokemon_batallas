defmodule PokemonBattle.MotorCombate do

  # Tabla de efectividades de tipos
  # tipo atacante → tipo defensor → modificador
  @efectividades %{
    "Fuego"     => %{"Planta" => 2.0, "Hielo" => 2.0, "Bicho" => 2.0},
    "Agua"      => %{"Fuego"  => 2.0, "Roca"  => 2.0, "Tierra" => 2.0},
    "Planta"    => %{"Agua"   => 2.0, "Roca"  => 2.0, "Tierra" => 2.0},
    "Electrico" => %{"Agua"   => 2.0, "Volador" => 2.0},
    "Roca"      => %{"Fuego"  => 2.0, "Hielo" => 2.0, "Volador" => 2.0, "Bicho" => 2.0}
  }

  # ¿Cuánto daño hace tipo_ataque contra tipo_defensor?
  # x2.0 → fuerte, x0.5 → débil, x1.0 → neutro
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

  # Calcula la efectividad total del movimiento contra el defensor
  # Si el defensor tiene 2 tipos, se multiplican ambos modificadores
  def calcular_efectividad(tipo_movimiento, tipos_defensor) do
    Enum.reduce(tipos_defensor, 1.0, fn tipo_def, acumulado ->
      modificador = obtener_modificador(tipo_movimiento, tipo_def)
      acumulado * modificador
    end)
  end

  # Bono por mismo tipo (STAB)
  # Si el movimiento es del mismo tipo que el atacante → x1.5
  def calcular_bono_tipo(tipo_movimiento, tipos_atacante) do
    if tipo_movimiento in tipos_atacante, do: 1.5, else: 1.0
  end

  # Calcula el daño final de un ataque
  # atacante       → %{ataque: 63}
  # defensor       → %{defensa: 70}
  # movimiento     → %{poder_base: 65, tipo: "Electrico"}
  # tipos_defensor → ["Agua"]
  # tipos_atacante → ["Electrico"]
  def calcular_dano(atacante, defensor, movimiento, tipos_defensor, tipos_atacante) do
    efectividad    = calcular_efectividad(movimiento.tipo, tipos_defensor)
    bono_tipo      = calcular_bono_tipo(movimiento.tipo, tipos_atacante)
    factor_azar    = 0.85 + :rand.uniform() * 0.15

    dano_base      = trunc((movimiento.poder_base * (atacante.ataque / defensor.defensa)) / 5 + 2)
    dano_final     = trunc(dano_base * efectividad * bono_tipo * factor_azar)

    max(dano_final, 1)
  end

  # Determina quién ataca primero según velocidad
  # Retorna :primero_a o :primero_b
  def orden_por_velocidad(pokemon_a, pokemon_b) do
    cond do
      pokemon_a.velocidad > pokemon_b.velocidad -> :primero_a
      pokemon_b.velocidad > pokemon_a.velocidad -> :primero_b
      true ->
        if :rand.uniform(2) == 1, do: :primero_a, else: :primero_b
    end
  end

end
