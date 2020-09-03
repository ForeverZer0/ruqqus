# Changelog

Documentation for library API changes.

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