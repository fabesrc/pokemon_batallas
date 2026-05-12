defmodule PokemonBattle.MotorCombateTest do
  use ExUnit.Case

  alias PokemonBattle.Estructuras.{Pokemon, Movimiento, PokemonEnBatalla}
  alias PokemonBattle.MotorCombate

  # ──────────────────────────────────────────────
  # DATOS DE PRUEBA
  # Los definimos una sola vez y los reutilizamos
  # en todos los tests
  # ──────────────────────────────────────────────

  defp pikachu do
    %PokemonEnBatalla{
      pokemon: %Pokemon{
        id: 71834,
        especie: "pikachu",
        dueno_original: "Ana",
        rareza: :raro,
        ataque: 63,
        defensa: 46,
        velocidad: 104,
        movimientos: []
      },
      salud_actual: 100
    }
  end

  defp squirtle do
    %PokemonEnBatalla{
      pokemon: %Pokemon{
        id: 40182,
        especie: "squirtle",
        dueno_original: "Luis",
        rareza: :comun,
        ataque: 52,
        defensa: 70,
        velocidad: 46,
        movimientos: []
      },
      salud_actual: 100
    }
  end

  defp impactrueno do
    %Movimiento{nombre: "impactrueno", tipo: "Electrico", poder_base: 65}
  end

  defp placaje do
    %Movimiento{nombre: "placaje", tipo: "Normal", poder_base: 35}
  end

  defp lanzarrocas do
    %Movimiento{nombre: "lanzarrocas", tipo: "Roca", poder_base: 35}
  end

  # ──────────────────────────────────────────────
  # TEST 1 — Daño con tipo FUERTE (x2.0)
  # Electrico es fuerte contra Agua → efectividad x2.0
  # Pikachu usa impactrueno de tipo Electrico → STAB x1.5
  # Daño esperado: entre 33 y 39 (varía por factor_azar)
  # ──────────────────────────────────────────────
  test "daño con tipo fuerte debe ser mayor que daño neutro" do
    dano_fuerte = MotorCombate.calcular_dano(
      pikachu(), squirtle(), impactrueno(), ["Agua"], ["Electrico"]
    )

    dano_neutro = MotorCombate.calcular_dano(
      pikachu(), squirtle(), placaje(), ["Agua"], ["Electrico"]
    )

    assert dano_fuerte > dano_neutro
  end

  # ──────────────────────────────────────────────
  # TEST 2 — Daño con tipo DÉBIL (x0.5)
  # Agua es débil contra Electrico (inversa de Electrico > Agua)
  # El daño débil debe ser menor que el neutro
  # ──────────────────────────────────────────────
  test "daño con tipo débil debe ser menor que daño neutro" do
    pistola_agua = %Movimiento{nombre: "pistola_agua", tipo: "Agua", poder_base: 40}

    dano_debil = MotorCombate.calcular_dano(
      squirtle(), pikachu(), pistola_agua, ["Electrico"], ["Agua"]
    )

    dano_neutro = MotorCombate.calcular_dano(
      squirtle(), pikachu(), placaje(), ["Electrico"], ["Agua"]
    )

    assert dano_debil < dano_neutro
  end

  # ──────────────────────────────────────────────
  # TEST 3 — Daño con tipo NEUTRO (x1.0)
  # Normal no tiene relación con Agua → x1.0
  # Sin STAB porque Pikachu es Electrico, no Normal
  # El daño debe ser al menos 1
  # ──────────────────────────────────────────────
  test "daño neutro debe ser al menos 1" do
    dano = MotorCombate.calcular_dano(
      pikachu(), squirtle(), placaje(), ["Agua"], ["Electrico"]
    )

    assert dano >= 1
  end

  # ──────────────────────────────────────────────
  # TEST 4 — Orden por velocidad
  # Pikachu velocidad 104 vs Squirtle velocidad 46
  # Pikachu siempre debe ir primero
  # ──────────────────────────────────────────────
  test "el pokemon más rápido ataca primero" do
    resultado = MotorCombate.orden_por_velocidad(pikachu(), squirtle())
    assert resultado == :primero_a
  end

  test "si el rival es más rápido va primero" do
    resultado = MotorCombate.orden_por_velocidad(squirtle(), pikachu())
    assert resultado == :primero_b
  end

  # ──────────────────────────────────────────────
  # TEST 5 — Aplicar daño
  # Verificar que la salud baja correctamente
  # y que el pokemon se marca como debilitado al llegar a 0
  # ──────────────────────────────────────────────
  test "aplicar daño reduce la salud correctamente" do
    squirtle_actualizado = MotorCombate.aplicar_dano(squirtle(), 30)
    assert squirtle_actualizado.salud_actual == 70
    assert squirtle_actualizado.debilitado == false
  end

  test "pokemon queda debilitado cuando la salud llega a 0" do
    squirtle_actualizado = MotorCombate.aplicar_dano(squirtle(), 100)
    assert squirtle_actualizado.salud_actual == 0
    assert squirtle_actualizado.debilitado == true
  end

  test "la salud no puede ser negativa" do
    squirtle_actualizado = MotorCombate.aplicar_dano(squirtle(), 999)
    assert squirtle_actualizado.salud_actual == 0
  end

  # ──────────────────────────────────────────────
  # TEST 6 — Efectividad de tipos
  # Verificar los modificadores directamente
  # ──────────────────────────────────────────────
  test "efectividad fuerte devuelve 2.0" do
    efectividad = MotorCombate.calcular_efectividad("Electrico", ["Agua"])
    assert efectividad == 2.0
  end

  test "efectividad débil devuelve 0.5" do
    efectividad = MotorCombate.calcular_efectividad("Agua", ["Electrico"])
    assert efectividad == 0.5
  end

  test "efectividad neutra devuelve 1.0" do
    efectividad = MotorCombate.calcular_efectividad("Normal", ["Agua"])
    assert efectividad == 1.0
  end

  test "efectividad con dos tipos se multiplica" do
    # Roca vs Fuego/Hielo → x2.0 * x2.0 = x4.0
    efectividad = MotorCombate.calcular_efectividad("Roca", ["Fuego", "Hielo"])
    assert efectividad == 4.0
  end

  # ──────────────────────────────────────────────
  # TEST 7 — Bono por tipo (STAB)
  # ──────────────────────────────────────────────
  test "bono de tipo aplica x1.5 cuando coincide" do
    bono = MotorCombate.calcular_bono_tipo("Electrico", ["Electrico"])
    assert bono == 1.5
  end

  test "sin bono de tipo aplica x1.0" do
    bono = MotorCombate.calcular_bono_tipo("Normal", ["Electrico"])
    assert bono == 1.0
  end

end
