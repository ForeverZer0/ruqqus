<p align="center">
<img src="https://raw.githubusercontent.com/ForeverZer0/ruqqus/master/assets/ruqqus_text_logo.png" width="360"/>
</p>

<hr>

# Ruqqus

A Ruby API implementation for [Ruqqus](https://ruqqus.com/), an [open-source](https://github.com/ruqqus/ruqqus) platform for online communities, free of censorship and moderator abuse by design. [Sign up](https://ruqqus.com/signup?ref=foreverzer0
) if you haven't yet!

[![Build Status](https://travis-ci.org/ForeverZer0/ruqqus.svg?branch=master)](https://travis-ci.org/ForeverZer0/ruqqus)
[![Gem Version](https://badge.fury.io/rb/ruqqus.svg)](https://rubygems.org/gems/ruqqus)
[![Inline docs](http://inch-ci.org/github/ForeverZer0/ruqqus.svg?branch=master)](http://inch-ci.org/github/ForeverZer0/ruqqus)
[![Maintainability](https://api.codeclimate.com/v1/badges/c39f44a706302e4cd340/maintainability)](https://codeclimate.com/github/ForeverZer0/ruqqus/maintainability)
[![OpenIssues](https://img.shields.io/github/issues/ForeverZer0/ruqqus)](https://github.com/ForeverZer0/ruqqus/issues)
[![License](https://img.shields.io/github/license/ForeverZer0/ruqqus)](https://opensource.org/licenses/MIT)
[![Ruby](https://img.shields.io/badge/powered%20by-ruby-red)](https://www.ruby-lang.org/en/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruqqus'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruqqus

To use the `ruqqus-oauth` helper to generate user tokens for desktop development:

    $ gem install ruqqus --development

## Authentication

Ruqqus enables 3rd-party client authorization using the [OAuth2 protocol](https://oauth.net/2/). Before it is possible
to interact with the API, you will need to first [register an application](https://ruqqus.com/settings/apps), which can
be supply you with an API key/secret pair. This key will allow you to authorize users and grant privileges with an
assortment of scopes to fit your needs.

### Desktop Development

This gem includes a tool to automate obtaining a client code for users, primarily aimed for desktop developers who do
not have a server running to receive the redirect URL. The tool requires the `mechanize` and `tty-prompt` gems, which
are not included by default.

To install the tool with its dependencies, install this gem with the following flag.

    $ gem insall ruqqus --development

Once installed, simply run `ruqqus-oauth`. You will be prompted to input the API key that was issued by Ruqqus to your
approved application, and the user credentials for the account you with to authorize, such as that for a bot. Once
executed, an authorization code will be displayed on-screen, which you can then use to create a token.

```ruby
require 'ruqqus'

client_id     = 'XXXXXX' # Received after registering application
client_secret = 'XXXXXX' # Received after registering application
code          = 'XXXXXX' # The generated code (or the one you obtained via traditional means)

# You must implement a responsible way of storing this token for reuse.
token = Ruqqus::Token.new(client_id, client_secret, code)
client = Ruqqus::Client.new(client_id, client_secret, token)

# Alternatively, you can create a new token and a client with a single call.
# This will perform the "grant" action of the code while creating it automatically 
client = Ruqqus::Client.new(client_id, client_secret, code)
```

The token will automatically refresh itself as-needed, but you will need to handle storing its new value for repeated
uses. To facilitate this and make it easier, there is a callback that can be subscribed to which will be called each
time the access key is updated.

```ruby
# Load an existing token that has already been authorized
token = Ruqqus::Token.load_json('./token.json')

# Create your client
client = Ruqqus::Client.new(client_id, client_secret, token)

# Set the callback block to automatically update the saved token when it refreshes
client.token_refreshed do |t|
  t.save_json('./token.json')
end
```

The token obtains sensitive material, and due to the security issues of storing it in plain text, this functionality is
left to the user. The token is essentially the equivalent of your user credentials for Ruqqus, so bear that in mind how
and where you store this information so that it is not compromised.

## Usage

For in-depth documentation and instructions on how to get started, please see the following resources:

* [API Documentation](https://www.rubydoc.info/gems/ruqqus) - Complete documentation of the entire API (100% coverage)
* [Wiki](https://github.com/ForeverZer0/ruqqus/wiki) - Public wiki with more in-depth explanation, code samples, best practices, etc.

### Features

The bulk of the API is obviously related to performing actions as a user, such as posting, commenting, voting, etc.. The
following highlights some of these features.

* Vote on posts and comments
* Create posts (text/link/image)
* Automated image upload via anonymous upload to Imgur ([API Key](https://imgur.com/account/settings/apps) required) 
* Create/edit/delete comments
* Enumerate all existing guilds
* Enumerate all posts in a guild
* Enumerate all posts on the "front page", "all", etc., with sorting and filtering
* Enumerate all posts/comments of users (excluding private/banned/blocked accounts)

#### Misc. Examples

Some random examples displaying the ease in performing various operations.

##### Let's do some voting!
```ruby
client.each_user_post('captainmeta4') do |post|
  # Upvote our fearless leader's posts
  client.vote_post(post, 1)
end

client.each_user_comment('captainmeta4') do |comment|
  # ...and his comments.
  client.vote_comment(comment, 1)
end
```

##### Monitor For New Posts
```ruby
delay = 10
puts 'Watching for new posts, press Ctrl+C to quit'
loop do
  time = Time.now
  sleep(delay)

  puts "Checking the front page for new posts since #{time}"
  client.each_post(sort: :new, filter: :all) do |post|
    # Stop checking post once we encounter one older than this iteration
    break if post.created < time
    # Do something about this new post showing up in All
    puts "Found a new post: '#{post.title}'"
  end
end
```
##### Download all images from a guild
```ruby
require 'open-uri'
domains = %w[i.ruqqus.com i.imgur.com]

Dir.mkdir('./tree_pics') unless Dir.exist?('./tree_pics')
client.each_guild_post('Trees', sort: :new) do |post|
  next unless domains.include?(post.domain)
  ext = File.extname(post.url)
  ext = '.jpg' if ext.empty? # We don't care, just an example
  path = File.join('./tree_pics', post.id + ext)
  URI.open(post.url) { |src| File.open(path, 'wb') { |dst| dst.write(src.read) } }
end
```

### Types

The Ruqqus API exposes four primary types:

* Users
* Guilds
* Posts
* Comments

Nearly all client operations interact with one or more of these entities in some way. Each of these types also has an
`#id` property that can be used with other related API functions, such as voting, replying, deleting, etc. The full
documentation listing all properties they obtain can be found [here](https://www.rubydoc.info/gems/ruqqus), but the API
is rather intuitive. Here are some samples of their basic
usage.

#### Users

Obtain information about users.

```ruby
user = client.user_info('foreverzer0')

# Get user's total rep (as well as separate for comments/posts)
user.total_rep
#=> 22234

# Enumerate earned badges
user.badges.map(&:to_s)
#=> ["Joined Ruqqus during open beta", "Verified Email", "Recruited 10 friends to join Ruqqus"]

# Retrieve a Time object for when user created account
user.created
#=> 2020-06-16 21:59:04 -0400
```

#### Guilds

Obtain information about guilds.

```ruby
guild = client.guild('Ruby')

# Query the number of members, description, accent color, etc.
guild.member_count
#=> 43

# Links to guild's banner, profile, etc.
guild.banner_url
#=> "https://i.ruqqus.com/board/ruby/banner-2.png"

# Check for flags such as NSFW, NSFL, deletion, banned, "offensive", etc.
guild.nsfw?
#=> false
```

#### Posts

Obtain information about posts.

```ruby
# Post IDs can be found within any link to a post.
# https://ruqqus.com/post/<POST ID>/<POST TITLE>
 
post_id = '2e0x'
post = client.post(post_id)

# Obtain relevant information pertaining the guilds on Ruqqus
  
post.author_name
#=> "Galadriel"

post.title
#=> "Made this project in Ruby On Rails"

post.url
#=> "https://ruqqus-metrics.com/"

post.score
#=> 10
```

#### Comments

Obtain information about comments. Comments are very similar to posts, but have a few unique methods for obtaining their nesting level, parent post/comment, etc.

```ruby
# Post IDs can be found within any link to a post.
# https://ruqqus.com/post/<POST ID>/<POST TITLE>/<COMMENT ID>

comment_id = '67mt'
comment = client.comment(comment_id)

client.post(comment.post).title
#=> "Hi. I'm Josh Roehl, singer and songwriter of the hit song \"Endless Summer\". I am hosting an AMA here."
 
comment.body
#=> "I'm fully aware that I'm not a very good singer. Let's call it half-singing, half-rapping." 

client.user(comment.author_name).ban_reason
#=> "Spam"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ForeverZer0/ruqqus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
