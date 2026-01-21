# frozen_string_literal: true

require "test_helper"

class ValistTest < Minitest::Test
  class SampleModel
    include ActiveModel::Validations

    attr_accessor :name, :email, :active, :skip

    validates :name, presence: true, if: :active?
    validates :email, format: { with: /@/ }, unless: -> { skip? }
    validate :custom_check
    validate -> { errors.add(:base, "invalid") }

    def active?
      !!active
    end

    def skip?
      !!skip
    end

    def custom_check
      errors.add(:base, "custom")
    end
  end

  def test_all_with_activemodel_validations
    result = Valist.all(SampleModel)

    presence = result.find { |v| v[:name] == ActiveModel::Validations::PresenceValidator }
    refute_nil presence
    assert_equal [:name], presence[:attributes]
    assert_equal [":active?"], presence[:if_conds]

    format = result.find { |v| v[:name] == ActiveModel::Validations::FormatValidator }
    refute_nil format
    assert_equal [:email], format[:attributes]

    unless_proc = SampleModel._validators[:email].first.options[:unless]
    expected_unless = unless_proc.source_location.join(":")
    assert_equal [expected_unless], format[:unless_conds]

    custom = result.find { |v| v[:name] == :custom_check }
    refute_nil custom
    assert_nil custom[:attributes]

    proc_entry = result.find { |v| v[:name].is_a?(String) && v[:name].start_with?("proc@") }
    refute_nil proc_entry
  end
end
