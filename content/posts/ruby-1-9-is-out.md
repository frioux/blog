---
aliases: ["/archives/49"]
title: "Ruby 1.9 is out!"
date: "2007-12-26T18:54:54-06:00"
tags: ["ruby", "ruby19"]
guid: "http://blog.afoolishmanifesto.com/archives/49"
---
Exciting! It was apparently put up yesterday, on Christmas. What a cool gift right? I looked through the [changed maintained my Mauricio](http://eigenclass.org/hiki.rb?Changes+in+Ruby+1.9) and here are /my/ favorites.

**New literal hash syntax [Ruby2]**

    {a: "foo"}		# => {:a=>"foo"}

**.() and calling Procs without #call/#[] [EXPERIMENTAL]**

You can now do:

    a = lambda{|*b| b} a.(1,2) # => [1, 2]

**Multiple splats allowed**

1.9 allows multiple splat operators when calling a method:

```
def foo(*a)
  a
end

foo(1, *[2,3], 4, *[5,6])                        # => [1, 2, 3, 4, 5, 6]
```

**Mandatory arguments after optional arguments allowed**

```
def m(a, b=nil, *c, d)
  [a,b,c,d]
end
m(1,2)                                         # => [1, nil, [], 2]
```

**Object#tap**

Passes the object to the block and returns it (meant to be used for call chaining).

    "F".tap{|x| x.upcase!}[0] # => "F" # Note that "F".upcase\![0] would fail since upcase! would return nil in this # case.

**Module#attr is an alias of attr\_reader**

Use

```
attr :foo=
```

to create a read/write accessor. (RCR#331)

**Enumerable#cycle**

Calls the given block for each element of the enumerable in a never-ending cycle:

    a = ["a", "b", "c"]
    a.cycle {|x| puts x }  # print, a, b, c, a, b, c,.. forever.

**Enumerable#group\_by**

Groups the values in the enumerable according to the value returned by the block:

    (1..10).group_by{|x| x % 3} # => {0=>[3, 6, 9], 1=>[1, 4, 7, 10], 2=>[2, 5, 8]}

**Enumerable#drop**

Without a block, returns an array with all but the first n elements from the enumeration. Otherwise drops elements while the block returns true (and returns all the elements after it returns a false value):

    a = [1, 2, 3, 4, 5] a.drop(3) # => [4, 5]
    a.drop {|i| i < 3 } # => [3, 4, 5]

**Enumerable#inject (#reduce) without a block**

If no block is given, the first argument to #inject is the name of a two-argument method that will be called; the optional second argument is the initial value:

    [RUBY_VERSION, RUBY_RELEASE_DATE] # => ["1.9.0", "2007-08-03"] (1..10).reduce(:+) # => 55

**Enumerable#count**

It could be defined in Ruby as

    def count(*a) inject(0) do |c, e| if a.size == 1 # suspect, but this is how it works (a[0] == e) ? c + 1 : c else yield(e) ? c + 1 : c end end end

Therefore

    ["bar", 1, "foo", 2].count(1) # => 1 ["bar", 1, "foo", 2].count{|x| x.to_i != 0} # => 2

**Array#nitems**

It is equivalent to selecting the elements that satisfy a condition and obtaining the size of the resulting array:

    %w[1 2 3 4 5 6].nitems{|x| x.to_i > 3}		# => 3

**Block argument to Array#index, Array#rindex [Ruby2]**

They can now take a block to make them work like #select.

    ['a','b','c'].index{|e| e == 'b'} # => 1 ['a','b','c'].index{|e| e == 'c'} # => 2 ['a','a','a'].rindex{|e| e == 'a'} # => 2 ['a','a','a'].index{|e| e == 'b'} # => nil

**Array#combination**

    ary.combination(n){|c| ...}

yields all the combinations of length n of the elements in the array to the given block. If no block is passed, it returns an enumerator instead. The order of the combinations is unspecified.

    a = [1, 2, 3, 4] a.combination(1).to_a #=> \[[1],[2],[3],[4]] a.combination(2).to_a #=> \[[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]] a.combination(3).to_a #=> \[[1,2,3],[1,2,4],[1,3,4],[2,3,4]] a.combination(4).to_a #=> \[[1,2,3,4]] a.combination(0).to_a #=> \[[]]: one combination of length 0 a.combination(5).to_a #=> [] : no combinations of length 5

**Array#permutation**

Operates like #combination, but with permutations of length n.

```
a = [1, 2, 3] a.permutation(1).to_a #=>; \[[1],[2],[3]] a.permutation(2).to_a #=>; \[[1,2],[1,3],[2,1],[2,3],[3,1],[3,2]] a.permutation(3).to_a #=>; \[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]] a.permutation(0).to_a #=>; \[[]]: one permutation of length 0 a.permutation(4).to_a #=>; [] : no permutations of length 4
```

**Array#pop, Array#shift**

They can take an argument to specify how many objects to return:

```
%w[a b c d].pop(2) # =>; ["c", "d"]
```

**Hash preserves order!**

```
RUBY_VERSION                    # => "1.9.0"
h=\{:a=>;1, :b=>;2, :c=>;3, :d=>;4\}  # =>; \{:a=>;1, :b=>;2, :c=>;3, :d=>;4\}
h[:e]=5
h                               # => {:a=>;1, :b=>;2, :c=>;3, :d=>;4, :e=>;5}

h.keys                          # => [:a, :b, :c, :d, :e]
h.values                        # => [1, 2, 3, 4, 5]
h.to_a                          # => \[[:a, 1], [:b, 2], [:c, 3], [:d, 4], [:e, 5]]

```

vs.

```
RUBY_VERSION                    # => "1.8.6"
h={:a=>1, :b=>2, :c=>3, :d=>4}  # => {:a=>1, :b=>2, :c=>3, :d=>4}
h[:e]=5
h                               # => {:e=>5, :a=>1, :b=>2, :c=>3, :d=>4}
h.keys                          # => [:e, :a, :b, :c, :d]
h.values                        # => [5, 1, 2, 3, 4]
h.to_a                          # => \[[:e, 5], [:a, 1], [:b, 2], [:c, 3], [:d, 4]]
```

**Numeric#upto, #downto, #times, #step**

These methods return an enumerator if no block is given:

    a = 10.times a.inject{|s,x| s+x } # => 45 a = [] b = 10.downto(5) b.each{|x| a << x} a # => [10, 9, 8, 7, 6, 5]

**Range#cover?**

    range.cover?(value)

compares value to the begin and end values of the range, returning true if it is comprised between them, honoring #exclude\_end?.

    ("a".."z").cover?("c")                            # => true
    ("a".."z").cover?("5")                            # => false

**Limit input in IO#gets, IO#readline, IO#readlines, IO#each\_line, IO#lines, IO.foreach, IO.readlines, StringIO#gets, StringIO#readline, StringIO#each, StringIO#readlines**

These methods accept an optional integer argument to specify the maximum amount of data to be read. The limit is specified either as the (optional) second argument, or by passing a single integer argument (i.e. the first argument is interpreted as the limit if it's an integer, as a line separator otherwise).

**IO#ungetc, StringIO#ungetc**

Allows to push back an arbitrarily large character.

**Seven predicate methods where added for the weekdays:**

    Time.now		# => Thu Nov 03 18:58:25 CET 2005
    Time.now.sunday?		# => false
