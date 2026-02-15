# frozen_string_literal: true

require_relative "validation_inspector/version"

# Lists ActiveModel validation callbacks with their conditions.
module ValidationInspector
  SUPPORTED_OPTION_KEYS = {
    # LengthValidator
    minimum: true,
    maximum: true,
    is: true,
    in: true,
    within: true,
    # NumericalityValidator
    only_integer: true,
    greater_than: true,
    greater_than_or_equal_to: true,
    less_than: true,
    less_than_or_equal_to: true,
    equal_to: true,
    other_than: true,
    odd: true,
    even: true,
    # FormatValidator
    with: true,
    without: true,
    # ComparisonValidator
    # (greater_than, less_than, etc. are shared with NumericalityValidator)
    # Common options
    allow_nil: true,
    allow_blank: true
  }.freeze

  def self.all(model_class)
    model_class._validate_callbacks.map do |cb|
      validator = validator_name(cb.filter)

      attributes = cb.filter.respond_to?(:attributes) ? cb.filter.attributes : nil

      { validator:, attributes: attributes }.tap do |v|
        ifs     = Array(cb.instance_variable_get(:@if))
        unlesss = Array(cb.instance_variable_get(:@unless))

        v[:if_conds] = ifs.map { |c| format_condition(c) } unless ifs.empty?
        v[:unless_conds] = unlesss.map { |c| format_condition(c) } unless unlesss.empty?

        options = extract_options(cb.filter)
        v[:options] = options unless options.empty?
      end
    end
  end

  def self.validator_name(filter)
    case filter
    when Symbol then filter
    when Proc
      loc = filter.source_location&.join(":")
      "proc@#{loc || "unknown"}"
    else
      filter.class
    end
  end

  def self.format_condition(cond)
    cond.is_a?(Symbol) ? ":#{cond}" : (cond.source_location&.join(":") || cond.class.name)
  end

  def self.extract_options(filter)
    return {} unless filter.respond_to?(:options)

    options = filter.options
    return {} unless options.is_a?(Hash)

    options.each_with_object({}) do |(key, value), result|
      next unless SUPPORTED_OPTION_KEYS.key?(key)

      result[key] = value.is_a?(Regexp) ? value.inspect : value
    end
  end

  private_class_method :format_condition, :validator_name, :extract_options
end

module ValidationInspector
  module ClassMethodsExtension
    def inspect_validations
      ValidationInspector.all(self)
    end
  end
end

ActiveModel::Validations::ClassMethods.prepend ValidationInspector::ClassMethodsExtension
