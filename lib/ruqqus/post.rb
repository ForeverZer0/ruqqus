require_relative 'submission'

module Ruqqus

  ##
  # Represents a post on Ruqqus.
  class Post < Submission

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

    def domain
      @data[:domain]
    end

    def embed_url
      @data[:embed_url]
    end

    def original_guild_name
      @data[:original_guild_name]
    end

    def original_guild
      @original_guild ||= original_guild_name ? Ruqqus.guild(original_guild_name) : nil
    end

    def thumb_url
      @data[:thumb_url]
    end

    def url
      @data[:url]
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
      # TODO
    end
  end
end