require 'active_support/core_ext/string'

module KeyBridge
  class Translator
    def initialize(map, transforms: [], delimiter: '.')
      @map = map

      transforms = transforms
        .map(&:to_s)
        .map(&:camelize)
        .map(&:to_sym)

      @transforms = (ValueTransforms.constants & transforms)
        .map(&ValueTransforms.method(:const_get))

      @delimiter = delimiter
    end

    def translate(subject)
      source = KeypathHash.new(subject, delimiter: @delimiter)
      target = KeypathHash.new({}, delimiter: @delimiter)

      @map.each.with_object(target) do |(source_keypath, target_keypath), memo|
        next unless value = source[source_keypath]

        memo[target_keypath] = @transforms.reduce(value) do |val, transform|
          transform.new(target_keypath, val).transform
        end
      end.to_hash
    end

    def reverse!
      @map = Hash[@map.map { |k,v| [v,k] }]
    end
  end
end
