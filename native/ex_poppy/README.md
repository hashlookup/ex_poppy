# NIF for Elixir.ExPoppy

## To build the NIF module:

- Your NIF will now build along with your project.

## To load the NIF:

```elixir
defmodule ExPoppy do
  use Rustler, otp_app: :ex_poppy, crate: "ex_poppy"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: err()
end
```

## Examples

[This](https://github.com/rusterlium/NifIo) is a complete example of a NIF written in Rust.
