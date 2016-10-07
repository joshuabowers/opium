# Opium

Provides an intuitive, Mongoid-inspired mapping layer between your application's object space and Parse.

[![Gem Version](https://badge.fury.io/rb/opium.svg)](http://badge.fury.io/rb/opium)
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

### Parse.com server closure note

Opium was originally written to communicate with apps hosted on Parse.com; as hosted parse is hitting end-of-life in January 2017, any parse apps which wish to continue using the infrastructure need to be [migrated to third-party hosted parse-server instance](https://www.parse.com/migration).

As of version 1.4.0, Opium should be able to communicate with these third-party installations. Within the generated configuration file, two settings need to be updated to point Opium at the proper server instance:

- `server_url`: the URL of the server on which a parser-server API instance is hosted.
- `mount_point`: the sub-URI endpoint on `server_url` where Opium can reach the API.

As the config file suggests, it is suggested that these values be provided in a server environment via environment variables.

### Model Generator

A generator exists for creating new models; this should be invoked whenever `rails g model` gets invoked.

```bash
$ rails g model game title:string price:float
```

A separate generate is available for creating a model to wrap Parse's User model:

```bash
$ rails g opium:user
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

#### Field data types

Opium comes with support for a variety of different data types for fields. These automatically will convert native ruby representations of the stored values to values supported by the parse backend, and conversely. At this time, Opium supports the following field types, where the first column is the type specified in ruby, and the second column is the type as stored in parse.

| Ruby Type       | Parse Type |
|-----------------|------------|
| Integer         | Number     |
| Float           | Number     |
| String          | String     |
| Symbol          | String     |
| Date            | Date       |
| DateTime        | Date       |
| Time            | Date       |
| Array           | Array      |
| Opium::Boolean  | Boolean    |
| Opium::GeoPoint | GeoPoint   |
| Opium::File     | File       |
| Opium::Pointer  | Pointer    |

Field setters will generally attempt to convert any incoming value to a native ruby representation, as noted above. Opium will automatically convert these values to a parse-friendly representation as necessary: e.g., when performing a query or persisting data.

Setting the type for a field is done by specifying the `:type` option on the field method. If this option is not present, the field will default to a ruby type of `Object`, which acts as a pass-through of the values coming from and going to parse. In the example from the last section, the `Game` model has two fields, one which is specified as having a `String` type, while the other has a `Float` type.

#### Field options

Fields can be modified by a small set of options passed to their definition:

- `readonly`: Expects a boolean value. If present, Opium will prevent the field from being altered locally. (The associated parse column may still be modified from other locations outside of Opium.)
- `as`: Expects a string or symbol value. If present, this will specify the name of the associated column within parse where the value should be stored. This allows the field to be named something more semantically useful locally.
- `type`: See the previous section. Expects a class constant.
- `default`: Expects either a logically convertible literal or a lambda providing the same. If a lambda is provided, it will be evaluated each time a model is instantiated, unless a value is provided for the field.

```ruby
class Article
  include Opium::Model

  field :title, type: String, readonly: true
  field :edited_on, type: Date, as: :last_edited
  field :published_at, type: Date, default: -> { Time.now }
end
```

In the preceding example, an `Article` is never allowed to alter its `title`, while its `last_edited` field is locally aliased as `edited_on`, and it will provide a default value for `published_at`, should none otherwise be provided.

#### Model associations

Opium currently supports basic associations between models: an owning model can specify that it `has_many` of another model, which can specify that it `belongs_to` the former.

```ruby
class Player
  # ...
  has_many :high_scores
  # ...
end

class HighScore
  # ...
  belongs_to :player
  # ...
end
```

##### Association options

- `class_name`: Expects a string. In case the class name cannot be inferred from the association name, it can be provided by this option.
- `inverse_of`: Expects a string or a symbol. In case the inverse method name cannot be inferred from the association name or its class name, it can be provided by this option.

#### Model field metadata

#### Validations

#### Callback hooks

#### Dirty attribute tracking

#### JSON serialization

### Creating and updating models

### Querying data

#### Find by id

#### Criteria & Scopes

#### Kaminari support

Opium comes with support for [Kaminari](https://rubygems.org/gems/kaminari). To ensure that Opium loads itself correctly, please specify it _after_ Kaminari within your Gemfile:

```Gemfile
gem 'kaminari'
gem 'opium'
```

Models and Criteria will gain the methods defined by Kaminari, and should be compatible with Kaminari's pagination partials.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/opium/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
