# reeves   [![Build Status](https://travis-ci.org/genya0407/reeves.svg?branch=master)](https://travis-ci.org/genya0407/reeves)
Reeves class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'genya0407/reeves'
end
```
## example
```ruby
p Reeves.hi
#=> "hi!!"
t = Reeves.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file
