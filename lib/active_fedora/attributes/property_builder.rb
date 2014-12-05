module ActiveFedora::Attributes
  class PropertyBuilder < ActiveTriples::PropertyBuilder #:nodoc:

    def self.define_accessors(model, reflection)
      mixin = model.generated_property_methods
      name = reflection.term
      define_readers(mixin, name)
      reflection.multivalue ? define_writers(mixin, name) : define_singular_writers(mixin, name)
    end

    def self.define_writers(mixin, name)
      mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(value)
          if value.present? && !value.respond_to?(:each)
            raise ArgumentError, "You attempted to set the property `#{name}' to a scalar value. However, this property is declared as being multivalued."
          end
          set_value(:#{name}, value)
        end
      CODE
    end

    def self.define_singular_writers(mixin, name)
      mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(value)
          if value.respond_to?(:each) # singular
            raise ArgumentError, "You attempted to set the property `#{name}' to an enumerable value. However, this property is declared as singular."
          end
          set_value(:#{name}, value)
        end
      CODE
    end
  end
end
