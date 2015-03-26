# Opium

Provides an intuitive, Mongoid-inspired mapping layer between your application's object space and Parse.

[![Build Status](https://travis-ci.org/joshuabowers/opium.svg?branch=master)](https://travis-ci.org/joshuabowers/opium)
[![Coverage Status](https://img.shields.io/coveralls/joshuabowers/opium.svg)](https://coveralls.io/r/joshuabowers/opium)
[![Code Climate](https://codeclimate.com/github/joshuabowers/opium/badges/gpa.svg)](https://codeclimate.com/github/joshuabowers/opium)

## Installation

Add this line to your application's Gemfile:

    gem 'opium'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opium

## Usage

### Within Rails

Opium will automatically establish itself as the default ORM for Rails.

#### ORM Configuration

Create a config file to communicate with your Parse database by running the config generator:

```bash
$ rails g opium:config
```

See the generated file at `config/opium.yml` for more details

#### Model Generator

A generator exists for creating new models; this should be invoked whenever `rails g model` gets invoked.

```bash
$ rails g model game title:string price:float
```

### Specifying a model

Models are defined by mixing in `Opium::Model` into a new class. Class names should match the names of the
classes defined within Parse. You can define fields on your model which mirror the columns within a Parse
class.

```ruby
class Game
  include Opium::Model
  
  field :title, type: String
  field :price, type: Float
end
```

All models automatically come with three fields: *:id*, *:created_at*, and *:updated_at*. Field names are
converted from a native ruby snake_case naming convention to a Parse lowerCamel convention.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/opium/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
