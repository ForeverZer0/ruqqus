require 'rest-client'
require 'json'

require_relative 'ruqqus/routes'
require_relative 'ruqqus/client'
require_relative 'ruqqus/types'
require_relative 'ruqqus/version'

##
# Top-level namespace of the Ruqqus gem.
module Ruqqus

  ##
  # The base Ruqqus URL.
  HOME = 'https://ruqqus.com'.freeze

  ##
  # A regular expression used for username validation.
  VALID_USERNAME = /^[a-zA-Z0-9_]{5,25}$/.freeze

  ##
  # A regular expression used for password validation.
  VALID_PASSWORD= /^.{8,100}$/.freeze

  ##
  # A regular expression used for guild name validation.
  VALID_GUILD = /^[a-zA-Z0-9][a-zA-Z0-9_]{2,24}$/.freeze

  ##
  # A regular expression used for post/comment ID validation.
  VALID_POST = /[A-Za-z0-9]+/.freeze

  ##
  # Generic error class for exceptions specific to the Ruqqus API.
  class Error < StandardError
  end

  ##
  # Retrieves the {User} with the specified username.
  #
  # @param username [String] the username of the Ruqqus account to retrieve.
  #
  # @return [User] the requested {User}.
  #
  # @raise [ArgumentError] when `username` is `nil` or value does match the {VALID_USERNAME} regular expression.
  # @raise [Error] thrown when user account does not exist.
  def self.user_info(username)
    raise(ArgumentError, 'username cannot be nil') unless username
    raise(ArgumentError, 'invalid username') unless VALID_USERNAME.match?(username)
    api_get("#{Routes::USER_INFO}#{username}", User)
  end

  ##
  # Retrieves the {Guild} with the specified name.
  #
  # @param guild_name [String] the name of the Ruqqus guild to retrieve.
  #
  # @return [Guild] the requested {Guild}.
  #
  # @raise [ArgumentError] when `guild_name` is `nil` or value does match the {VALID_GUILD} regular expression.
  # @raise [Error] thrown when guild does not exist.
  def self.guild_info(guild_name)
    raise(ArgumentError, 'guild_name cannot be nil') unless guild_name
    raise(ArgumentError, 'invalid guild name') unless VALID_GUILD.match?(guild_name)
    api_get("#{Routes::GUILD_INFO}#{guild_name}", Guild)
  end

  ##
  # Retrieves the {Post} with the specified name.
  #
  # @param post_id [String] the ID of the post to retrieve.
  #
  # @return [Post] the requested {Post}.
  #
  # @raise [ArgumentError] when `post_id` is `nil` or value does match the {VALID_POST} regular expression.
  # @raise [Error] thrown when a post with the specified ID does not exist.
  def self.post_info(post_id)
    raise(ArgumentError, 'post_id cannot be nil') unless post_id
    raise(ArgumentError, 'invalid post ID') unless VALID_POST.match?(post_id)
    api_get("#{Routes::POST_INFO}#{post_id}", Post)
  end

  ##
  # Retrieves the {Comment} with the specified name.
  #
  # @param comment_id [String] the ID of the comment to retrieve.
  #
  # @return [Comment] the requested {Comment}.
  #
  # @raise [ArgumentError] when `comment_id` is `nil` or value does match the {VALID_POST} regular expression.
  # @raise [Error] when a comment with the specified ID does not exist.
  def self.comment_info(comment_id)
    raise(ArgumentError, 'comment_id cannot be nil') unless comment_id
    raise(ArgumentError, 'invalid comment ID') unless VALID_POST.match?(comment_id)
    api_get("#{Routes::COMMENT_INFO}#{comment_id}", Comment)
  end

  ##
  # @api private
  # Calls the GET method at the specified API route, and returns the deserializes JSON response as an object.
  #
  # @param route [String] the full API route to the GET method.
  # @param klass [Class] a Class instance that is inherited from {ItemBase}, or `nil` to return as a JSON hash.
  #
  # @return [Hash,Object] an instance of the specified class.
  #
  # @raise [Error] thrown when the requested item is not found.
  # @raise [ArgumentError] when the specified class is not inherited from {ItemBase}.
  def self.api_get(route, klass = nil)
    raise(ArgumentError, 'klass is not a child class of Ruqqus::ItemBase') unless klass < ItemBase
    #noinspection RubyResolve
    begin
      body = RestClient.get(route).body
      klass && klass.respond_to?(:from_json) ? klass.from_json(body) : JSON.parse(body, symbolize_names: true)
    rescue RestClient::BadRequest
      raise(Error, 'invalid search parameters, object with specified criteria does not exist')
    end
  end
end