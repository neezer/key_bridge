require 'active_support/core_ext/string'

module KeyBridge
  class Translator
    def initialize(map, transforms: [])
      @map = map

      transforms = transforms
        .map(&:to_s)
        .map(&:camelize)
        .map(&:to_sym)

      @transforms = (ValueTransforms.constants & transforms)
        .map(&ValueTransforms.method(:const_get))
        .map(&:new)
    end

    def translate(subject)
      source = KeypathHash.new(subject)
      target = KeypathHash.new({})
      apply_transform = ->(value, transformFn) { transformFn.transform(value) }

      @map.each.with_object(target) do |(source_keypath, target_keypath), memo|
        next unless value = source[source_keypath]
        memo[target_keypath] = @transforms.reduce(value, &apply_transform)
      end.to_hash
    end

    def reverse!
      @map = Hash[@map.map { |k,v| [v,k] }]
    end
  end
end
