require 'rest-client'

require_relative 'ruqqus/item_base'
require_relative 'ruqqus/comment'
require_relative 'ruqqus/guild'
require_relative 'ruqqus/post'
require_relative 'ruqqus/user'
require_relative 'ruqqus/version'

##
# Top-level namespace of the Ruqqus gem.
module Ruqqus

  ##
  # The base Ruqqus URL.
  HOME = 'https://ruqqus.com'.freeze

  ##
  # A regular expression used for username validation.
  USERNAME_REGEX = /^[a-zA-Z0-9_]{5,25}$/.freeze

  ##
  # A regular expression used for password validation.
  PASSWORD_REGEX = /^.{8,100}$/.freeze

  ##
  # Generic error class for exceptions specific to this library.
  class Error < StandardError
  end

  ##
  # Retrieves the {User} with the specified username.
  #
  # @param [String] the username of the Ruqqus account to retrieve.
  #
  # @return [User] the requested {User}.
  #
  # @raise [ArgumentError] when `username` is `nil` or value does match the {USERNAME_REGEX} regular expression.
  # @raise [Error] thrown when user account does not exist.
  def self.user(username)
    raise(ArgumentError, 'username cannot be nil') unless username
    raise(ArgumentError, 'invalid username') unless USERNAME_REGEX.match?(username)
    api_get("#{HOME}/api/v1/user/#{username}", User)
  end

  ##
  # Retrieves the {Guild} with the specified name.
  #
  # @param [String] the name of the Ruqqus guild to retrieve.
  #
  # @return [Guild] the requested {Guild}.
  #
  # @raise [ArgumentError] when `guild_name` is `nil`.
  # @raise [Error] thrown when guild does not exist.
  def self.guild(guild_name)
    raise(ArgumentError, 'guild_name cannot be nil') unless guild_name
    # TODO: Validate name
    api_get("#{HOME}/api/v1/guild/#{guild_name}", Guild)
  end

  ##
  # Retrieves the {Post} with the specified name.
  #
  # @param [String] the ID of the post to retrieve.
  #
  # @return [Post] the requested {Post}.
  #
  # @raise [ArgumentError] when `post_id` is `nil`.
  # @raise [Error] thrown when a post with the specified ID does not exist.
  def self.post(post_id)
    raise(ArgumentError, 'post_id cannot be nil') unless post_id
    api_get("#{HOME}/api/v1/post/#{post_id}", Post)
  end

  ##
  # Retrieves the {Comment} with the specified name.
  #
  # @param [String] the ID of the comment to retrieve.
  #
  # @return [Comment] the requested {Comment}.
  #
  # @raise [ArgumentError] when `comment_id` is `nil`.
  # @raise [Error] when a comment with the specified ID does not exist.
  def self.comment(comment_id)
    raise(ArgumentError, 'comment_id cannot be nil') unless comment_id

    api_get("#{HOME}/api/v1/comment/#{comment_id}", Comment)
  end

  private

  ##
  # Calls the GET method at the specified API route, and returns the deserializes JSON response as an object.
  #
  # @param route [String] the full API route to the GET method.
  # @param klass [Class] a {Class} instance that is inherited from {ItemBase}.
  #
  # @return [Object] an instance of the specified class.
  #
  # @raise [Error] thrown when the requested item is not found.
  # @raise [ArgumentError] when the specified class is not inherited from {ItemBase}.
  def self.api_get(route, klass)
    raise(ArgumentError, 'klass is not a child class of Ruqqus::ItemBase') unless klass < ItemBase
    #noinspection RubyResolve
    begin
      response = RestClient.get(route)
      klass.from_json(response.body)
    rescue RestClient::BadRequest
      raise(Error, 'item not found')
    end
  end
end

