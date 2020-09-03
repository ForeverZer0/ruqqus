
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
  end
end