require 'active_support/core_ext/hash'
require 'pry'

class BabelHash
  def initialize(map, opts = {})
    @map = map

    @opts = {
      invert_booleans: false
    }.merge(opts)
  end

  def translate(subject)
    invert_bools = method(:invert_if).curry[@opts[:invert_booleans]]
    source = KeypathHash.new(subject)
    target = KeypathHash.new({})

    @map.each.with_object(target) do |(source_keypath, target_keypath), memo|
      if retrieved_value = source[source_keypath]
        memo[target_keypath] = invert_bools[retrieved_value]
      end
    end.to_hash
  end

  def reverse!
    @map = Hash[@map.map { |k,v| [v,k] }]
  end

  private

  def invert_if(should_invert_booleans, value)
    if should_invert_booleans && (value == true || value == false)
      !value
    else
      value
    end
  end

  class Translator
  end

  class KeypathHash
    class IndexError < StandardError
      def initialize(keypath)
        super(%(Must provide an index for reading values from '#{keypath}'!))
      end
    end

    def initialize(hash, delimiter: '.')
      @hash = hash.with_indifferent_access
      @delimiter = delimiter
    end

    def [](keypath, target = @hash, index = nil)
      first, *rest = keypath.split(@delimiter)
      first, index, is_array = extract_array(first, index)

      if rest.any?
        method(:[]).call(rest.join(@delimiter), target[first], index)
      elsif index && target[index].nil?
        target[first][index]
      elsif index
        method(:[]).call(first, target[index])
      elsif is_array
        fail IndexError.new(keypath)
      elsif target
        target[first]
      end
    end

    def []=(keypath, value, target = @hash, index = nil)
      first, *rest = keypath.split(@delimiter)
      first, index, is_array = extract_array(first, index)

      target ||= index ? [] : {}

      if rest.any?
        target[first] = method(:[]=).call(
          rest.join(@delimiter),
          value,
          target[first],
          index
        )
      elsif index
        target[index] = method(:[]=).call(keypath, value, target[index])
      elsif is_array && target[first]
        target[first] << value
      elsif is_array
        target[first] = [value]
      else
        target[first] = value
      end

      target
    end

    def to_hash
      @hash || {}
    end

    private

    def extract_array(first, index)
      if match = first.match(/(\[(\d*)\])$/)
        [first.gsub(match[1], ''), to_int(match[2]), true]
      else
        [first, index, false]
      end
    end

    def to_int(str)
      unless str.empty?
        str.to_i
      end
    end
  end
end
