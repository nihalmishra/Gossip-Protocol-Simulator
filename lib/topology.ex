defmodule Topology do
  def getNeighbor(topology, curr_index, total_nodes) do
    # numNodes = correctNumNodesForGrids(total_nodes, topology)
    # range = 1..numNodes
    # random2dGrid = Enum.shuffle(range) |> Enum.with_index(1)
    neighbors =
      case topology do
        "full" -> get_full_neighbors(total_nodes)

        "line" -> get_line_neighbors(curr_index, total_nodes)

        # "rand2D" -> get_rand2D_neighbors(curr_index, total_nodes, random2dGrid)

        "3Dtorus" -> get_3Dtorus_neighbors(curr_index, total_nodes)

        "honeycomb" -> get_honeycomb_neighbors(curr_index, total_nodes)

        "randhoneycomb" -> get_randhoneycomb_neighbors(curr_index, total_nodes)
      end
      IO.inspect(neighbors)
      neighbors
  end

  defp get_full_neighbors(total_nodes) do
    Enum.to_list 1..total_nodes
  end


  defp get_line_neighbors(curr_index, total_nodes) do
    cond do
      curr_index == 0 -> [1]
      curr_index == total_nodes - 1 -> [total_nodes - 2]
      true -> [(total_nodes - 1), (total_nodes + 1)]
    end
  end

  # def get_rand2D_neighbors(curr_index, total_nodes) do
  #   gridLen = total_nodes |> :math.sqrt() |> trunc()
  #   k = (gridLen / 10) |> :math.ceil() |> trunc()

  #   top = Enum.map(1..k, fn x -> curr_index - x * gridLen end) |> Enum.filter(fn x -> x > 0 end)
  #   bottom = Enum.map(1..k, fn x -> curr_index + x * gridLen end) |> Enum.filter(fn x -> x <= total_nodes end)

  #   right =
  #     if rem(curr_index, gridLen) == 0,
  #       do: [],
  #       else: Enum.take_while((curr_index + 1)..(curr_index + k), fn x -> rem(x, gridLen) != 1 end)

  #   left =
  #     if rem(curr_index, gridLen) == 1,
  #       do: [],
  #       else: Enum.take_while((curr_index - 1)..(curr_index - k), fn x -> rem(x, gridLen) != 0 end)

  #   neighborIndex = top ++ bottom ++ right ++ left |> Enum.map(fn x -> trunc(x) end)

  #   Enum.filter(random2dGrid, fn x -> Enum.member?(neighborIndex, elem(x, 1)) end)
  #   |> Enum.map(fn x -> elem(x, 0) end)
  # end

  defp get_3Dtorus_neighbors(i, total_nodes) do
    cubeLength = total_nodes |> :math.pow(1 / 3)
    total_nodes = :math.pow(cubeLength, 3)

    side1 = if i - 1 <= 0, do: total_nodes + i - 1, else: i - 1
    side2 = if i + 1 > total_nodes, do: i + 1 - total_nodes, else: i + 1
    side3 = if i - cubeLength <= 0, do: total_nodes + i - cubeLength, else: i - cubeLength
    side4 = if i + cubeLength > total_nodes, do: total_nodes + i - cubeLength, else: i + cubeLength
    side5 = if i - cubeLength * cubeLength <= 0, do: total_nodes + i - cubeLength * cubeLength, else: i - cubeLength * cubeLength
    side6 = if i + cubeLength * cubeLength > total_nodes, do: total_nodes + i + cubeLength * cubeLength, else: i + cubeLength * cubeLength

    [
      side1,
      side2,
      side3,
      side4,
      side5,
      side6
    ]
  end

  defp get_honeycomb_neighbors(curr_index, total_nodes) do
      width = :math.sqrt(total_nodes) |> :math.ceil() |> :math.pow(2) |> trunc()
      row = div(curr_index, width)
      neighbors1 =
        cond do
          rem(row, 2) == 0 && rem(curr_index,2)==0 -> curr_index + 1
          rem(row, 2) == 0 && rem(curr_index,2)==1 -> curr_index - 1
          rem(row, 2) == 1 && rem(curr_index,2)==0 -> curr_index - 1
          rem(row, 2) == 1 && rem(curr_index,2)==0 -> curr_index + 1
        end
      neighbors2 = curr_index + width
      neighbors3 = curr_index - width
      [
        neighbors1,
        neighbors2,
        neighbors3
      ]
      |> Enum.filter(fn x -> x > 0 && x <= total_nodes end) |> Enum.map(fn x-> trunc(x) end)
  end

  defp get_randhoneycomb_neighbors(curr_index, total_nodes) do
    [Enum.random(1..total_nodes) | get_honeycomb_neighbors(curr_index, total_nodes)]
  end

  def correctNumNodesForGrids(numNodes, topology) do
    case topology do
      "3Dtorus" -> :math.pow(numNodes, 1 / 3) |> :math.ceil() |> :math.pow(3) |> trunc()
      "rand2D" -> :math.sqrt(numNodes) |> :math.ceil() |> :math.pow(2) |> trunc()
      _ -> numNodes
    end
  end

  def get_distance(x1, y1, x2, y2) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end
end

