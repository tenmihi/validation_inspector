# frozen_string_literal: true

require "spec_helper"

RSpec.describe Valist do
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

  describe ".all" do
    it "lists ActiveModel validations" do
      result = described_class.all(SampleModel)

      presence = result.find { |v| v[:validator] == ActiveModel::Validations::PresenceValidator }
      expect(presence).not_to be_nil
      expect(presence[:attributes]).to eq([:name])
      expect(presence[:if_conds]).to eq([":active?"])

      format = result.find { |v| v[:validator] == ActiveModel::Validations::FormatValidator }
      expect(format).not_to be_nil
      expect(format[:attributes]).to eq([:email])
    end

    it "lists custom validation methods" do
      result = described_class.all(SampleModel)

      custom = result.find { |v| v[:validator] == :custom_check }
      expect(custom).not_to be_nil
      expect(custom[:attributes]).to be_nil
    end

    it "lists proc validations" do
      result = described_class.all(SampleModel)

      proc_entry = result.find { |v| v[:validator].is_a?(String) && v[:validator].start_with?("proc@") }
      expect(proc_entry).not_to be_nil
    end
  end
end
