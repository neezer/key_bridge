require 'active_support/core_ext/hash'
require 'key_bridge/value_action'

module KeyBridge
  class KeypathHash
    def initialize(hash, delimiter: '.')
      @hash = hash.with_indifferent_access
      @delimiter = delimiter
    end

    def [](keypath, target = @hash, index = nil)
      action = ValueAction.get(keypath, nil, index, @delimiter)
      first, rest_keypath, index = action.arg_list
      target ||= {}.with_indifferent_access

      case action.description

      when :get_value_at_keypath
        method(:[])[rest_keypath, target[first]]

      when :get_value_of_keypath_at_index
        method(:[])[rest_keypath, target[first][index]]

      when :get_value_at_index
        target[first][index]

      when :fail_read_array_without_index
        fail ArrayIndexError.new(keypath)

      when :get_value_at_key
        target[first]

      end
    end

    def []=(keypath, value, target = @hash, index = nil)
      action = ValueAction.get(keypath, value, index, @delimiter)
      first, rest_keypath, index = action.arg_list
      target ||= {}.with_indifferent_access

      case action.description

      when :set_key_to_keypath
        target[first] = method(:[]=)[rest_keypath, value, target[first]]

      when :set_index_to_keypath
        target[first] ||= []
        target[first][index] = method(:[]=)[
          rest_keypath, value, target[first][index]
        ]

      when :set_key_to_value_at_index
        target[first][index] = value

      when :add_value_to_array_at_key
        target[first] ||= []
        target[first] << value

      when :set_key_to_value
        target[first] = value

      end

      target
    end

    def to_hash
      @hash || {}
    end

    class ArrayIndexError < StandardError
      def initialize(keypath)
        super %(Must provide an index for reading values from '#{keypath}'!)
      end
    end
  end
end
