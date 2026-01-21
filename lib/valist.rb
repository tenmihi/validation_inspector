# frozen_string_literal: true

require_relative "valist/version"

module Valist
  def self.all(model_class)
    model_class._validate_callbacks.map do |cb|
      name = case cb.filter
      when Symbol then cb.filter
      when Proc
                loc = cb.filter.source_location&.join(":")
                "proc@#{loc || 'unknown'}"
      else
                cb.filter.class
      end

      attributes = cb.filter.respond_to?(:attributes) ? cb.filter.attributes : nil

      { name:, attributes: }.tap do |v|
        ifs     = Array(cb.instance_variable_get(:@if))
        unlesss = Array(cb.instance_variable_get(:@unless))

        v[:if_conds] = ifs.map { |c| format_condition(c) } unless ifs.empty?
        v[:unless_conds] = unlesss.map { |c| format_condition(c) } unless unlesss.empty?
      end
    end
  end

  def self.format_condition(cond)
    cond.is_a?(Symbol) ? ":#{cond}" : (cond.source_location&.join(":") || cond.class.name)
  end

  private_class_method :format_condition
end
