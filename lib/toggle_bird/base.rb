class ToggleBird::Base
  class << self
    def toggle(key, value)
      @toggles ||= {}

      # Change the value of the toggle inside
      # the block and reset to original value
      # after the block has finished executing.
      if block_given?
        previous_toggle = @toggles[key]
        @toggles[key] = value
        yield
        @toggles[key] = previous_toggle
      else
        @toggles[key] = value
      end
    end

    def enabled?(key, true_value = nil, false_value = nil, **toggle_options)
      value = toggle_value(key, **toggle_options)
      if value
        yield if block_given?
        true_value || value
      else
        false_value || value
      end
    end

    def disabled?(key, true_value = nil, false_value = nil, **toggle_options)
      value = toggle_value(key, **toggle_options)
      if value
        false_value || !value
      else
        yield if block_given?
        true_value || !value
      end
    end

    private

      def toggle_value(key, **toggle_options)
        raise ToggleBird::Error, "toggle #{key} not set" if @toggles[key].nil?

        value = @toggles[key]
        !!(value.is_a?(Proc) ? value.call(**toggle_options) : value)
      end
  end
end
