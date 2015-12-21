module KeyBridge
  module ValueTransforms
    class InvertBooleans < Base
      def should_transform?
        !!value == value
      end

      def transformation
        !value
      end
    end
  end
end
