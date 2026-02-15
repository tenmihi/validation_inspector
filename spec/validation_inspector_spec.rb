# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidationInspector do
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

  class ModelWithOptions
    include ActiveModel::Validations

    attr_accessor :name, :age, :status, :role

    validates :name, length: { minimum: 2, maximum: 255 }
    validates :age, numericality: { greater_than_or_equal_to: 0, less_than: 150, only_integer: true }
    validates :status, inclusion: { in: %w[active inactive] }
    validates :role, exclusion: { in: %w[admin superuser], allow_nil: true }
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

    it "extracts options from LengthValidator" do
      result = described_class.all(ModelWithOptions)

      length = result.find { |v| v[:validator] == ActiveModel::Validations::LengthValidator }
      expect(length).not_to be_nil
      expect(length[:options]).to include(minimum: 2, maximum: 255)
    end

    it "extracts options from NumericalityValidator" do
      result = described_class.all(ModelWithOptions)

      numericality = result.find { |v| v[:validator] == ActiveModel::Validations::NumericalityValidator }
      expect(numericality).not_to be_nil
      expect(numericality[:options]).to include(
        greater_than_or_equal_to: 0,
        less_than: 150,
        only_integer: true
      )
    end

    it "extracts options from InclusionValidator" do
      result = described_class.all(ModelWithOptions)

      inclusion = result.find { |v| v[:validator] == ActiveModel::Validations::InclusionValidator }
      expect(inclusion).not_to be_nil
      expect(inclusion[:options]).to include(in: %w[active inactive])
    end

    it "extracts allow_nil option from ExclusionValidator" do
      result = described_class.all(ModelWithOptions)

      exclusion = result.find { |v| v[:validator] == ActiveModel::Validations::ExclusionValidator }
      expect(exclusion).not_to be_nil
      expect(exclusion[:options]).to include(in: %w[admin superuser], allow_nil: true)
    end

    it "extracts regex pattern from FormatValidator as inspected string" do
      result = described_class.all(SampleModel)

      format = result.find { |v| v[:validator] == ActiveModel::Validations::FormatValidator }
      expect(format).not_to be_nil
      expect(format[:options][:with]).to eq("/@/")
    end
  end
end
