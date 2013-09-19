module ActiveFedora
  module Associations
    # This is the root class of all associations:
    #
    #   Association
    #     BelongsToAssociation
    #     AssociationCollection
    #       HasManyAssociation
    #
    #
    class Association
      attr_reader :owner, :target, :reflection
      delegate :options, :klass, to: :reflection

      def initialize(owner, reflection)
        #reflection.check_validity!
        @owner, @reflection = owner, reflection
        @updated = false
        reset
        # construct_scope
      end

      # Resets the \loaded flag to +false+ and sets the \target to +nil+.
      def reset
        @loaded = false
        @target = nil
      end

      # Reloads the \target and returns +self+ on success.
      def reload
        reset
        # construct_scope
        load_target
        self unless @target.nil?
      end

      # Has the \target been already \loaded?
      def loaded?
        @loaded
      end

      # Asserts the \target has been loaded setting the \loaded flag to +true+.
      def loaded!
        @loaded = true
        @stale_state = stale_state
      end

      # The target is stale if the target no longer points to the record(s) that the
      # relevant foreign_key(s) refers to. If stale, the association accessor method
      # on the owner will reload the target. It's up to subclasses to implement the
      # state_state method if relevant.
      #
      # Note that if the target has not been loaded, it is not considered stale.
      def stale_target?
        loaded? && @stale_state != stale_state
      end

      # Sets the target of this proxy to <tt>\target</tt>, and the \loaded flag to +true+.
      def target=(target)
        @target = target
        loaded!
      end

      # def scoped
      #   target_scope.merge(@association_scope)
      # end
      
      # Set the inverse association, if possible
      def set_inverse_instance(record)
        if record && invertible_for?(record)
          inverse = record.association(inverse_reflection_for(record).name)
          inverse.target = owner
        end
      end
      

      # # This class of the target. belongs_to polymorphic overrides this to look at the
      # # polymorphic_type field on the owner.
      # def target_klass
      #   @reflection.klass
      # end

      # # Can be overridden (i.e. in ThroughAssociation) to merge in other scopes (i.e. the
      # # through association's scope)
      # def target_scope
      #   target_klass.scoped
      # end

      # Assigns the ID of the owner to the corresponding foreign key in +record+.
      # If the association is polymorphic the type of the owner is also set.
      def set_belongs_to_association_for(record)
        unless @owner.new_record?
          record.add_relationship(@reflection.options[:property], @owner)
        end
      end

      def load_target
          @target = find_target if (@stale_state && stale_target?) || find_target?
          loaded! unless loaded?
          target
      end

        private

        
        def find_target?
          !loaded? && (!owner.new_record? || foreign_key_present?) && klass
        end

        # Loads the \target if needed and returns it.
        #
        # This method is abstract in the sense that it relies on +find_target+,
        # which is expected to be provided by descendants.
        #
        # If the \target is already \loaded it is just returned. Thus, you can call
        # +load_target+ unconditionally to get the \target.
        #
        # ActiveFedora::ObjectNotFoundError is rescued within the method, and it is
        # not reraised. The proxy is \reset and +nil+ is the return value.
        def load_target
          @target = find_target if (@stale_state && stale_target?) || find_target?
          loaded! unless loaded?
          target
        end

        # Returns true if there is a foreign key present on the owner which
        # references the target. This is used to determine whether we can load
        # the target if the owner is currently a new record (and therefore
        # without a key). If the owner is a new record then foreign_key must
        # be present in order to load target.
        #
        # Currently implemented by belongs_to
        def foreign_key_present?
          false
        end

        # Raises ActiveFedora::AssociationTypeMismatch unless +record+ is of
        # the kind of the class of the associated objects. Meant to be used as
        # a sanity check when you are about to assign an associated record.
        def raise_on_type_mismatch(record)
          unless record.is_a?(@reflection.klass) || record.is_a?(@reflection.class_name.constantize)
            message = "#{@reflection.class_name}(##{@reflection.klass.object_id}) expected, got #{record.class}(##{record.class.object_id})"
            raise ActiveFedora::AssociationTypeMismatch, message
          end
        end

        # Can be redefined by subclasses, notably polymorphic belongs_to
        # The record parameter is necessary to support polymorphic inverses as we must check for
        # the association in the specific class of the record.
        def inverse_reflection_for(record)
          reflection.inverse_of
        end

        # Returns true if inverse association on the given record needs to be set.
        # This method is redefined by subclasses.
        def invertible_for?(record)
          inverse_reflection_for(record)
        end


        # This should be implemented to return the values of the relevant key(s) on the owner,
        # so that when state_state is different from the value stored on the last find_target,
        # the target is stale.
        #
        # This is only relevant to certain associations, which is why it returns nil by default.
        def stale_state
        end

    end
  end
end