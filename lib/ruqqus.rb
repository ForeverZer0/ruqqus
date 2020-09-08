require 'base64'
require 'json'
require 'rbconfig'
require 'rest-client'
require 'securerandom'
require 'socket'

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
  # @!attribute self.proxy [rw]
  #   @return [URI?] the URI of the proxy server in use, or `nil` if none has been set.

  ##
  # Obtains a list of URIs of free proxy servers that can be used to route network traffic through.
  #
  # @param anon [Symbol] anonymity filter for the servers to return, either `:transparent`, `:anonymous`, or `:elite`.
  # @param country [String,Symbol] country filter for servers to return, an ISO-3166 two digit county code.
  #
  # @return [Array<URI>] an array of proxy URIs that match the input filters.
  # @note These proxies are free, keep that in mind. They are refreshed frequently, can go down unexpectedly, be slow,
  #   and other manners of inconvenience that can be expected with free services.
  # @see https://www.nationsonline.org/oneworld/country_code_list.htm
  def self.proxy_list(anon: :elite, country: nil)
    raise(ArgumentError, 'invalid anonymity value') unless %i(transparent anonymous elite).include?(anon.to_sym)

    url = "https://www.proxy-list.download/api/v1/get?type=https&anon=#{anon}"
    url << "&country=#{country}" if country

    RestClient.get(url) do |resp|
      break if resp.code != 200
      return resp.body.split.map { |proxy| URI.parse("https://#{proxy}") }
    end
    Array.new
  end

  def self.proxy
    RestClient.proxy
  end

  def self.proxy=(uri)
    raise(TypeError, "#{uri} is not a URI") if uri && !uri.is_a?(URI)
    RestClient.proxy = uri
  end

  ##
  # Helper function to automate uploading images to Imgur anonymously and returning the direct image link.
  #
  # @param client_id [String] an Imgur client ID
  # @param image_path [String] the path to an image file.
  # @param opts [Hash] the options hash.
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

  ##
  # Generates a URL for the user to navigate to that will allow them to authorize an application.
  #
  # @param client_id [String] the unique ID of the approved client to authorize.
  # @param redirect [String] the redirect URL where the client sends the OAuth authorization code.
  # @param scopes [Array<Symbol>] a collection of values indicating the permissions the application is requesting from
  #   the user. See {Ruqqus::Client::SCOPES} for valid values.
  # @param permanent [Boolean] `true` if authorization should persist until user explicitly revokes it,
  #   otherwise `false`.
  # @param csrf [String] a token to authenticate and prevent a cross-site request forgery (CSRF) attack, or `nil` if
  #   you do not plan to validate the presence of the cookie in the redirection.
  #
  # @see https://ruqqus.com/settings/apps
  # @see https://owasp.org/www-community/attacks/csrf
  def self.authorize_url(client_id, redirect, scopes, permanent = true, csrf = nil)

    raise(ArgumentError, 'invalid redirect URI') unless URI.regexp =~ redirect
    raise(ArgumentError, 'scopes cannot be empty') unless scopes && !scopes.empty?

    scopes = scopes.map(&:to_sym)
    raise(ArgumentError, "invalid scopes specified") unless scopes.all? { |s| Client::SCOPES.include?(s) }
    if scopes.any? { |s| [:create, :update, :guildmaster].include?(s) } && !scopes.include?(:identity)
      # Add identity permission if missing, which is obviously required for a few other permissions
      scopes << :identity
    end

    url = 'https://ruqqus.com/oauth/authorize'
    url << "?client_id=#{client_id || raise(ArgumentError, 'client ID cannot be nil')}"
    url << "&redirect_uri=#{redirect}"
    url << "&scope=#{scopes.join(',')}"
    url << "&state=#{csrf || Base64.encode64(SecureRandom.uuid).chomp}"
    url << "&permanent=#{permanent}"
    url
  end


  ##
  # Opens a URL in the system's default web browser, using the appropriate command for the host platform.
  #
  # @param [String] the URL to open.
  #
  # @return [void]
  def self.open_browser(url)

    cmd = case RbConfig::CONFIG['host_os']
    when /mswin|mingw|cygwin/ then "start \"\"#{url}\"\""
    when /darwin/ then "open '#{url}'"
    when /linux|bsd/ then "xdg-open '#{url}'"
    else raise(Ruqqus::Error, 'unable to determine how to open URL for current platform')
    end

    system(cmd)
  end

  ##
  # If using a `localhost` address for your application's OAuth redirect, this method can be used to open a socket and
  # listen for a request, returning the authorization code once it arrives.
  #
  # @param port [Integer] the port to listen on.
  # @param timeout [Numeric] sets the number of seconds to wait before cancelling and returning `nil`.
  #
  # @return [String?] the authorization code, `nil` if an error occurred.
  # @note This method is blocking, and will *not* return until a connection is made and data is received on the
  #   specified port, or the timeout is reached.
  def self.wait_for_code(port, timeout = 30)

    thread = Thread.new do
      sleep(timeout)
      TCPSocket.open('localhost', port) { |s| s.puts }
    end

    params = {}
    TCPServer.open('localhost', port) do |server|

      session = server.accept
      request = session.gets
      match = /^GET [\/?]+(.*) HTTP.*/.match(request)

      Thread.kill(thread)
      return nil unless match

      $1.split('&').each do |str|
        key, value = str.split('=')
        next unless key && value
        params[key.to_sym] = value
      end

      session.puts "HTTP/1.1 200\r\n"
      session.puts "Content-Type: text/html\r\n"
      session.puts "\r\n"
      session.puts create_response(!!params[:code])

      session.close
    end

    params[:code]
  end

  private

  ##
  # @return [String] a generic confirmation page to display in the user's browser after confirming application access.
  def self.create_response(success)
    args = success ? ['#339966', 'Authorization Confirmed'] : ['#ff0000', 'Authorization Failed']
    format ='<h1 style="text-align: center;"><span style="color: %s;"><strong>%s</strong></span></h1>'
    message = sprintf(format, *args)
    <<-EOS
<html>
<head>
    <style>
    .center {
      margin: 0;
      position: absolute;
      top: 50%;
      left: 50%;
      -ms-transform: translate(-50%, -50%);
      transform: translate(-50%, -50%);
    }
  </style>
</head>
<body>
<div class="center">
    <div><img src="https://raw.githubusercontent.com/ruqqus/ruqqus/master/ruqqus/assets/images/logo/ruqqus_text_logo.png" alt="" width="365" height="92" /></div>
    <p style="text-align: center;">&nbsp;</p>
    #{message}
    <p style="text-align: center;">&nbsp;&nbsp;</p>
    <p style="text-align: center;"><span style="color: #808080;">You can safely close the tab/browser and return to the application.</span></p>
</div>
</body>
</html>
    EOS
  end

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