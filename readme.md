### Lx lang
 Lx Lang will compile all Elixir file (.ex) to BeamVM and the compiler to an executable file independent of Beam.
 It is developed with V Lang

## Why Lx
 - To compile faster to BeamVM
 - To make executable without beam

### Goals
 - Fast compiler Elixir files to Beam VM
 - Compile Elixir File to native code (via V)


### To do List
 - [x] Lexing
 - [x] Parser file in AST
 - [x] Binary Expressions
 - [x] Assignment Statement
 - [x] Function Statement
 - [x] Module Statement
 - [x] Symbols table
 - [ ] Binary Erlang CodeGen
 - [ ] Binary Vlang CodeGen
 - [ ] Recreate compiler with Lx Lang

## About compilation
1. List all files to compile, follow ther order from the module that has a 'main' function
2. Compile all dependency files, at last the main module.
3. Set summarized information about headers functions was defined in modules.
4. Defer compilation warning. if is compiles many files and check dependency error, just wait to all files was compiled, and check if error persist, so thown.
5. Parallel compilation. Using methods above to compile in parallel
6. Using the TinyCC to compile to native

## Dependency between files

Imagine three files:

```elixir
  a.ex
  defmodule A do
    def main do
      B.operation()
    end
  end

  b.ex
  defmodule B do
    def operation do
      1
    end
    def operation_two do
      C.operation()
    end
  end

  c.ex
  defmodule C do
    def operation do
      2
    end
  end
```
  In order to compile A module, we need ensure that B module is already compiled, that be we need ensure C module is already compiled.
  Ir order of compilation defined by requirement of the main module, all warnings about compilation in call extern function is defer until finish all compilations that will be re evaluated.



### To Execute
1. Install gcc or tinycc
2. Install V
3. Install Erlang
4. On terminal, execute
  `$ v run . repl`
