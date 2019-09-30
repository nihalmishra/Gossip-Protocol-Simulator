defmodule App do
  use GenServer

  def main do
    Registry.start_link(keys: :unique, name: :my_reg)
    num_peer = 10
    peer_list = Enum.to_list(1..num_peer)
    create_gossip_peer(peer_list)
    start_time = System.monotonic_time(:millisecond)
  end

  def init(state) do
    {:ok, state}
  end

  def create_gossip_peer(peer_list) do
    msg_seen = 0
    Enum.map peer_list, fn peer ->
      {:ok, pid} = GenServer.start_link(GossipPeer, msg_seen, name: via_tuple(Integer.to_string(peer)))
      IO.inspect(pid)
    end
  end

  def startGossip(peer_list,start_time) do
    IO.puts "starting gossip"
    GenServer.cast(via_tuple(Integer.to_string(Enum.at(peer_list,0))),{:gossip,start_time})
    # Helper.span(peer_list, start_time)
  end

  defp via_tuple(peer_name) do
    {:via, Registry, {:my_reg, peer_name}}
  end
end
