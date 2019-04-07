using LoggedDicts
using Base.Test

if !isfile("ld_test.log")
    run(`touch $(joinpath(dirname(@__FILE__), "ld_test.log"))`)
end
if !isfile("loggeddict.test")
    run(`touch $(joinpath(dirname(@__FILE__), "loggeddict.test"))`)
end


# Create and populate a LoggedDict
ld = LoggedDict("my_ld", "ld_test.log")      # Init empty LoggedDict, with logs entries recorded in "mydict.log"
set!(ld, "key1", "some_value")
set!(ld, "key2", 2)                          # ld["key2"] equals 2
@test get(ld, "key2") == 2
set!(ld, "key2", "key21", [1.2, 3.4])        # ld["key2"] equals Dict("key21" => [1.2, 3.4]), overwrites previous value of 2
set!(ld, "key3", "key31", Set([1, 2, 3]))    # ld["key3"] equals Dict("key31" => Set([1, 2, 3]))
set!(ld, "key3", "key32", 32)                # ld["key3"] equals Dict("key31" => Set([1, 2, 3]), "key32" => 32)
pop!(ld, "key3", "key31", 2)                 # ld["key3"] equals Dict("key31" => Set([1, 3]), "key32" => 32)
push!(ld, "key3", "key31", 4)                # ld["key3"] equals Dict("key31" => Set([1, 3, 4]), "key32" => 32)
set!(ld, "key4", Dict("key41" => 41, "key42" => 42))    # ld["key4"] equals Dict("key41" => 4, "key42" => 42)

# Test some values
@test get(ld, "key1") == "some_value"
@test get(ld, "key2") == Dict("key21" => [1.2, 3.4])
@test get(ld, "key3") == Dict("key31" => Set([1, 3, 4]), "key32" => 32)
@test get(ld, "key4") == Dict("key41" => 41, "key42" => 42)
@test_throws ErrorException get(ld, "key5", "key51")

# Test: delete! and haskey
delete!(ld, "key1")
delete!(ld, "key3", "key32")
@test haskey(ld, "key1") == false
@test haskey(ld, "key3") == true
@test haskey(ld, "key3", "key32") == false

# Write the LoggedDict to disk
write_logged_dict("loggeddict.test", ld)

# Read the LoggedDict from disk
ld = ""
ld = read_logged_dict("loggeddict.test")

# Retest the values
@test get(ld, "key2") == Dict("key21" => [1.2, 3.4])
@test get(ld, "key3") == Dict("key31" => Set([1, 3, 4]))
@test get(ld, "key4") == Dict("key41" => 41, "key42" => 42)

# Test LoggedDict with logging off
ld = LoggedDict("my_ld", "ld_test.log", true)      # Init empty LoggedDict, with logs entries recorded in "mydict.log"
set!(ld, "key1", "some_value")
@test get(ld, "key1") == "some_value"


### EOF
