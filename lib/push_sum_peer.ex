defmodule PushSumPeer do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:receive, s,w}, state) do
    # IO.puts("receive starting #{state.name}")
    s = s + state.s
    w = w + state.w

    change = abs(s/w - state.s/state.w)

    no_change_counter =
      if(change  < :math.pow(10,-10)) do
        state.no_change_counter+1
      else
        0
      end

    if(no_change_counter == 3) do
      count = :ets.update_counter(:datastore, "count", {2,1})
      IO.puts("no change 3 times")
      if(rem(count,10)==0) do
        IO.puts("Actors terminated = #{count}")
      end
      total_nodes = elem(Enum.at(:ets.lookup(:datastore, "total_nodes"),0),1)
      if count == total_nodes do
        start_time = elem(Enum.at(:ets.lookup(:datastore, "start_time"),0),1)
        endTime = System.monotonic_time(:millisecond) - start_time
        IO.puts "Convergence time = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
      exit(:normal)
    end

    pushsum_send(state,s,w)

    updated_state = Map.put(state,:s, s/2)
    updated_state = Map.put(state,:w, w/2)
    updated_state = Map.put(state,:no_change_counter, no_change_counter)
    {:noreply, updated_state}
  end

  @spec pushsum_send(atom | %{name: any, topology: <<_::32, _::_*8>>}, number, number) :: :ok
  def pushsum_send(state,s,w) do
    curr_index = state.name
    # IO.puts "inside gossip #{curr_index} has seen #{msg_seen} messages"
    neighbors = Topology.getNeighbor(state.topology, curr_index)

    target = Integer.to_string(find_random_neighbor(neighbors))
    # IO.puts("#{curr_index} sending to #{target}")
    GenServer.cast(via_tuple(target), {:receive, s/2, w/2})
  end

  def find_random_neighbor(neighbors) do
    # if Enum.empty?(neighbors) do
    #   Process.exit(self(),:normal)
    # end
    next = Enum.random(neighbors)
  end

  # def handle_cast({:update_neighbours,current_neighbours},state) do
  #   new_state = Map.put(state,:neighbours,current_neighbours)
  #   if Enum.empty?(state.neighbours) do
  #     Process.exit(self(),:normal)
  #   end
  #   {:noreply,new_state}
  # end

  defp via_tuple(peer_name) do
    {:via, Registry, {:my_reg, peer_name}}
  end
end
