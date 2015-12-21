module KeyBridge
  module ValueTransforms
    class Base < Struct.new(:target_keypath, :value)
      def should_transform?
        fail NotImplementedError
      end

      def transformation
        fail NotImplementedError
      end

      def transform
        if should_transform?
          transformation
        else
          value
        end
      end
    end
  end
end
