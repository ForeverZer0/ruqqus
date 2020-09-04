require 'rest-client'
require 'json'

require_relative 'ruqqus/token'
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
  # Captures the ID of a post from a Ruqqus URL
  POST_REGEX = /\/post\/([A-Za-z0-9]+)\/?.*/.freeze

  ##
  # Captures the ID of a comment from a Ruqqus URL
  COMMENT_REGEX = /\/post\/.+\/.+\/([A-Za-z0-9]+)\/?/.freeze

  ##
  # Generic error class for exceptions specific to the Ruqqus API.
  class Error < StandardError
  end

  ##
  # Helper function to automate uploading images to Imgur anonymously and returning the direct image link.
  #
  # @param client_id [String] an Imgur client ID
  # @param image_path [String] the path to an image file.
  # @params opts [Hash] the options hash.
  # @option opts [String] :title a title to set on the Imgur post
  # @option opts [String] :description a description to set on the Imgur post
  #
  # @return [String] the direct image link from Imgur.
  # @note To obtain a free Imgur client ID, visit https://api.imgur.com/oauth2/addclient
  # @note No authentication is required for anonymous image upload, though rate limiting (very generous) applies.
  # @see Client.post_create
  def self.imgur_upload(client_id, image_path, **opts)
    #noinspection RubyResolve
    raise(Errno::ENOENT, image_path) unless File.exist?(image_path)
    raise(ArgumentError, 'client_id cannot be nil or empty') if client_id.nil? || client_id.empty?

    header = { 'Content-Type': 'application/json', 'Authorization': "Client-ID #{client_id}" }
    params = { image: File.new(image_path), type: 'file', title: opts[:title], description: opts[:description] }

    response = RestClient.post('https://api.imgur.com/3/upload', params, header)
    json = JSON.parse(response.body, symbolize_names: true)
    json[:data][:link]
  end

  ##
  # Checks if the specified guild name is available to be created.
  #
  # @param guild_name [String] the name of a guild to query.
  #
  # @return [Boolean] `true` is name is available, otherwise `false` if it has been reserved or is in use.
  def self.guild_available?(guild_name)
    available?(guild_name, VALID_GUILD, "#{Routes::GUILD_AVAILABLE}#{name}")
  end

  ##
  # Checks if the specified username is available to be created.
  #
  # @param username [String] the name of a user to query.
  #
  # @return [Boolean] `true` is name is available, otherwise `false` if it has been reserved or is in use.
  def self.username_available?(username)
    available?(username, VALID_USERNAME, "#{Routes::USERNAME_AVAILABLE}#{name}")
  end

  private

  ##
  # Checks if the specified guild or user name is available to be created.
  #
  # @param name [String] the name of a guild or username to query.
  # @param regex [Regex] a validation regex for the name.
  # @param route [String] the API endpoint to invoke.
  #
  # @return [Boolean] `true` is name is available, otherwise `false` if it has been reserved or is in use.
  def self.available?(name, regex, route)
    return false unless name && regex.match?(name)
    json = JSON.parse(RestClient.get(route))
    !!json[name]
  end
end