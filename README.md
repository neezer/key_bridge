# BabelHash

Translates one hash to another, given a map. Inspired to make a generic
solution to the problem outlined
[here](http://codenoble.com/blog/transforming-hashes-a-refactoring-story/).

### Basic Use

```ruby
translator = BabelHash.new({
  'topLevelKeys'       => 'some_other_top_level_key',
  'nested.keys'        => 'another_key',
  'mix.and.match[2]'   => 'keep_it_simple_silly',
  'deeply.nested.keys' => 'other.deeply.nested.keys'
})

translator.translate({ mix: { and: { match: [1,2,3] } } })
  #=> { keep_it_simple_silly: 3 }
```

You can also do silly things like invert booleans:

```ruby
translator = BabelHash.new(
  { 'a.truthy.value' => 'inverted.copy' },
  { invert_booleans: true }
)

translator.translate({ a: { truthy: { value: true } } })
  #=> { inverted: { copy: false } }
```

Also also, if you want to flip yourself around and do opposite
translations, you can either do the normal thing of making a new
instance with your manually flipped map (**boring**), or just call
`reverse!` on your first translator:

```ruby
translator = BabelHash.new({ 'panda.bears' => 'grizzly.cubs' })
translator.reverse!
translator.translate({ grizzly: { cubs: 'are cuddly' } })
  #=> { panda: { bears: 'are cuddly' } }
```

Lastly, uses
[ActiveSupport#hash_with_indifferent_access](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/hash_with_indifferent_access.rb) so it shouldn't
matter if you give it symbols or strings.

### Why?

Mostly because I was bored, and this is a problem I've ran into on
occasion myself. And I've been living in [React](https://facebook.github.io/react/)/[Redux](http://redux.js.org/) land these days and
I miss me some Ruby!

### What else?

Run the tests with

```
bundle exec ruby -I. babel_hash_test.rb
```

### Caveats

- Makes use of recursion, so don't use it with crazy hashes, or [enable
  TCO](http://nithinbekal.com/posts/ruby-tco/)
- Credit for the `first, *rest` goes to the [inimitable Avdi
  Grimm](http://devblog.avdi.org/2010/01/31/first-and-rest-in-ruby/)

### Is this the best solution there is?

I've no clue!

### Should I use this in production?

***HELLS NO!*** Might be full of bugs! Who knows! I'm tired and need to
sleep!
