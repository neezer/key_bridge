require 'active_support/core_ext/hash'
require 'pry'

class BabelHash
  IndexError = Class.new(StandardError) do
    def initialize(keypath)
      super(%(Must provide an index for reading values from '#{keypath}'!))
    end
  end

  KEYPATH_DELIMITER = '.'

  def initialize(map, opts = {})
    @map = map

    @opts = {
      invert_booleans: false
    }.merge(opts)
  end

  def translate(subject)
    return @translated if @translated

    invert_bools = method(:invert_if).curry[@opts[:invert_booleans]]

    @translated = @map.each.with_object({}) do |(key, value), memo|
      if retrieved_value = deep_get(key, subject)
        deep_set(value, invert_bools[retrieved_value], memo)
      end
    end.with_indifferent_access
  end

  def reverse!
    @map = Hash[@map.map { |k,v| [v,k] }]
    @translated = nil
  end

  private

  def deep_get(keypath, target, index = nil)
    first, *rest = *keypath.split(KEYPATH_DELIMITER)
    first, index, is_array = detect_array(first, index)

    if rest.any?
      deep_get(rest.join(KEYPATH_DELIMITER), wia(target)[first], index)
    elsif index && target[index].nil?
      wia(target)[first][index]
    elsif index
      deep_get(keypath, target[index])
    elsif is_array
      fail IndexError.new(keypath)
    elsif target
      wia(target)[first]
    end
  end

  def deep_set(keypath, value, target, index = nil)
    first, *rest = *keypath.split(KEYPATH_DELIMITER)
    first, index, is_array = detect_array(first, index)

    target ||= index ? [] : {}

    if rest.any?
      target[first] =
        deep_set(rest.join(KEYPATH_DELIMITER), value, target[first], index)
    elsif index
      target[index] = deep_set(keypath, value, target[index])
    elsif is_array && target[first]
      target[first] << value
    elsif is_array
      target[first] = [value]
    else
      target[first] = value
    end

    target
  end

  def invert_if(should_invert_booleans, value)
    if should_invert_booleans && (value == true || value == false)
      !value
    else
      value
    end
  end

  def detect_array(first, index)
    if match = first.match(/(\[(\d*)\])$/)
      [first.gsub(match[1], ''), to_int(match[2]), true]
    else
      [first, index, false]
    end
  end

  def wia(hash)
    hash.with_indifferent_access
  end

  def to_int(str)
    unless str.empty?
      str.to_i
    end
  end
end
