require 'active_support/core_ext/string'

module KeyBridge
  class ValueAction
    attr_reader :description, :arg_list

    def self.get(*args)
      self.new(*args).pick!
    end

    def initialize(keypath, value, index, delimiter)
      first, *rest = keypath.split(delimiter)
      @rest = rest.join(delimiter)
      @first, @index, @is_array = extract_array(first, index)
      @arg_list = [@first, @rest, @index, @is_array]
    end

    def pick!
      @description = ValueActions.constants
        .map(&ValueActions.method(:const_get))
        .select { |action| action.applicable?(*@arg_list) }
        .map(&:descriptor)
        .first

      self
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

  module ValueActions
    class Base
      def self.applicable?(*args)
        false
      end

      def self.descriptor
        name.split('::').last.underscore.to_sym
      end
    end

    class SetKeyToValueAtIndex < Base
      def self.applicable?(first, rest, index, is_array)
        [!rest.present?, !index.nil?, is_array].all?
      end
    end

    class AddValueToArrayAtKey < Base
      def self.applicable?(first, rest, index, is_array)
        [!rest.present?, index.nil?, is_array].all?
      end
    end

    class SetIndexToKeypath < Base
      def self.applicable?(first, rest, index, is_array)
        [rest.present?, !index.nil?, is_array].all?
      end
    end

    class SetKeyToKeypath < Base
      def self.applicable?(first, rest, index, is_array)
        [rest.present?, index.nil?].all?
      end
    end

    class SetKeyToValue < Base
      def self.applicable?(first, rest, index, is_array)
        [!rest.present?, index.nil?].all?
      end
    end
  end
end

#
      # if rest.any?
      #   target[first] = method(:[]=)[rest.join(@delimiter), value, target[first], index]
      # elsif is_array && target[first] && index
      #   target[first][index] = value
      # elsif is_array && target[first]
      #   target[first] << value
      # elsif is_array
      #   target[first] = [value]
      # elsif index
      #   target[index] = method(:[]=)[first, value, target[index]]
      # else
      #   target[first] = value
      # end
