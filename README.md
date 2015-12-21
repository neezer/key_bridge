# KeyBridge

Translates one hash to another, given a map. Inspired to make a generic solution to the problem outlined [here](http://codenoble.com/blog/transforming-hashes-a-refactoring-story/).

### Usage

#### Basic

Make a translator with the map you want to use:

``` ruby
translator = KeyBridge.new_translator({ 'name.firstName' => 'first_name' })
```

Both keys and values can use keypath syntax. By default, the delimiter is a `.`, but you can pass in  a custom delimieter if you want to use something else (see [Options](#options)).

Once you have a translator object, give it a hash that matches the left side of the map:

``` ruby
translator.translate({ name: { firstName: 'Milton' } })
#=> { 'first_name' => 'Milton' }
```

Note that you can use either symbols or strings for the hash keys in the given hash: KeyBridge uses [ActiveSupport#hash_with_indifferent_access](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/hash_with_indifferent_access.rb) so it shouldn't matter. The keypaths provided in the map must always be strings.

#### Arrays

Keypaths support array queries too! Just provide the array index as part of the keypath:

``` ruby
translator = KeyBridge.new_translator({ 'organizations[0].title' => 'title' })
```

Then it'll pull out the value at that array in the translated hash:

``` ruby
translator.translate({ organizations: [{ title: 'Collator' }] })
#=> { 'title' => 'Collator' }
```

You can also write to arrays, either by index or by pushing an empty array. For example:

``` ruby
translator = KeyBridge.new_translator({ 'title' => 'organizations[].title' })
translator.translate({ title: 'Collator' })
#=> { 'organizations' => [{ 'title' => 'Collator' }] }

translator = KeyBridge.new_translator({ 'title' => 'organizations[2].title' })
translator.translate({ title: 'Collator' })
#=> { 'organizations' => [nil, nil, { 'title' => 'Collator' }] }
```

#### Reverse

If you want to do a reverse translation on an already instantiated translator object, just call `reverse!` on it to flip the map:

``` ruby
translator = KeyBridge.new_translator({ 'panda.bears' => 'grizzly.cubs' })
translator.reverse!
translator.translate({ grizzly: { cubs: 'are cuddly' } })
#=> { 'panda' => { 'bears' => 'are cuddly' } }
```

#### Options <a id="options"></a>

``` ruby
translator = KeyBridge.new_translator(map, transforms: %i(), delimiter: '.')
```

- **transforms**
  
  This is where you can specify any value transformations you want to apply during the translation. This is an array of symbols corresponding to transformation strategies in `KeyBridge::ValueTransforms`
  
  Default: []
  
  Available transforms:
  
  - *:invert_booleans* — Flips all boolean values.
  
  ```ruby
  translator = KeyBridge.new_translator({ 'a.b' => 'x.y' }, transforms: %i(invert_booleans))
  translator.translate({ a: { b: false } })
  #=> { 'x' => { 'y' => true } }
  ```

- **delimiter**
  
  Specify a custom delimiter. Default is `.`

  ```ruby
  translator = KeyBridge.new_translator({ 'a@b' => 'x@y' }, delimiter: '@')
  translator.translate({ a: { b: 'c' } })
  #=> { 'x' => { 'y' => 'c' } }
  ```

### Testing

Run the tests with

``` 
bundle exec rake
```

### Notes

- Makes use of recursion, so don't use it with hashes with keys nested thousands of levels deep, or [enable TCO](http://nithinbekal.com/posts/ruby-tco/)
- Credit for the `first, *rest` goes to the [inimitable Avdi Grimm](http://devblog.avdi.org/2010/01/31/first-and-rest-in-ruby/)
