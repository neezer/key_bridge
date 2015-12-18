require 'active_support/core_ext/hash'

class BabelHash
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
      deep_set(value, invert_bools[deep_get(key, subject)], memo)
    end.with_indifferent_access
  end

  def reverse!
    @map = Hash[@map.map { |k,v| [v,k] }]
    @translated = nil
  end

  private

  def deep_get(keypath, target, index = nil)
    first, *rest = *keypath.split(KEYPATH_DELIMITER)
    first, index = detect_array(first, index)

    if rest.any?
      deep_get(rest.join(KEYPATH_DELIMITER), wia(target)[first], index)
    elsif index && target[index].nil?
      wia(target)[first][index]
    elsif index
      deep_get(keypath, target[index])
    else
      wia(target)[first]
    end
  end

  def deep_set(keypath, value, target, index = nil)
    target ||= index ? [] : {}
    first, *rest = *keypath.split(KEYPATH_DELIMITER)
    first, index = detect_array(first, index)

    if rest.any?
      target[first] =
        deep_set(rest.join(KEYPATH_DELIMITER), value, target[first], index)
    elsif index
      target[index] = deep_set(keypath, value, target[index])
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
    if match = first.match(/(\[(\d+)\])$/)
      [first.gsub(match[1], ''), match[2].to_i]
    else
      [first, index]
    end
  end

  def wia(hash)
    hash.with_indifferent_access
  end
end
