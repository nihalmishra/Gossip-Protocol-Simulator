# **Gossip Protocol Simulator**

## **Group Member Names -**

Saurabh Kumar Prasad

Nihal Mishra

## **Steps to run code on Windows OS**

1. Open Terminal
2. cd mishra_prasad/app
3. Generate executable with `mix escript.build`
4. Run with `escript ./app numNodes topology algorithm` where topology is one of `full/line/rand2D/3Dtorus/honeycomb/randhoneycomb` and algorithm is one of `gossip/push-sum`

## **Gossip Protocol**

Gossip algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.

Apart from Gossip, we also implemented the push-sum algorithm.

## **Network Topologies**

We handled the following network topologies and tested the convergence time for each of them. The actual network topology plays a critical role in the dissemination speed of Gossip protocols.

1. Full Network
2. Line
3. Random 2D Grid
4. 3D Torus Grid
5. Honeycomb
6. Random Honeycomb

## **What is working**

Gossip and Push-Sum algorithms are simulated succesfully for all the above topologies with varying convergence times due to the inherent nature of said topologies, which govern the spread of messages. An instance would be where Line topolgy has consistenetly the highest time to converge values while Random Honeycomb or 3D Torus fair far better.

## **Largest network handled**

### Gossip Protocol

| Topology    | Network Size     | Convergence time (ms)|
| ----------- | -----------      | ---------------------|
| Full Network | 10000| 123859|
| Line | 2500|193063|
| Random 2D Grid | 7000|11828|
| 3D Torus Grid | 25000|50453|
| Honeycomb | 25000|208609|
| Random Honeycomb | 150000|17658|

### Push Sum Algorithm

| Topology    | Network Size     |Convergence time (ms)|
| ----------- | -----------      |---------------------|
| Full Network | 1500|73563|
| Line | 400|666281|
| Random 2D Grid | 3000|99172|
| 3D Torus Grid | 1500|86391|
| Honeycomb | 1500|311297|
| Random Honeycomb | 150000|237671|
