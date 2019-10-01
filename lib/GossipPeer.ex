defmodule GossipPeer do
  # use DynamicSupervisor
  use GenServer

  # def start_link(node_list) do
  #   GenServer.start_link(__MODULE__, node_list, name: __MODULE__)
  # end

  def init(state) do
    # IO.inspect state
    {:ok, state}
  end

  def handle_cast({:receive, start_time}, state) do
    curr_index = state.name
    # IO.puts("receive starting #{curr_index}")
    msg_seen = state.msg_seen
    msg_seen = msg_seen + 1
    gossip_mode = state.gossip_mode
    IO.puts("#{curr_index}")
    if (gossip_mode == false) do
      GenServer.cast(self(),{:gossip,start_time})
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

    # if msg_seen == 1 do
    #   # IO.puts "starting process #{state.name}"
    #   spawn_link(__MODULE__,:gossipContinue,[state.neighbours,state.name,start_time])
    # end

    if msg_seen >= 10 do
      # IO.puts "killing process __________#{state.name}"
      exit(:normal)
    end

    gossip_mode = true
    new_state = Map.put(state,:msg_seen,msg_seen)
    new_state = Map.put(state,:gossip_mode,gossip_mode)
    # IO.puts("receive ending #{curr_index}")
    {:noreply, new_state}
  end

  def handle_cast({:gossip,start_time},state) do
    curr_index = state.name
    # IO.puts("cast gossip starting #{curr_index}")
    # :timer.sleep(500)
    msg_seen = state.msg_seen
    # msg_seen = msg_seen+1
    curr_index = state.name
    total_nodes = state.total_nodes
    # IO.puts "inside gossip #{curr_index} has seen #{msg_seen} messages"
    # IO.puts "#{curr_index} received msg"
    # IO.inspect total_nodes
    neighbours = Topology.getNeighbor("line", curr_index, total_nodes)

    # IO.inspect neighbours
    # IO.puts "@ #{state.name} , msg_cnt=#{msg_seen}"
    # if msg_seen == 1 do
    #   # IO.puts "#{state.name} ------------------reached"
    #   # spawn_link(__MODULE__,:gossipContinue,[state.neighbours,state.name,start_time])
    #   # IO.puts "after spawn"
    #   count = :ets.update_counter(:time_table, "count", {2,1})
    #   if count == state.total_nodes do
    #     endTime = System.monotonic_time(:millisecond) - start_time
    #     IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
    #     System.halt(1)
    #   end

    # end

    # # if msg_seen == 1 do
    # #   # IO.puts "starting process #{state.name}"
    # #   spawn_link(__MODULE__,:gossipContinue,[state.neighbours,state.name,start_time])
    # # end

    # if msg_seen >= 10 do
    #   # IO.puts "killing process __________#{state.name}"
    #   exit(:normal)
    # end
    # new_state = Map.put(state,:msg_seen,msg_seen)
    target = Integer.to_string(find_random_neighbour(neighbours, curr_index))
    IO.puts("#{curr_index} sending to #{target}")
    GenServer.cast(via_tuple(target), {:receive,start_time})
    GenServer.cast(self(),{:gossip,start_time})
    # GenServer.cast(self(),{:gossip,start_time})
    # {:noreply,new_state}
    # IO.puts("cast gossip ending #{curr_index}")
    {:noreply,state}
  end

  def handle_cast({:update_neighbours,current_neighbours},state) do
    new_state = Map.put(state,:neighbours,current_neighbours)
    if Enum.empty?(state.neighbours) do
      Process.exit(self(),:normal)
    end
    {:noreply,new_state}
  end

  # gossip continue
  def gossipContinue(neighbours,name,start_time) do
    {next_one,current_neighbours} = find_random_neighbour(neighbours,name)
    # IO.puts "#{name} ----> #{next_one}"
    GenServer.cast(next_one,{:gossip,start_time})
    gossipContinue(current_neighbours,name,start_time)
  end

  def find_random_neighbour(neighbours,name) do
    # if Enum.empty?(neighbours) do
    #   Process.exit(self(),:normal)
    # end
    next = Enum.random(neighbours)
    # if aliveORnot(next) do
    #   {next,neighbours}
    # else
    #   neighbours = neighbours -- [next]
    #   GenServer.cast(name,{:update_neighbours,neighbours})
    #   randomNeighbour(neighbours,name)
  end
  # def add_node(node_list) do
  #   # child_spec = {ComputationWorker, worker_name}
  #   count = 0
  #   Enum.map node_list, fn _node ->
  #     {:ok, pid} = GenServer.start_link(__MODULE__, count)
  #   end
  # end

  # def remove_node(worker_pid) do
  #   GenServer.terminate_child(__MODULE__, worker_pid)
  # end

  defp via_tuple(peer_name) do
    {:via, Registry, {:my_reg, peer_name}}
  end
end
