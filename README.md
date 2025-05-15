# The infrastructure

The [docker-compose](./docker-compose.yml) it runs a simple RabbitMQ cluster with 3 nodes.

# Step to reproduce the issue

1. Run `docker compose up`
1. Wait that the dockers to set up, like a minute
1. Once the RabbitMQ cluster is ready run the perf test in java

```sh
docker run -it --rm --network="rabbitmq-cluster" pivotalrabbitmq/stream-perf-test:latest -fvs foo-bar --uris rabbitmq-stream://guest:guest@rabbitmq1:5552 -st test-2 -x 1 -y 0
```

1. After a while, usually some seconds but sometimes a minute, in one or both replicas (`rabbitmq2` or `rabbitmq3`) you should see an error with `accept_chunk_out_of_order`

```sh
docker logs rabbitmq2 | grep accept_chunk_out_of_order
docker logs rabbitmq3 | grep accept_chunk_out_of_order
```

Example of the output:

```sh
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0> ** Reason for termination ==
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0> ** {{accept_chunk_out_of_order,42829465,42829465},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>     [{osiris_log,accept_chunk,2,[{file,"src/osiris_log.erl"},{line,808}]},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>      {osiris_replica,'-handle_incoming_data/3-fun-0-',2,
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>                      [{file,"src/osiris_replica.erl"},{line,570}]},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>      {lists,foldl,3,[{file,"lists.erl"},{line,2146}]},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>      {osiris_replica,handle_incoming_data,3,
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>                      [{file,"src/osiris_replica.erl"},{line,569}]},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>      {gen_server,try_handle_info,3,[{file,"gen_server.erl"},{line,2345}]},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>      {gen_server,handle_msg,6,[{file,"gen_server.erl"},{line,2433}]},
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0>      {proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,329}]}]}
2025-05-15 08:57:59.691750+00:00 [error] <0.2780.0> 
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>   crasher:
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     initial call: osiris_replica:init/1
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     pid: <0.2780.0>
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     registered_name: []
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     exception exit: {accept_chunk_out_of_order,42829465,42829465}
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>       in function  osiris_log:accept_chunk/2 (src/osiris_log.erl, line 808)
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>       in call from osiris_replica:'-handle_incoming_data/3-fun-0-'/2 (src/osiris_replica.erl, line 570)
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>       in call from lists:foldl/3 (lists.erl, line 2146)
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>       in call from osiris_replica:handle_incoming_data/3 (src/osiris_replica.erl, line 569)
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>       in call from gen_server:try_handle_info/3 (gen_server.erl, line 2345)
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>       in call from gen_server:handle_msg/6 (gen_server.erl, line 2433)
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     ancestors: [osiris_server_sup,osiris_sup,<0.1646.0>]
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     message_queue_len: 2
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     messages: [{'$gen_cast',{committed_offset,42829427}},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                   {'EXIT',<25744.2447.0>,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                       {{badmatch,{error,einval}},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                        [{osiris_replica_reader,setopts,3,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                             [{file,"src/osiris_replica_reader.erl"},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                              {line,390}]},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                         {osiris_replica_reader,do_sendfile0,1,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                             [{file,"src/osiris_replica_reader.erl"},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                              {line,342}]},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                         {osiris_replica_reader,handle_cast,2,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                             [{file,"src/osiris_replica_reader.erl"},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                              {line,213}]},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                         {gen_server,try_handle_cast,3,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                             [{file,"gen_server.erl"},{line,2371}]},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                         {gen_server,handle_msg,6,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                             [{file,"gen_server.erl"},{line,2433}]},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                         {proc_lib,init_p_do_apply,3,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                             [{file,"proc_lib.erl"},{line,329}]}]}}]
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     links: [<0.1650.0>]
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     dictionary: [{rand_seed,{#{type => exsss,next => #Fun<rand.0.40079776>,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                                 bits => 58,uniform => #Fun<rand.1.40079776>,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                                 uniform_n => #Fun<rand.2.40079776>,
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                                 jump => #Fun<rand.3.40079776>},
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>                               [129485132136450126|59260559737362325]}}]
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     trap_exit: true
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     status: running
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     heap_size: 196650
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     stack_size: 29
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>     reductions: 37189241
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0>   neighbours:
2025-05-15 08:57:59.697121+00:00 [error] <0.2780.0> 
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>     supervisor: {local,osiris_server_sup}
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>     errorContext: child_terminated
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>     reason: {accept_chunk_out_of_order,42829465,42829465}
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>     offender: [{pid,<0.2780.0>},
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>                {id,"__test-2_1747299414973352688"},
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>                {mfargs,{osiris_replica,start_link,undefined}},
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>                {restart_type,temporary},
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>                {significant,false},
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>                {shutdown,5000},
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>                {child_type,worker}]
2025-05-15 08:57:59.697962+00:00 [error] <0.1650.0>
```

# What We've Observed

It seems this error is specific to RabbitMQ clusters running a stream producer with the filter feature enabled. Turning off the filter feature eliminates the problem. This issue leads to increased latency, instability, and a significant volume of logs.
