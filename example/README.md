# example   [![build](https://github.com/genya0407/example/actions/workflows/ci.yml/badge.svg)](https://github.com/genya0407/example/actions/workflows/ci.yml)
Example class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'genya0407/example'
end
```
## example
```ruby
p Example.hi
#=> "hi!!"
t = Example.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file
