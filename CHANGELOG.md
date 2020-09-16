# Changelog

Documentation for library API changes.

Versioning system:

`MAJOR.MINOR.REVISION`

* `MAJOR` Corresponds to the native Ruqqus API major version
* `MINOR` Indicates possible breaking API changes for existing code
* `REVISION` Added functionality, bug-fixes, and other non-breaking alterations

## Version 1.1.5

* Added `Ruqqus::Clien#post_delete` method
* Added `Ruqqus::Guild#guildmasters` attribute

## Version 1.1.4

* Improved the way refreshing works to do so within a certain threshold

## Version 1.1.3

* Implemented browser-based confirmation process
* Implemented capturing confirmation code from `localhost`  OAuth redirects
* Fixed bug in querying guild/username availability

## Version 1.1.2

* Implemented enumerating comments of guilds and posts

## Version 1.1.1

* BUGFIX: Added acceptance of variable args to `Token#to_json`
* BUGFIX: Fixed regex validator in `ruqqus-oauth` for the client ID
* Separated the client ID/secret from the `Token` class, and placed within `Client` to now handle this logic

## Version 1.1.0

* Implemented `Ruqqus::Token` class to handle OAuth2 authentication
* Added `Ruqqus::Client` class as the primary object for API usage
    * Implemented post creation
    * Implemented comment creation and deletion
    * Implementing querying for reserved usernames/guilds
    * Implemented retrieving posts of guilds
    * Implemented retrieving posts and comments of users
    * Implemented voting on posts and comments as a user
    * Implemented enumerating all guilds
    * Implemented enumerating through all posts
* Refactored `Ruqqus.user_info` to `Ruqqus::Client#user`
* Refactored `Ruqqus.guild_info` to `Ruqqus::Client#guild`
* Refactored `Ruqqus.post_info` to `Ruqqus::Client#post`
* Refactored `Ruqqus.comment_info` to `Ruqqus::Client#comment`
* Many improvements in code and better adhesion to DRY principles
* Added helper method to automate uploading and creating image posts on Ruqqus via Imgur

## Version 1.0.1

* Changed validation for `fomr_url` methods in `Post` and `Comment` to also accept relative URIs.

## Version 1.0.0

* Initial release, 100% coverage of existing Ruqqus API