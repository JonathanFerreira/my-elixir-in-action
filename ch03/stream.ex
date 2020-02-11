# A stream is a lazy enumerable, which means it produces the actual result on demand

# creates a stream
stream = [1, 2, 3] |> Stream.map(fn x -> 2 * x end)
# print stream one by time
Enum.to_list(stream)

# In this example we don't need read the entire file in memory
# and after iterate each line
# Using stream we can read one line by time and parse.
# This example we filter lines with length > 100
defmodule ReadFile do
  defp stripped_lines!(path) do
    path
    |> File.stream!
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  def large_lines!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Enum.filter(&String.length(&1) > 100)
  end

  def lines_length!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Enum.map(&String.length/1)
  end

  def longest_line_length!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Stream.map(&String.length/1)
    |> Enum.max()
  end


  def longest_line!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Enum.max_by(&String.length/1)
  end

  def words_per_line!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Enum.map(&word_count/1)
  end

  defp word_count(string) do
    string
    |> String.split()
    |> length()
  end

  def smallest_line_length!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Stream.map(&String.length/1)
    |> Enum.min()
  end

  def smallest_line!(path \\ 'stream_file.txt') do
    path
    |> stripped_lines!
    |> Enum.min_by(&String.length/1)
  end
end
