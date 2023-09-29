# frozen_string_literal: true

require "test_helper"

class ToggleBirdTest < ToggleBird::Base
  toggle :enabled_toggle, true
  toggle :disabled_toggle, false
  toggle :is_foo_user, ->(options) { options[:user_email] == "foo@example.com" }
end

class TestToggleBird < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ToggleBird::VERSION
  end

  class TestEnabledAndDisabled < Minitest::Test
    def test_enabled_and_disabled_return_correctly
      assert ToggleBirdTest.enabled?(:enabled_toggle)
      refute ToggleBirdTest.enabled?(:disabled_toggle)
      refute ToggleBirdTest.disabled?(:enabled_toggle)
      assert ToggleBirdTest.disabled?(:disabled_toggle)
    end

    def test_options_are_evaluated
      assert ToggleBirdTest.enabled?(:is_foo_user, user_email: "foo@example.com")
      refute ToggleBirdTest.enabled?(:is_foo_user, user_email: "bar@example.com")
      refute ToggleBirdTest.disabled?(:is_foo_user, user_email: "foo@example.com")
      assert ToggleBirdTest.disabled?(:is_foo_user, user_email: "bar@example.com")
    end

    def test_block_is_called_when_true
      enabled_true_probe = false
      ToggleBirdTest.enabled?(:enabled_toggle) { enabled_true_probe = true }
      assert enabled_true_probe

      enabled_false_probe = false
      ToggleBirdTest.enabled?(:disabled_toggle) { enabled_false_probe = true }
      refute enabled_false_probe

      disabled_true_probe = false
      ToggleBirdTest.disabled?(:enabled_toggle) { disabled_true_probe = true }
      refute disabled_true_probe

      disabled_false_probe = false
      ToggleBirdTest.disabled?(:disabled_toggle) { disabled_false_probe = true }
      assert disabled_false_probe
    end

    def test_returns_true_or_false_values_when_provided_as_arguments
      assert_equal "true string",
                   ToggleBirdTest.enabled?(:enabled_toggle, "true string", "false string")
      assert_equal "false string",
                   ToggleBirdTest.enabled?(:disabled_toggle, "true string", "false string")
      assert_equal "false string",
                   ToggleBirdTest.disabled?(:enabled_toggle, "true string", "false string")
      assert_equal "true string",
                   ToggleBirdTest.disabled?(:disabled_toggle, "true string", "false string")
    end

    def test_raises_error_if_toggle_is_not_defined
      assert_raises(ToggleBird::Error) { ToggleBirdTest.enabled? :undefined_toggle }
      assert_raises(ToggleBird::Error) { ToggleBirdTest.disabled? :undefined_toggle }
    end
  end

  class TestToggle < Minitest::Test
    def test_toggles_can_be_set_using_values
      ToggleBirdTest.toggle :new_true_toggle, true

      assert ToggleBirdTest.enabled?(:new_true_toggle)
    end

    def test_toggles_can_be_set_using_expressions
      ToggleBirdTest.toggle :new_expression_toggle, 1 > 0

      assert ToggleBirdTest.enabled?(:new_expression_toggle)
    end

    def test_toggles_can_be_set_using_a_callable
      ToggleBirdTest.toggle :callable_toggle, -> { 1 < 0 }

      refute ToggleBirdTest.enabled?(:callable_toggle)
    end

    def test_toggles_can_be_set_using_a_callable_with_arguments
      ToggleBirdTest.toggle :callable_with_options_toggle,
                            ->(options) { options[:name] == "Foo Bar" }

      assert ToggleBirdTest.enabled?(:callable_with_options_toggle, name: "Foo Bar")
      refute(ToggleBirdTest.enabled?(:callable_with_options_toggle, name: "Fizz Buzz"))
      refute(ToggleBirdTest.disabled?(:callable_with_options_toggle, name: "Foo Bar"))
      assert(ToggleBirdTest.disabled?(:callable_with_options_toggle, name: "Fizz Buzz"))
    end
  end
end
