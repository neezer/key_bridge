module KeyBridge
  module ValueTransforms
    class Base
      def should_transform?(value)
        fail NotImplementedError
      end

      def transform(value, &block)
        should_transform?(value) ? block.call(value) : value
      end
    end
  end
end
