defmodule GossipPeer do
  use GenServer

  def init(state) do
    {:ok, state}
  end


  # def handle_call({:receive, start_time},from, state) do
  #   IO.puts("receive starting #{state.name}")
  #   # IO.puts("recieved from #{from}")
  #   msg_seen = state.msg_seen + 1

  #   if (msg_seen == 1) do
  #     spawn_link(__MODULE__,:gossip_cycle,[state,start_time])
  #   end

  #   if (msg_seen >= 10) do
  #     IO.puts "#{state.name} seen msg 10 times"
  #     # exit(:normal)
  #   end
  #   new_state = Map.put(state,:msg_seen, msg_seen)
  #   IO.puts("receive ending #{state.name}")
  #   {:reply, :ok, new_state}
  # end

  def handle_cast({:receive, start_time}, state) do
    # IO.puts("receive starting #{state.name}")
    # IO.puts("recieved from #{from}")
    msg_seen = state.msg_seen + 1

    if (msg_seen == 1) do
      spawn_link(__MODULE__,:gossip_cycle,[state,start_time])
      count = :ets.update_counter(:time_table, "count", {2,1})
      if(rem(count,100)==0) do
        IO.puts("Nodes seen message : #{count}")
      end
      if count == state.total_nodes do
        endTime = System.monotonic_time(:millisecond) - start_time
        IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
    end

    if (msg_seen >= 10) do
      # IO.puts "#{state.name} seen msg 10 times"
      exit(:normal)
    end
    new_state = Map.put(state,:msg_seen, msg_seen)
    # IO.puts("receive ending #{state.name}")
    {:noreply, new_state}
  end



    # if msg_seen == 1 do
    #   # IO.puts "#{state.name} ------------------reached"
    #   # spawn_link(__MODULE__,:gossipContinue,[state.neighbours,state.name,start_time])
    #   # IO.puts "after spawn"
    #   count = :ets.update_counter(:time_table, "count", {2,1})
    #   if count == (state.total_nodes + 100) do
    #     endTime = System.monotonic_time(:millisecond) - start_time
    #     IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
    #     System.halt(1)
    #   end
    # end


  def gossip_cycle(state, start_time) do
    # :timer.sleep(100)
    # IO.puts "inside gossip #{curr_index} has seen #{msg_seen} messages"
    curr_index = state.name
    neighbours = Topology.getNeighbor("randhoneycomb", curr_index, state.total_nodes)

    target = Integer.to_string(find_random_neighbour(neighbours, curr_index))
    # IO.puts("#{curr_index} sending to #{target}")
    GenServer.cast(via_tuple(target), {:receive,start_time})
    gossip_cycle(state, start_time)
  end

  def find_random_neighbour(neighbours,name) do
    # if Enum.empty?(neighbours) do
    #   Process.exit(self(),:normal)
    # end
    next = Enum.random(neighbours)
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
