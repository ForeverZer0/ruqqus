<p align="center">
<img src="https://raw.githubusercontent.com/ruqqus/ruqqus/master/ruqqus/assets/images/logo/ruqqus_text_logo.png" width="250"/>
</p>

<hr>

# Ruqqus

A Ruby API implementation for [Ruqqus](https://ruqqus.com/), an [open-source](https://github.com/ruqqus/ruqqus) platform for online communities, free of censorship and moderator abuse by design. [Sign up](https://ruqqus.com/signup?ref=foreverzer0
) if you haven't yet!

[![Build Status](https://travis-ci.org/ForeverZer0/ruqqus.svg?branch=master)](https://travis-ci.org/ForeverZer0/ruqqus)
[![Gem Version](https://badge.fury.io/rb/ruqqus.svg)](https://badge.fury.io/rb/ruqqus)
[![Inline docs](http://inch-ci.org/github/ForeverZer0/ruqqus.svg?branch=master)](http://inch-ci.org/github/ForeverZer0/ruqqus)
[![Maintainability](https://api.codeclimate.com/v1/badges/c39f44a706302e4cd340/maintainability)](https://codeclimate.com/github/ForeverZer0/ruqqus/maintainability)

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

## Usage

See the [documentation](https://www.rubydoc.info/gems/ruqqus) for a complete API reference.

### Client Registration, Authentication, and Creation

The Ruqqus API first requires [OAuth2](https://oauth.net/2/) authentication to perform nearly all actions. To obtain
a client ID for your API application, first login into your Ruqqus account and 
[register an application](https://ruqqus.com/settings/apps). Registration requires administrator approval, but typically
is granted within hours of applying.

#### Development Testing

For desktop development and testing, there is an additional tool included for rapidly authorizing a user account to
interact with the API using any valid HTTPS address as the redirect. Simply run `ruqqus-oauth`, input credentials of the
account and application, and it will automatically authorize the user and issue a token to use.

The dependencies for this application are included in the development dependencies of the gem, so will require the gem
to be installed as `gem install ruqqus --development`, or manually by installing the following gems:

* `mechanize`
* `tty-prompt`

#### Create a Client

Once you have obtained your client ID, secret, and a user token, you can create a client:

```ruby
require 'ruqqus'

client_id     = '...' # Received after registering application
client_secret = '...' # Received after registering application
code          = '...' # The code obtained from the OAuth2 redirect URL, or one generated from ruqqus-oauth

# You must implement a responsible way of storing this token for reuse.
token = Token.new(client_id, client_secret, code)
client = Ruqqus::Client.new(token)
```

### Querying General Information

You can easily query for general information on the following entities:

* Users
* Guilds
* Posts
* Comments

Each of these entities also has an `#id` property that can be used with other related API functions, such as voting,
replying, deleting, etc. The full documentation listing all properties they obtain can be found 
[here](https://www.rubydoc.info/gems/ruqqus), but the API is rather intuitive. Here are some samples of their basic
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
guild = client.guild_info('Ruby')

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
post = client.post_info(post_id)

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
comment = client.comment_info(comment_id)

client.post_info(comment.post).title
#=> "Hi. I'm Josh Roehl, singer and songwriter of the hit song \"Endless Summer\". I am hosting an AMA here."
 
comment.body
#=> "I'm fully aware that I'm not a very good singer. Let's call it half-singing, half-rapping." 

client.user_info(comment.author_name).ban_reason
#=> "Spam"
```

### User Actions

The bulk of the API is obviously related o performing actions as a user, such as posting, commenting, voting, etc., but
also includes guild/admin management for GMs/admins, and app management for registered applications of the user.  




## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ForeverZer0/ruqqus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
