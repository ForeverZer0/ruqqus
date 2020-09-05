
module Ruqqus

  ##
  # Represents a post on Ruqqus.
  class Post < Submission

    ##
    # @!attribute [r] thumb_url
    #   @return [String?] the URL of the post's thumbnail image, or `nil` if none exists.

    ##
    # @!attribute [r] url
    #   @return [String?] the URL the post links to, or `nil` if none is specified.

    ##
    # @!attribute [r] author_title
    #   @return [Title?] the title assigned to the author, or `nil` if none is defined.

    ##
    # @!attribute [r] comment_count
    #   @return [Integer] the number of comments made on the post.

    ##
    # @!attribute [r] domain
    #   @return [String] the domain name for link posts, otherwise a short descriptor of the post type.

    ##
    # @!attribute [r] embed_url
    #   @return [String] the embed URL for the post.

    ##
    # @!attribute [r] original_guild_name
    #   @return [String] the name of the guild this post was originally posted in.

    # @@!attribute [r] title
    #   @return [String] the post title.


    def author_title
      #noinspection RubyYardReturnMatch,RubyResolve
      @author_title ||= @data[:author_title] ? Title.new(@data[:author_title]) : nil
    end

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

    def thumb_url
      @data[:thumb_url]
    end

    def url
      #noinspection RubyYardReturnMatch
      @data[:url]&.empty? ? nil : @data[:url]
    end
  end
end