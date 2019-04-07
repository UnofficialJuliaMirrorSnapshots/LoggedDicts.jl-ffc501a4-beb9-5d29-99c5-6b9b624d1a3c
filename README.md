# LoggedDicts

[![Build Status](https://travis-ci.org/JockLawrie/LoggedDicts.jl.svg?branch=master)](https://travis-ci.org/JockLawrie/LoggedDicts.jl)
[![codecov.io](http://codecov.io/github/JockLawrie/LoggedDicts.jl/coverage.svg?branch=master)](http://codecov.io/github/JockLawrie/LoggedDicts.jl?branch=master)

## Why
LoggedDicts is motivated by a need for a lightweight easy-to-use key-value data store similar to Redis, that can also store arbitrary Julia objects.

## Functionality
- A `LoggedDict` is simply a `Dict` for which every write is logged to a user-defined output.
- A `LoggedDict` can be reconstructed from the log.
- A `LoggedDict` can also be directly written to and read from disk.

## Notes
- Since every write is logged, `LoggedDict`s are not suitable in applications with high write frequency.
- Unlike Redis, LoggedDict is not directly optimized for performance. Instead, it leverages existing performance optimizations in Julia itself. If you require better performance than LoggedDict provides, please try an alternative such as Redis or LevelDB...or feel free to implement a performance enhancement!

## Usage
The getters and setters specify an ordered sequence of keys that defines a path to a value. If a specified path does not exist, `set!` will create it, but all other getters/setters will raise an error. The getters and setters are:
- Create: `set!(ld::LoggedDict, keys, value)`
    - __NB:__ If the path defined by `keys` already exists, this function overwrites the value at the path location. Otherwise the path is created and the value is set.
- Read:   `get(ld::LoggedDict, keys...)`
- Delete: `delete!(ld::LoggedDict, keys...)`
- Update:
    - `push!(ld::LoggedDict, keys, value)`
    - `pop!(ld::LoggedDict, keys, value)`
    - More to come as required

## Example
```julia
using LoggedDicts

# Create a LoggedDict
# Specify log file
# Include a name for the LoggedDict so that log entries can be attributed to this LoggedDict (in case other data sources write to log file)
ld = LoggedDict("my_ld", "mydict.log")

# Populate the LoggedDict
set!(ld, "key1", "some_value")
set!(ld, "key2", 2)                          # ld["key2"] equals 2
set!(ld, "key2", "key21", rand(2))           # ld["key2"] equals Dict("key21" => [rand(), rand()]), overwrites previous value of 2
set!(ld, "key3", "key31", Set([1, 2, 3]))    # ld["key3"] equals Dict("key31" => Set([1, 2, 3]))
set!(ld, "key3", "key32", 32)                # ld["key3"] equals Dict("key31" => Set([1, 2, 3]), "key32" => 32)
pop!(ld, "key3", "key31", 2)                 # ld["key3"] equals Dict("key31" => Set([1, 3]), "key32" => 32)
push!(ld, "key3", "key31", 4)                # ld["key3"] equals Dict("key31" => Set([1, 3, 4]), "key32" => 32)
set!(ld, "key4", Dict("key41" => 41, "key42" => 42))    # ld["key4"] equals Dict("key41" => 4, "key42" => 42)

# Some simple queries
println(get(ld, "key1"))                # "some_value"
println(haskey(ld, "key3", "key32"))    # true
delete!(ld, "key3", "key32")
println(haskey(ld, "key3", "key32"))    # false

# Write the LoggedDict to disk
write_logged_dict("mydict", ld)
println(ld)

# Read the LoggedDict from disk
ld = read_logged_dict("mydict")
println(ld)
```

## Todo (ideas, rather than plans)
- More functions for modifying existing values. E.g., splice!, unshift!, enqueue!, dequeue!, etc.
- Deploying LoggedDict as a stand-alone web service.
- Function for reconstructing the `LoggedDict` from the log.
- Function for compressing the log such that the `LoggedDict` that is reconstructed from the compressed log is the same as that reconstructed from the original log.
- For key-value pairs consistent with Redis key-value pairs, wrap the existing syntax with Redis-like syntax so that the same syntax works for both `LoggedDict`s and `RedisConnection`s. Then users can swap out the backend by changing only 1 line...that which defines the data store. For example, `set(d, "key1", "value1")` will work whether d is a `LoggedDict` or a `RedisConnection`.
- Performance optimizations.
