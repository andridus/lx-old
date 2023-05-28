-module('Test.Mod').
-export([sum/3]).

-spec sum(integer(), float(), float()) -> float().
sum(A, B, C) -> A + B + C.
