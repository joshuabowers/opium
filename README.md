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

A separate generator is available for creating a model to wrap Parse's User model:

```bash
$ rails g opium:user
```

Finally, another generator is available to further customize Parse's Installation model:

```bash
$ rails g opium:installation
```

Both of these latter two generators otherwise accept the same arguments as the generic model generator.

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

Opium will attempt to infer the class name and inverse method of an association by standard Rails naming conventions: the singular, classified variant of the method name is taken to be the target class. In case naming conventions prohibit this inference from working properly, the following options are available:

- `class_name`: Expects a string. In case the class name cannot be inferred from the association name, it can be provided by this option.
- `inverse_of`: Expects a string or a symbol. In case the inverse method name cannot be inferred from the association name or its class name, it can be provided by this option.

Associations will be covered in more detail in the sections covering [creating models](#creating-and-updating-models) and [querying data](#querying-data). For now, note that Opium will attempt to manage the relationships between associated models for you and provides a robust, Rails-centric approach to manipulating and querying them.

#### Model field metadata

A set of utility class methods are provided to survey the defined fields and associations on any given model:

- `#fields`: returns a hash of all defined fields, keyed by the name of the field. Each value stored within the hash is an [`Opium::Model::Field`](lib/opium/model/field.rb) object, which has methods which reflect the settings discussed in [Field options](#field-options).
- `#has_field?` / `#field?`: expects a string or symbol, and returns a boolean value denoting whether the field is currently defined on the model.
- `#relations`: returns a hash of all defined associations, keyed by the method name used to define the relationship on the current model. Each value is a [`Opium::Model::Relatable::Metadata`](lib/opium/model/relatable/metadata.rb), which contains details pertaining to what the association is being made between.

Each of these methods would be called on the model you wish to inspect. In the following example, we ask the `Player` model if it has a `:name` field, get all of its readonly fields, and grab a list of its associations:

```ruby
class Player
  include Opium::Model
  field :name, type: String
  field :gamer_score, type: Integer
  has_many :high_scores
  has_many :played_games, class_name: 'GameSave', inverse_of: :played_by
end

# Should output the message, as Player does define a field called "name"
puts "'Player' has a name field!" if Player.has_field? :name

# Winnows the collection of field definitions by selecting only those which are readonly.
readonly_fields = Player.fields.select {|_, field| field.readonly?}

# #relations is a hash, indexed by name; in this example, the output should include the text "high_scores, played_games".
puts "'Player' defines the following associations: #{ Player.relations.keys.join(', ') }"
```

Model metadata is readonly; it shouldn't be updated after the model has been defined. It might be useful, however, for writing model concerns or some sort of view decorator to help DRY up model usage in Rails.

#### Validations

Opium provides access to `ActiveModel::Validations` on a per model basis, so it is possible to validate the integrity of any data stored within an instance prior to saving it. Validations follow the normal ActiveModel format:

```ruby
class Article
  include Opium::Model
  field :title, type: String
  # ...
  validates :title, presence: true
end

article = Article.new
article.valid?       # false, as .title is nil.
article.errors       # Standard ActiveModel::Errors object
article.title = 'Wibbly Wobbly Timey Wimey'
article.valid?       # true, as .title has a value.
```

As is standard with `ActiveModel` compliant libraries, attempting to save an invalid model will either return false (and not trigger the save) or raise an exception, depending upon how the save was triggered.

#### Callback hooks

Each Opium model has a set of callback points which can be hooked into. Adhering to the standard of `ActiveModel::Callbacks`, these provide a model a means by which to tie into various parts of an instance's lifecycle.

A full list of the available callbacks can be found by accessing the following constant:

```ruby
Opium::Model::Callbacks::CALLBACKS
```

Opium defines callbacks for the following events:

| Event / Action | Supported hooks       |
|----------------|-----------------------|
| Save           | before, after, around |
| Create         | before, after, around |
| Update         | before, after, around |
| Destroy        | before, after, around |
| Initialize     | after                 |
| Find           | after                 |
| Touch          | after                 |
| Validation     | before, after         |

To define a callback, do something like in the following example. (This example uses Dirty attributes, which are discussed in the next section.)

```ruby
class Game
  # ...
  field :price, type: Float
  has_many :on_wishlists, class_name: Wishlist
  # ...

  before_save :notify_price_drop

  private

  def notify_price_drop
    if price_changed? && price_was > price
      # Send a message to all players who have the game on their wishlist ...
    end
  end
end
```

Please note that callbacks are only invokable within the context of Opium running in Ruby itself; these do not define Cloud Code JavaScript methods within the parse-server backend. If you need to tie into an instance's lifecycle outside the scope of a Ruby project, it is suggested that you look at using Cloud Code directly.

#### Dirty attribute tracking

Models will automatically gain attribute tracking, provided by `ActiveModel::Dirty`. As the fields of a model are altered, specialty events, of the form `<field-name>_will_change!` will be raised. At any point prior to saving, you can use the full suite of Dirty methods to query an instance about changes which have occurred to it. Dirty tracking follows a cycle: upon instance initialization, the model has no changes; upon a field changing, the current set of changes is updated; upon successfully saving the model, the current changes are cleared, and the previous changes get updated.

```ruby
class Article
  include Opium::Model
  field :title, type: String
  field :body, type: String
end

article = Article.new
article.changes        # Should be empty

# As we are updating the .title, it'll flag the dirty tracking with its update;
# as it has changed, some output denoting the alteration should be made.
article.title = 'Something happen'
puts article.title_change.inspect if article.title_changed?
```

Dirty tracking is provided for any attribute defined by the [`field`](#specifying-a-model) method.

#### JSON serialization

All Opium models should be serializable to JSON, using `ActiveModel::Serialization`. Note that a model instance does not include a root node.

JSON serialization is built around an object's `attributes` hash, which is publicly accessible. By default, all fields of the model are included within this hash. You can also store non-field data within `attributes` and have it show up in the JSON output.

Be aware that all Opium models use `ActiveModel::ForbiddenAttributesProtection` for mass assignment sanitization.

### Special Models: User and Installation

Parse defines a couple of utility classes for each app, which require special access privileges. Amongst these are two models for dealing with users of the app and the devices the app are installed on.

Opium provides wrappers around these constructs, in the form of `Opium::User` and `Opium::Installation`. For the most part, these two classes behave exactly like other models. Both classes are inheritable, so you can extend either of them with more information as necessary. Please be aware that the new subclasses will still be wrapping the core parse model, rather than being new models within the app; this means that you can still access their data via their superclasses, but would lose the convenient access to custom data.

#### Opium::User

The user model comes with the following data defined upon it:

| Field          | Data type      |
|----------------|----------------|
| id             | String         |
| created_at     | DateTime       |
| updated_at     | DateTime       |
| username       | String         |
| password       | String         |
| email          | String         |
| email_verified | Opium::Boolean |
| session_token  | String         |

To further customize the User model with other fields, associations, or scopes, you can subclass `Opium::User`, as in the following example:

```ruby
class CustomUser < Opium::User
  field :gamer_score, type: Integer
  has_many :high_scores
end
```

Note that as `Opium::User` is already an `Opium::Model`, you do not need to include that module into the custom user.

`Opium::User` provides a set of utility methods at the class level for handling user authentication and session handling.

- `authenticate[!]`: takes two parameters, being the `username` and `password` combo to test. Passwords are assumed to be in cleartext, so plan accordingly. The bang version of this method will raise an exception on failure, while the regular method will silently fail with nil. Otherwise, returns the instance of `Opium::User` associated with the provided credentials.
- `find_by_session_token`: takes a single parameter, the token to search for. Should the token be found, the associated user object is returned. If the token is not found, raises an exception.

At the instance level, `Opium::User` also provides a set of methods for reseting the users password:

- `reset_password[!]`: requires the user have a set email address. The bang variant will raise an exception on failure, while the regular method sets an error in the instance's `errors` object. Requests that parse reset the password for this current user, who will then get information sent to them via their email address.

#### Opium::Installation

The `Opium::Installation` class comes with a number of different fields predefined upon it:

| Field           | Data Type |
|-----------------|-----------|
| id              | String    |
| created_at      | DateTime  |
| updated_at      | DateTime  |
| badge           | Integer   |
| channels        | Array     |
| time_zone       | String    |
| device_type     | Symbol    |
| push_type       | Symbol    |
| gcm_sender_id   | Integer   |
| installation_id | String    |
| device_token    | String    |
| channel_uris    | Array     |
| app_name        | String    |
| app_version     | String    |
| parse_version   | String    |
| app_identifier  | String    |

Like `Opium::User`, the `Installation` class may be extended to provide access to more information stored within the parse database:

```ruby
class CustomInstallation < Opium::Installation
  field :notify_on_score_change, type: Opium::Boolean
end
```

Installations provide a convenient method to perform advanced targeting when sending [push notifications](#push-notifications).

### Creating and updating models

After defining a model with Opium, you might want to create new instances of it, or update the data of an existing instance. Opium has been designed to be familiar to anyone who has used other Rails-centric ORMs, such as ActiveRecord. In this regard, object creation follows two patterns: delayed persistence, and immediate persistence.

With delayed persistence, a model object is partially built and capable of being manipulated before being persisted. To finally create the model in parse-server, call its `save` method:

```ruby
class Player
  include Opium::Model
  field :name, type: String
  field :gamer_score, type: Integer, default: 0
end

player = Player.new( name: 'The Doctor' )
player.gamer_score = 1000

player.persisted?     # false, as it has not yet been saved
player.new_record?    # true, as it has not yet been saved

if player.save
  # persisted!  
  player.persisted?   # true, as it has been saved
else
  # there was a problem!
end
```

As this example suggests, you build a new model instance by calling its constructor, which accepts an attributes hash. The model may be altered and updated to taste. When ready to save, call the `save` method. `save` will run validations on the model, fire off any defined callbacks, update dirty tracking, and attempt to persist the model to parse-server. Should any of these steps fail, `save` will return false, and halt the operation at the point of failure. Otherwise, `save` will return true.

Alternatively, you can use `save!`, which, in the event of a failure, will raise an exception.

Note that the model's `id`, `created_at`, and `updated_at` fields will not have a value until it has been persisted.

With immediate persistence, a model object is built and then immediately stored to parse-server. This is achieved using the `create` class method, which accepts an attributes hash:

```ruby
player = Player.create( name: 'The Doctor', gamer_score: 1000 )
player.persisted?     # true, as it has been saved
```

`create` behaves like `save!`: if there was a failure at any point in the persistence process, an exception will be raised. If there is no failure, the object returned by the method is a persisted model within parse-server.

Updating a model follows a similar set of patterns: at any time you wish to store changes to a persisted model, call `save` or `save!`:

```ruby
player.gamer_score += 50
player.save!
```

Alternatively, if you want to update the attributes of a model and save it simultaneously, you can do so with either `update` or `update!`, which behave analogously to the save methods:

```ruby
if player.update( gamer_score: player.gamer_score + 50 )
  # persisted!
else
  # There was a problem!
end

player.update!( gamer_score: 2000 )
```

`update` is aliased as `update_attributes`, and `update!` is aliased as `update_attributes!`; use whichever makes more semantic sense to you.

If a model has any associations, it will attempt to persist the changes to the association, which might very well cause a cascade of persistence. Opium will attempt to only trigger a save call to a model if it needs to. Due to parse-server's unique way of representing model associations in its API, updating the association between two models does require a separate API call. Be wary when attempting to modify many models simultaneously.

When you define an association between two models, one of those models receives a special collection field of type `Opium::Model::Relation` for storing instances of the other model. This collection has utility methods for building new instances of the associated model:

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

player = Player.new
player.high_scores.class     # Opium::Model::Relation
player.high_scores.count     # 0, as there are none, yet.

score1 = player.high_scores.build
score1.value = 200

# .build is aliased as .new; either accepts an attributes hash.
score2 = player.high_scores.new( value: 1000 )

player.high_scores.count     # 2, from the previous actions

fail "That shouldn't have happened" unless score1.player == player
```

As you might expect, using a relation's build method will automatically add the built associated model to the collection; using this method will also cause the built model to point at the owner of the collection. You can also update the owner of a particular model on that model directly:

```ruby
score3 = HighScore.new( value: 10000 )
score3.player = player

player.high_scores.include?( score3 )   # true, as the above setter updates player.
```

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

## Push Notifications

Opium provides support for Parse's push endpoint via the `Opium::Push` class. The following attributes may be configured on a push before it is created:

- `channels`: an array of strings, indicating the channels to send the push to.
- `where`: used to perform an installation query. See [advanced targeting](#advanced-targeting) for more details.
- `data`: a payload hash to be delivered as part of the push.
- `expires_at`: the DateTime when the push expires; Parse will no longer attempt to send the notification after this time.
- `push_at`: used to schedule the notification for some point in the future.
- `exiration_interval`: used with `push_at`; specifies an interval, expressed in seconds relative to `push_at`, to attempt to send the notification for.

Note that `expires_at` and `push_at` are mutually exclusive; Opium prioritizes `push_at`. `push_at` can only be a value within a two week window of Time.now.

Furthermore, the `data` payload has some common fields which are accessible from the push object itself:

- `alert`: A message payload to send. Assumed to be a string.
- `badge`: (iOS only) can be either a string value of "Increment" to increase the badge count by 1 on the receiving device, or a number indicating the new badge count.
- `sound`: (iOS only) a string indicating the file within the app bundle to play upon receiving the notification.
- `content_available`: (iOS only) will cause the app to trigger a background download if set to a value of 1.
- `category`: (iOS only) the identifier of the UIUserNotificationCategory of this notification.
- `uri`: (android only) specifies an Activity to be activated associated with the provided value.
- `title`: (android only) the value displayed in for the push in the system tray.

Note that note all of these data are supported on all platforms.

Once the push has be configured as desired, it can be sent out by triggering the `create` method, which will either raise an error on failure or return true on success. Note that a truthy return value does not necessarily indicate that Parse has successfully sent any notifications; rather it merely indicates that Parse has successfully received the push request and did not find anything egregious in it.

### Advanced Targeting

## Contributing

1. Fork it ( https://github.com/[my-github-username]/opium/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
