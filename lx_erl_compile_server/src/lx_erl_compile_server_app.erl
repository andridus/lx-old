%%%-------------------------------------------------------------------
%% @doc lx_erl_compile_server public API
%% @end
%%%-------------------------------------------------------------------

-module(lx_erl_compile_server_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, Port) ->
    lx_erl_compile_server_sup:start_link(Port).

stop(_State) ->
    ok.

%% internal functions
