require 'active_support/core_ext/hash'

class BabelHash
  KEY_PATH_DELIMITER = '.'

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
      deep_set(key, invert_bools[deep_get(value, subject)], memo)
    end.with_indifferent_access
  end

  def reverse!
    @map = Hash[@map.map { |k,v| [v,k] }]
    @translated = nil
  end

  private

  def invert_if(should_invert_booleans, value)
    if should_invert_booleans && (value == true || value == false)
      !value
    else
      value
    end
  end

  def deep_get(keypath, target, index = nil)
    first, *rest = *keypath.split(KEY_PATH_DELIMITER)

    if first =~ /(\[(\d+)\])$/
      index = $2.to_i
      first = first.gsub($1, '')
    end

    if rest.any?
      deep_get(
        rest.join(KEY_PATH_DELIMITER),
        target.with_indifferent_access[first],
        index
      )
    elsif index
      deep_get(keypath, target[index])
    else
      target.with_indifferent_access[first]
    end
  end

  def deep_set(keypath, value, target, index = nil)
    target ||= index ? [] : {}
    first, *rest = *keypath.split(KEY_PATH_DELIMITER)

    if first =~ /(\[(\d+)\])$/
      index = $2.to_i
      first = first.gsub($1, '')
    end

    if rest.any?
      target[first] = deep_set(
        rest.join(KEY_PATH_DELIMITER),
        value,
        target[first],
        index
      )
    elsif index
      target[index] = deep_set(keypath, value, target[index])
    else
      target[first] = value
    end

    target
  end
end
