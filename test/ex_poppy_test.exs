defmodule ExPoppyTest do
  use ExUnit.Case
  doctest ExPoppy

  @input_file "test/test.bloom"
  @output_file "test/mytestfile.bloom"

  setup do
    if File.exists?(@output_file) do
      File.rm(@output_file)
    end

    on_exit(fn ->
      if File.exists?(@output_file) do
        File.rm(@output_file)
      end
    end)

    :ok
  end

  test "Create default filter" do
    ref = ExPoppy.new(10000, 0.01)
    assert is_reference(ref)
    assert ExPoppy.version(ref) == 2
    assert ExPoppy.capacity(ref) == 10000
    assert ExPoppy.fpp(ref) == 0.01
    assert ExPoppy.count_estimate(ref) == 0
  end

  test "Create DCSO filter" do
    ref = ExPoppy.with_version(1, 10000, 0.01)
    assert ExPoppy.version(ref) == 1
    assert ExPoppy.capacity(ref) == 10000
    assert ExPoppy.fpp(ref) == 0.01
    assert ExPoppy.count_estimate(ref) == 0
  end

  test "Create filter with parameters " do
    ref = ExPoppy.with_params(2, 10000, 0.01, 3)
    assert ExPoppy.version(ref) == 2
    assert ExPoppy.capacity(ref) == 10000
    assert ExPoppy.fpp(ref) == 0.01
    assert ExPoppy.count_estimate(ref) == 0
  end

  test "loading a NX filter" do
    ref = ExPoppy.load_filter("nx.bloom")
    assert ref == {:error, "IO error: No such file or directory (os error 2)"}
  end

  test "loading an existing filter" do
    ref = ExPoppy.load_filter(@input_file)
    assert ExPoppy.version(ref) == 1
    assert ExPoppy.capacity(ref) == 10000
    assert ExPoppy.fpp(ref) == 0.01
    assert ExPoppy.count_estimate(ref) == 3
  end

  test "saving filter to a file" do
    ref = ExPoppy.with_params(2, 10000, 0.01, 3)
    assert ExPoppy.version(ref) == 2
    assert ExPoppy.capacity(ref) == 10000
    assert ExPoppy.fpp(ref) == 0.01
    assert ExPoppy.count_estimate(ref) == 0
    assert ExPoppy.save(ref, @output_file) == {}
    assert File.exists?(@output_file)
  end

  test "inserting and checking strings on a bloom filter" do
    strings =
      Enum.reduce(1..50, [], fn x, acc ->
        [
          (Enum.to_list(?A..?Z) ++ Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9))
          |> Enum.take_random(x)
          |> to_string()
          | acc
        ]
      end)

    ref = ExPoppy.with_params(2, 10000, 0.01, 3)

    Enum.map(strings, &ExPoppy.insert_str(ref, &1))
    assert ExPoppy.count_estimate(ref) == 50

    Enum.map(strings, fn x ->
      assert ExPoppy.contains_str(ref, x)
    end)

    assert ExPoppy.contains_str(
             ref,
             (Enum.to_list(?A..?Z) ++ Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9))
             |> Enum.take_random(20)
             |> to_string()
           ) == false
  end
end
