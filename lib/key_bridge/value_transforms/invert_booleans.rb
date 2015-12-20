module KeyBridge
  module ValueTransforms
    class InvertBooleans < Base
      def should_transform?(value)
        !!value == value
      end

      def transform(value)
        super do
          !value
        end
      end
    end
  end
end
