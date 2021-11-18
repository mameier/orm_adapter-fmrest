# OrmAdapter::Fmrest

Adds Filemaker Rest to the orm_adaptor project.

### ORM Adapter
>Provides a single point of entry for popular ruby ORMs. Its target audience is gem authors who want to support more than one ORM.

For more information see the [orm_adapter project](http://github.com/ianwhite/orm_adapter).

### FmRest

>A Ruby client for FileMaker's Data API with ActiveRecord-ish ORM features.

For more information see the [fmrest-ruby gem](https://github.com/beezwax/fmrest-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orm_adapter-fmrest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orm_adapter-fmrest

## Devise

>Devise is a flexible authentication solution for Rails.

For more information see the [Devise](https://github.com/plataformatec/devise).

And now you can use Devise authentication based on Filemaker REST ORM.

Add the following lines to Gemfile:

```ruby
gem 'fmrest-ruby'
gem 'orm_adapter-fmrest'
gem 'devise'
```

And then configure Devise using "--orm fmrest" parameter:

    $ rails generate devise:install --orm fmrest
    $ rails generate devise User --orm fmrest

After that you can create User model:

```ruby
class User < FmRest::Layout
  layout('your_user_layout')
  extend Devise::Models
  devise :database_authenticatable, :rememberable, :trackable


end
```

## Known Limitations and Issues

* There is no unit test. Fill free to add it.

## Acknowledge

Part of the code and logic (i.e. devise compatibility) is ripped from [orm_adapter-her](https://github.com/myxrome/orm_adapter-her).

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
