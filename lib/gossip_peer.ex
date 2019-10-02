defmodule GossipPeer do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:receive, msg}, state) do
    # IO.puts("receive starting #{state.name}")
    seen_count = state.seen_count + 1

    if (seen_count == 1) do
      #Start gossip mode on the peer asynchronously
      spawn_link(__MODULE__,:gossip_cycle,[state])

      count = :ets.update_counter(:datastore, "count", {2,1})

      # print for every x nodes that received msg
      if(rem(count,100)==0) do
        IO.puts("Nodes seen message = #{count}")
      end
      total_nodes = elem(Enum.at(:ets.lookup(:datastore, "total_nodes"),0),1)
      if count == total_nodes do
        start_time = elem(Enum.at(:ets.lookup(:datastore, "start_time"),0),1)
        endTime = System.monotonic_time(:millisecond) - start_time
        IO.puts "Convergence time = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
    end

    if (seen_count >= 10) do
      # IO.puts "#{state.name} seen msg 10 times"
      exit(:normal)
    end

    updated_state = Map.put(state,:seen_count, seen_count)
    # IO.puts("receive ending #{state.name}")
    {:noreply, updated_state}
  end

  def gossip_cycle(state) do
    # IO.puts "inside gossip #{curr_index} has seen #{msg_seen} messages"
    curr_index = state.name
    neighbors = Topology.getNeighbor(state.topology, curr_index)

    target = Integer.to_string(find_random_neighbor(neighbors))
    # IO.puts("#{curr_index} sending to #{target}")
    GenServer.cast(via_tuple(target), {:receive,:ok})
    gossip_cycle(state)
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
