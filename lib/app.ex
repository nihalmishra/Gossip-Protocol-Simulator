defmodule App do
  use GenServer

  def main(args) do
    [numNodes, topology, algorithm] = args
    Registry.start_link(keys: :unique, name: :my_reg)
    num_peer = String.to_integer(numNodes)
    peer_list = Enum.to_list(1..num_peer)
    create_gossip_peer(peer_list)
    start_time = System.monotonic_time(:millisecond)
    time_table = :ets.new(:time_table, [:set, :public, :named_table])
    :ets.insert(time_table, {"count",0})
    start_gossip(peer_list, start_time)
  end

  def init(state) do
    {:ok, state}
  end

  def create_gossip_peer(peer_list) do
    Enum.map peer_list, fn peer ->
      {:ok, pid} = GenServer.start_link(GossipPeer, %{msg_seen: 0, name: peer, total_nodes: length(peer_list)}, name: via_tuple(Integer.to_string(peer)))
    end
  end

  def start_gossip(peer_list,start_time) do
    random_node = Enum.random(peer_list)
    # GenServer.cast(via_tuple(Integer.to_string(random_node)),{:receive,start_time})
    GenServer.cast(via_tuple(Integer.to_string(Enum.at(peer_list,50))),{:receive,start_time})
  end

  defp via_tuple(peer_name) do
    {:via, Registry, {:my_reg, peer_name}}
  end
end
