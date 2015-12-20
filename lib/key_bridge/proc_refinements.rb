module KeyBridge
  module ProcRefinements
    refine Proc do
      def *(other)
        Proc.new { |x| call(other[x]) }
      end
    end
  end
end
