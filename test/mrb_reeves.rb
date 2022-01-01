##
## Reeves Test
##

assert("Reeves#hello") do
  t = Reeves.new "hello"
  assert_equal("hello", t.hello)
end

assert("Reeves#bye") do
  t = Reeves.new "hello"
  assert_equal("hello bye", t.bye)
end

assert("Reeves.hi") do
  assert_equal("hi!!", Reeves.hi)
end
