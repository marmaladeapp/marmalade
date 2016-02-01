class Array
  def mode
    counter = Hash.new(0)
    # this creates a new, empty hash with no keys, but makes all defalt values zero. it will be used to store
    # the information from the array, such that the keys will be each unique number from the array (IOW, if there
    # are two or more 4's in the array, there will just be one key that is a 4), and the value for each key will
    # be the number of times that integer appears in the array.
    self.each do |i|
      counter[i] += 1
    end
    # this interates throught the array, and for each element it creates a key for that integer (if it hasn't been
    # created already) and basically pushes a +1 to the value of that key. remember, the values all start at zero
    # because the "Hash.new" language included "(0)" at the end.
    mode_array = []
    # this creates an empty array, to be filled with the most repeated number(s) from the array.
    # this will be the array that is returned at the end of the method.
    counter.each do |k, v|
      if v == counter.values.max
        mode_array << k
      end
    end
    # this loop iterates through the counter array. for each key/value pair, it compares the value to
    # the high value in the array, and if the value it's comparing is equal to the high value, it
    # adds to the mode array the key associated with that value.
    mode_array.sort
    # this returns the mode array (sorted)
  end
end