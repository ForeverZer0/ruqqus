require_relative 'submission'

module Ruqqus

  ##
  # Represents a post on Ruqqus.
  class Post < Submission

    ##
    # Captures the ID of a post from a Ruqqus URL
    POST_REGEX = /ruqqus.com\/post\/([A-Za-z0-9]+)\/?.*/.freeze

    ##
    # @return [Title?] the title assigned to the author, or `nil` if none is defined.
    def author_title
      #noinspection RubyYardReturnMatch
      @author_title ||= @data[:author_title] ? Title.new(@data[:author_title]) : nil
    end

    ##
    # @return [Integer] the number of comments made on the post.
    def comment_count
      @data[:comment_count]
    end

    ##
    # @return [String] the domain name for link posts, otherwise a short descriptor of the post type.
    def domain
      @data[:domain]
    end

    ##
    # @return [String] the embed URL for the post.
    def embed_url
      @data[:embed_url]
    end

    ##
    # @return [String] the name of the guild this post was originally posted in.
    def original_guild_name
      @data[:original_guild_name]
    end

    ##
    # @return [Guild] the guild this post was originally posted in.
    def original_guild
      @original_guild ||= Ruqqus.guild(original_guild_name)
    end

    ##
    # @return [String?] the URL of the post's thumbnail image, or `nil` if none exists.
    def thumb_url
      @data[:thumb_url]
    end

    ##
    # @return [String?] the URL the post links to, or `nil` if none is specified.
    def url
      #noinspection RubyYardReturnMatch
      @data[:url]&.empty? ? nil : @data[:url]
    end

    ##
    # @return [String] the string representation of the object.
    def to_s
      @data[:title] || inspect
    end

    ##
    # Creates a new {Post} instance from the specified URL.
    #
    # @param [String] a URL link to a post.
    #
    # @return [Post] the {Post} instance the URL links to.
    #
    # @raise [ArgumentError] then `url` is `nil`.
    # @raise [Ruqqus::Error] when the link is not for a Ruqqus post.
    def self.from_url(url)
      raise(ArgumentError, 'url cannot be nil') unless url
      match = POST_REGEX.match(url)
      raise(ArgumentError, 'invalid URL for a post') unless match
      Ruqqus.post($1)
    end
  end
end