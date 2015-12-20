module KeyBridge
  class Translator
    def initialize(map, transforms: [])
      @map = map
      @transforms = (ValueTransforms.constants & transforms)
        .map(&ValueTransforms.method(:const_get))
        .map(&:new)
    end

    def translate(subject)
      source = KeypathHash.new(subject)
      target = KeypathHash.new({})

      @map.each.with_object(target) do |(source_keypath, target_keypath), memo|
        next unless value = source[source_keypath]
        memo[target_keypath] = @transforms.reduce(value) { |v,f| f.transform(v) }
      end.to_hash
    end

    def reverse!
      @map = Hash[@map.map { |k,v| [v,k] }]
    end
  end
end
