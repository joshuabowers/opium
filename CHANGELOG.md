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