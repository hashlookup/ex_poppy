# ExPoppy

ExPoppy is a NIF wrapping the poppy RUST library https://github.com/hashlookup/poppy/ :
  - It allows for the creation and query of poppy and DCSO bloom filters
  - It comes with supervisor friendly worker that can hold a bloom filter in memory and answer client queries.

## Installation

The package can be installed by adding `ex_poppy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_poppy, "~> 0.1.4"}
  ]
end
```

Documentation and package details can be found at <https://hexdocs.pm/ex_poppy>.