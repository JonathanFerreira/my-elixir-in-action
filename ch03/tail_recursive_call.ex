# If the last thing a function does is call another function (or itself),
# you’re dealing with a tail call:
# Tail recursion doesn’t consume additional memory,

# def original_fun(...) do
#   ...
#   another_fun(...)    ①  
# end

# The following code ISN'T a tail call.
# This is because the call to another_fun isn’t the last thing done in the fun function.
# After another_fun finishes, you have to increment its result by 1 to compute the final result of fun.

# def fun(...) do
#   1 + another_fun(...)    ①  
# end

# Converting ListHelper to a tail-recursive function

defmodule ListHelper do
  def sum(list) do
    do_sum(0, list)
  end

  defp do_sum(current_sum, []) do
    current_sum
  end

  defp do_sum(current_sum, [head | tail]) do
    new_sum = current_sum + head
    do_sum(new_sum, tail) # tail call
  end
end
