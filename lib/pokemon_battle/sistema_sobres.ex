defmodule PokemonBattle.SistemaSobres do

  alias PokemonBattle.Estructuras.Pokemon
  alias PokemonBattle.Estructuras.Movimiento
  alias PokemonBattle.Estructuras.Sobre


  # COMPRAR SOBRE
  # Verifica monedas y crea un sobre pendiente
  # Retorna {:ok, sobre} o {:error, motivo}

  def comprar_sobre(entrenador, tipo_sobre, tipos_disponibles) do
    # Buscar el tipo de sobre en la tienda
    case Enum.find(tipos_disponibles, fn t -> t.tipo == tipo_sobre end) do
      nil ->
        {:error, "Tipo de sobre '#{tipo_sobre}' no existe"}

      sobre_info ->
        # ¿Tiene monedas suficientes?
        if entrenador.monedas < sobre_info.precio do
          {:error, "Monedas insuficientes. Tienes #{entrenador.monedas}, necesitas #{sobre_info.precio}"}
        else
          nuevo_sobre = %Sobre{
            id:   generar_id(),
            tipo: tipo_sobre
          }
          {:ok, nuevo_sobre, sobre_info.precio}
        end
    end
  end


  def abrir_sobre(sobre, dueno, especies, movimientos_pool, tipos_disponibles) do
    # Buscar las probabilidades del tipo de sobre
    info_sobre = Enum.find(tipos_disponibles, fn t -> t.tipo == sobre.tipo end)

    # Generar 3 Pokémon
    Enum.map(1..3, fn _ ->
      generar_pokemon(dueno, especies, movimientos_pool, info_sobre.probabilidades)
    end)
  end


  def sortear_rareza(probabilidades) do
    numero = :rand.uniform(100)

    cond do
      numero <= probabilidades.comun ->
        :comun
      numero <= probabilidades.comun + probabilidades.raro ->
        :raro
      true ->
        :epico
    end
  end


  def calcular_estadisticas(especie, rareza) do
    {min_factor, max_factor} = rango_rareza(rareza)

    # Sortea un factor aleatorio dentro del rango de la rareza
    factor = min_factor + :rand.uniform(max_factor - min_factor + 1) - 1

    %{
      ataque:    round(especie.ataque_base    * (1 + factor / 100)),
      defensa:   round(especie.defensa_base   * (1 + factor / 100)),
      velocidad: round(especie.velocidad_base * (1 + factor / 100))
    }
  end



  def asignar_movimientos(tipos_especie, movimientos_pool) do
    case tipos_especie do
      # Especie con un solo tipo
      [tipo] ->
        # 2 movimientos del tipo de la especie
        del_tipo     = movimientos_del_tipo(tipo, movimientos_pool) |> Enum.take_random(2)
        # 2 movimientos de cualquier tipo (sin repetir los ya elegidos)
        ya_elegidos  = Enum.map(del_tipo, fn m -> m.nombre end)
        otros        = movimientos_pool
                       |> Enum.reject(fn m -> m.nombre in ya_elegidos end)
                       |> Enum.take_random(2)
        del_tipo ++ otros

      # Especie con DOS tipos
      [tipo1, tipo2] ->
        # 1 movimiento del tipo 1
        mov_tipo1    = movimientos_del_tipo(tipo1, movimientos_pool) |> Enum.take_random(1)
        # 1 movimiento del tipo 2
        ya_elegidos1 = Enum.map(mov_tipo1, fn m -> m.nombre end)
        mov_tipo2    = movimientos_del_tipo(tipo2, movimientos_pool)
                       |> Enum.reject(fn m -> m.nombre in ya_elegidos1 end)
                       |> Enum.take_random(1)
        # 2 movimientos de cualquier tipo
        ya_elegidos2 = ya_elegidos1 ++ Enum.map(mov_tipo2, fn m -> m.nombre end)
        otros        = movimientos_pool
                       |> Enum.reject(fn m -> m.nombre in ya_elegidos2 end)
                       |> Enum.take_random(2)
        mov_tipo1 ++ mov_tipo2 ++ otros
    end
  end


  # PRIVADAS


  # Genera un Pokémon completo a partir de una especie aleatoria
  defp generar_pokemon(dueno, especies, movimientos_pool, probabilidades) do

    especie = Enum.random(especies)

    rareza = sortear_rareza(probabilidades)

    stats = calcular_estadisticas(especie, rareza)

    movimientos = asignar_movimientos(especie.tipos, movimientos_pool)
                  |> Enum.map(fn m ->
                    %Movimiento{
                      nombre:     m.nombre,
                      tipo:       m.tipo,
                      poder_base: m.poder_base
                    }
                  end)


    %Pokemon{
      id:            generar_id(),
      especie:       especie.especie,
      dueno_original: dueno,
      rareza:        rareza,
      ataque:        stats.ataque,
      defensa:       stats.defensa,
      velocidad:     stats.velocidad,
      movimientos:   movimientos
    }
  end

  defp movimientos_del_tipo(tipo, movimientos_pool) do
    Enum.filter(movimientos_pool, fn m -> m.tipo == tipo end)
  end


  defp generar_id do
    :rand.uniform(99999 - 10000 + 1) + 9999
  end

  
  defp rango_rareza(:comun), do: {2, 8}
  defp rango_rareza(:raro),  do: {10, 20}
  defp rango_rareza(:epico), do: {25, 40}

end
