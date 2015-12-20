require 'active_support/core_ext/hash'
require 'key_bridge/value_action'

module KeyBridge
  class KeypathHash
    def initialize(hash, delimiter: '.')
      @hash = hash.with_indifferent_access
      @delimiter = delimiter
    end

    def [](keypath, target = @hash, index = nil)
      first, *rest = keypath.split(@delimiter)
      first, index, is_array = extract_array(first, index)

      if rest.any?
        method(:[])[rest.join(@delimiter), target[first], index]
      elsif index && target[index].nil?
        target[first][index]
      elsif index
        method(:[])[first, target[index]]
      elsif is_array
        fail ArrayIndexError.new(keypath)
      elsif target
        target[first]
      end
    end

    def []=(keypath, value, target = @hash, index = nil)
      action = ValueAction.get(keypath, value, index, @delimiter)
      first, rest_keypath, index = action.arg_list

      case action.description
      when :set_key_to_keypath
        target ||= {}
        target[first] = method(:[]=)[rest_keypath, value, target[first], index]
      when :set_index_to_keypath
        target[first] ||= []
        target[first][index] = method(:[]=)[rest_keypath, value, target[first][index]]
      when :set_key_to_value_at_index
        target[first][index] = value
      when :add_value_to_array_at_key
        target ||= {}
        target[first] ||= []
        target[first] << value
      when :set_key_to_new_array
        target ||= {}
        target[first] = [value]
      when :set_key_to_value
        target ||= {}
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

    class ArrayIndexError < StandardError
      def initialize(keypath)
        super %(Must provide an index for reading values from '#{keypath}'!)
      end
    end
  end
end
