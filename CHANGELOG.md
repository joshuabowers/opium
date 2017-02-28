## 1.5.3
### New Features
- #54: Installation queries are now supported by Opium::Push to perform a more finely targeted push.
- #55: Introduction of Opium::Installation, which allows for access and manipulation of Parse's Installation object.
- Opium::Push has an expanded set of attributes which may be set to further customize a push, including the ability to schedule a push for a particular time and expire pushes.

## 1.5.2
### Resolved Issues
- Push should now use the master key for creating notifications, rather than the REST API key.

## 1.5.1
### Resolved Issues
- Model::Criteria should now respond to #size correctly.

## 1.5.0
### New Features
- Opium will now work with ActiveModel 5.* going forward. Use a version before 1.5 if ActiveModel 4.* compatibility is needed. As a side-effect, supported rubies moves to anything above 2.2.2

## 1.4.0
### New Features
- #52: Opium should now be capable of easily connecting to a custom parse-server instance hosted on a third party server.

## 1.3.5
### New Features
- Due to ignorance, missed a method override for Opium::GeoPoint ===. Now implemented at the class level as well as at the instance level.

## 1.3.4
### New Features
- Opium::GeoPoint now provides a custom === operator; this either delegates to == (if given another geo point), to != (if given GeoPoint; NULL_ISLAND is an invalid location!), or nil if anything else.

## 1.3.3
### New Features
- Opium::GeoPoint now implements Comparable
- Opium::GeoPoint now has a constant, NULL_ISLAND, which has a lat/long of 0/0.

## 1.3.2
### Resolved Issues
- #51: Queryable#translate_to_parse now attempts to ensure that constraint values
are converted to the associated field type.

## 1.3.1
### Resolved Issues
- #50: Model::Dirty#save! now overridden to apply dirty changes when invoked.

## 1.3.0
### New Features
- Now have basic support for sending push notifications via the parse server.

## 1.2.4
### Resolved Issues
- #49: Opium::File#to_ruby now correctly handles blank/empty strings.

## 1.2.3
### New Features
- Config file can now track the Parse API webhook key.

## 1.2.2
### Resolved Issues
- #45: Of course, the untested new feature includes the wrong thing. D'oh! Model should now be including GlobalID::Identification, rather than GlobalID.

## 1.2.1
### New Features
- Fieldable should now be refactored to be more readable and less cluttered; .field, in particular, has been split up into a set of algorithmic steps.
- #45: If GlobalID is defined, it is automatically included into all models.

### Resolved Issues
- #46: Relations should now more gracefully handle conversions from nil and Array.

## 1.2.0
### New Features
- #33: Model associations.

## 1.1.8
### Resolved Issues
- #41: Boolean and GeoPoint are now namespaced within Opium. The ModelGenerator also maps attribute types for these classes.
- #42: GeoPoint now is capable of converting from String in `.to_ruby`

## 1.1.7
### Resolved Issues
- #40: `Opium::File.to_ruby` now correctly handles JSON string representation of hashes.

## 1.1.6
### Resolved Issues
- #39: `Opium::File.upload` now paramterizes the file name.
- #38: Added Content-Length and Transfer-Encoding headers to file uploads.

## 1.1.5
### Resolved Issues
- #37: Callbacks no longer makes `:update` a private method.

## 1.1.4
### Resolved Issues
- Persistable now filters out any readonly fields from the data sent on create.
- #36: The `email_verified` field in `Opium::User` is now readonly.

## 1.1.3
### Resolved Issues
- #35: The railtie now should clear the criteria model cache upon app reload.

## 1.1.2
### Resolved Issues
- #34: Rails generators now correctly reference `::File`, rather than `File`, which, in context, evaluates to `Opium::File`.

## 1.1.1
### Resolved Issues
- Fixed bug where Rails was unable to load `Opium::Model::Connectable` in `Opium::File`.

## 1.1.0

### New Features
- #29: `Opium::File` is now a supported field type, which wraps Parse's File objects.
- #31: `Symbol` is now a supported field type, which is meant to be used on top of a Parse String column.

### Resolved Issues
- #30: ActionController compatibility is increased: `.all` and `#update` should work without causing any issues.
- #10: `#attributes=` delegates to a setter for an unknown field preferentially, if the setter is present.
