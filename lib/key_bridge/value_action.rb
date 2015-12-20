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
      @arg_list = [@first, @rest, @index, @is_array, value]
    end

    def pick!
      @description = ValueActions.constants
        .map(&ValueActions.method(:const_get))
        .map { |action_class| action_class.new(*@arg_list) }
        .select(&:match?)
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
      if str.present?
        str.to_i
      end
    end
  end

  module ValueActions
    class Action < Struct.new(:first, :rest, :index, :is_array, :value)
      def descriptor
        self.class.name.split('::').last.underscore.to_sym
      end

      def match?
        false
      end

      private

      def rest_present?
        rest.present?
      end

      def rest_absent?
        !rest_present?
      end

      def is_array?
        is_array == true
      end

      def not_array?
        !is_array?
      end

      def index_present?
        index.present?
      end

      def index_absent?
        !index_present?
      end

      def value_present?
        if !!value == value && value == false
          true # false values are present
        else
          value.present?
        end
      end

      def value_absent?
        !value_present?
      end
    end

    class GetValueOfKeypathAtIndex < Action
      def match?
        rest_present? && is_array? && index_present? && value_absent?
      end
    end

    class GetValueAtIndex < Action
      def match?
        rest_absent? && is_array? && index_present? && value_absent?
      end
    end

    class GetValueAtKeypath < Action
      def match?
        rest_present? && not_array? && value_absent?
      end
    end

    class FailReadArrayWithoutIndex < Action
      def match?
        is_array? && index_absent? && value_absent?
      end
    end

    class GetValueAtKey < Action
      def match?
        rest_absent? && index_absent? && not_array? && value_absent?
      end
    end

    class SetKeyToValue < Action
      def match?
        rest_absent? && index_absent? && not_array? && value_present?
      end
    end

    class SetKeyToKeypath < Action
      def match?
        rest_present? && index_absent? && not_array? && value_present?
      end
    end

    class SetIndexToKeypath < Action
      def match?
        rest_present? && index_present? && is_array? && value_present?
      end
    end

    class AddValueToArrayAtKey < Action
      def match?
        rest_absent? && index_absent? && is_array? && value_present?
      end
    end

    class SetKeyToValueAtIndex < Action
      def match?
        rest_absent? && index_present? && is_array? && value_present?
      end
    end
  end
end
