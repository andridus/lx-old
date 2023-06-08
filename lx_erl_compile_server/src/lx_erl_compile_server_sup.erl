-module(lx_erl_compile_server_sup).
-behaviour(supervisor).

-export([start_link/1, start_socket/0]).
-export([init/1]).

start_link(Port) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, [Port]).

init([Port]) ->
  {ok, ListenSocket} = gen_tcp:listen(Port, [{active, once}]),
  %% We start our pool of empty listeners
  %% we must do this in another, as it is a blocking process
  spawn_link(fun empty_listeners/0),
  {ok, { {simple_one_for_one, 60, 3600},
      [
        {lx_erl_compile_server, {lx_erl_compile_server, start_link, [ListenSocket]}, temporary, 1000, worker, [lx_erl_compile_server]}
      ]
    }}.
start_socket() ->
  supervisor:start_child(?MODULE, []).

empty_listeners() ->
  [start_socket() || _ <- lists:seq(1,20)],
  ok.
