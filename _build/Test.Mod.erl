-module('Test.Mod').
-export([sum/3]).

-spec sum(int(), float(), float()) -> float().
sum(A, B, C) -> A + B.
