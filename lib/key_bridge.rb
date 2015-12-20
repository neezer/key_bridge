module KeyBridge
  autoload :KeypathHash, 'key_bridge/keypath_hash'
  autoload :Translator, 'key_bridge/translator'

  module ValueTransforms
    autoload :Base, 'key_bridge/value_transforms/base'
    autoload :InvertBooleans, 'key_bridge/value_transforms/invert_booleans'
  end
end
