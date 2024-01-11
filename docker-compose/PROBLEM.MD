I have a Problem.

When running my blockchain node locally, I can execute the RPC method over HTTP successfuly using `http://127.0.0.1:8554`.

Output from local node start:

```
24-01-08T11:43:04Z Loaded 9069 addresses from peers.dat  28ms
2024-01-08T11:43:04Z init message: Starting network threads...
2024-01-08T11:43:04Z net thread start
2024-01-08T11:43:04Z addcon thread start
2024-01-08T11:43:04Z dnsseed thread start
2024-01-08T11:43:04Z opencon thread start
2024-01-08T11:43:04Z [ain_grpc] Starting JSON RPC server at 0.0.0.0:8551
2024-01-08T11:43:04Z msghand thread start
2024-01-08T11:43:04Z [ain_grpc] Starting WebSockets server at 0.0.0.0:8553
```

But when running it inside a container and requesting from another container instance over HTTP, the node returns using `http://defid:8551`:

```
Response: {"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"},"id":"1"}
```

Output from docker node start:

```
defid            | 2024-01-08T11:59:15Z Loaded 9073 addresses from peers.dat  246ms
defid            | 2024-01-08T11:59:15Z init message: Starting network threads...
defid            | 2024-01-08T11:59:15Z net thread start
defid            | 2024-01-08T11:59:15Z dnsseed thread start
defid            | 2024-01-08T11:59:15Z [ain_grpc] Starting JSON RPC server at 0.0.0.0:8551
defid            | 2024-01-08T11:59:15Z addcon thread start
defid            | 2024-01-08T11:59:15Z msghand thread start
defid            | 2024-01-08T11:59:15Z opencon thread start
defid            | 2024-01-08T11:59:15Z [ain_grpc] Starting WebSockets server at 0.0.0.0:8553
```

As you can see, in the first request locally, I am using the port `8554`. It's nowhere in the logs, but I found it somewhere else.

But when requesting in containers, I use the port `8551` which is the RPC Port in the log output on node start.

I know that the node has in fact 2 RPCs. One is the native chain and the other an EVM chain.

I use this command to start the node:

```
defid -blocksonly -rpcthreads=1 -rpcallowip="172.24.0.0/16" -rpcbind="0.0.0.0" -wsbind="0.0.0.0" -grpcbind="0.0.0.0" -ethrpcbind="0.0.0.0" -rpcuser=defid-user -rpcpassword=mfemrkn564kjnfg34
```

And I found this documentation as well:

```
- `rpcbind` + `ethrpcbind`: changes address to bind JSON-RPC servers to. Set this to `0.0.0.0/0` to make the server publicly accessibly.
- `rpcallowip`: whitelist for IP addresses allowed to use the JSON-RPC server. Set this to `0.0.0.0/0` to open server to the public.
- `rpcport` + `ethrpcport` + `grpcport` + `wsport`: change JSON-RPC server ports.
- `rpcuser` + `rpcpassword`: set username/password for JSON-RPC server.
- `txindex`: creates index of every transaction. Allows you to query any transaction without knowing the block hash. Useful for blockchain analysis and explorer nodes.
- `walletfastselect` + `walletcoinopteagerselect`: creates a transaction quicker, but may not use the most optimal UTXO. Useful for masternodes and wallets with a large number of UTXOs.
```

I know, that I need to make the request to the native RPC. But I really struggle on how to accomplish this.
