#!/bin/bash
erl -pa lx_erl_compile_server/_build/default/lib/lx_erl_compile_server/ebin -eval "application:start(lx_erl_compile_server)" -noshell