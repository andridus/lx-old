defmodule CaseAndGuardsTest do

  def number?(_x :: integer) :: boolean do
    true
  end
  def number?(_x :: any) :: boolean do
    false
  end

  def main() do
    # ## TEST 1: Simple case
    x0 = 1
    case x0 do
      1 -> true
      2 -> false
    end

    # # # # # TEST 2: simple case with any clause
    x1 = 1
    case x1 do
      1 -> true
      _int -> false
    end

    # # # # TEST 3: simple case with scoped var
    x2 = 1
    case x2 do
      _x -> true
      _ -> false
    end

    # # # TEST 4: simple case with scoped return var
    # # ## TODO: Fix type errors on clause
    x3 = 1
    case x3 do
      x -> x
      _ -> 0
    end

    # # # # # ## TEST 5:  Case with when (guard)
    x4 = 1
    case x4 do
      x when x == 1 -> true
      _ -> false
    end

    # # # # # # ## TEST 6: Case with , (comma) guard
    x5 = 1
    case x5 do
      x, x == 1 -> true
      _ -> false
    end

    # # # # # ## TEST 7: Guard [comma] with functions
    x6 = 1
    case x6 do
      x, number?(x) -> true
      _ -> false
    end

    # # # # # # ## TEST 8: Guard [when] with functions
    x7 = 1
    case x7 do
      x when number?(x) -> true
      _ -> false
    end

    # # # # # ## TEST 9: case with or clauses
    x8 = 1
    case x8 do
      2 | 1 | 0 -> true
      _ -> false
    end

    # # # # ## TEST 10: case with or clauses and guards inside
    # x9 = 1
    # case x9 do
    #  y, y == 1 | 2 | x, x == 10 | 1  -> true
    #   _ -> false
    # end


    :ok
  end
end
