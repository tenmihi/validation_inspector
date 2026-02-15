# ValidationInspector

A simple Ruby gem to list ActiveModel validation callbacks with their conditions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'validation_inspector'
```

And then execute:

```bash
bundle install
```

## Usage

```ruby
require 'validation_inspector'

class User < ApplicationRecord
  attr_accessor :name, :email, :age

  validates :name, presence: true, if: :active?
  validates :email, format: { with: /@/ }
  validates :age, numericality: { greater_than: 0 }
  validate :custom_validation
end

User.inspect_validations
=>
[
  { validator: ActiveModel::Validations::PresenceValidator,
    attributes: [:name],
    if_conds: [":active?"] },
  { validator: ActiveModel::Validations::FormatValidator,
    attributes: [:email],
    options: { with: "/@/" } },
  { validator: ActiveModel::Validations::NumericalityValidator,
    attributes: [:age],
    options: { greater_than: 0 } },
  { validator: :custom_validation,
    attributes: nil }
]
```

**Note**: Options from custom validators or other unsupported validators are not included in the `options` field.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
