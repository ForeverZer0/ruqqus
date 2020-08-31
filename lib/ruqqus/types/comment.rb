
module Ruqqus

  ##
  # Describes a comment in a post.
  class Comment < Submission

    ##
    # Captures the ID of a comment from a Ruqqus URL
    COMMENT_REGEX = /\/post\/.+\/.+\/([A-Za-z0-9]+)\/?/.freeze

    ##
    # @return [Integer] the level of "nesting" in the comment tree, starting at `1` when in direct reply to the post.
    def level
      @data[:level]
    end

    ##
    # @return [String] the unique ID of the parent for this comment.
    def parent_id
      @data[:parent]
    end

    ##
    # @return [Boolean] `true` if {#parent_id} refers to a comment, otherwise `false` if a post.
    def parent_comment?
      level > 1
    end

    ##
    # @return [Boolean] `true` if {#parent_id} refers to a post, otherwise `false` if a comment.
    def parent_post?
      level == 1
    end

    ##
    # @return [String] the ID of the post this comment belongs to.
    def post_id
      @data[:post]
    end

    ##
    # Creates a new {Comment} instance from the specified URL.
    #
    # @param url [String] a URL link to a comment.
    #
    # @return [Comment] the {Comment} instance the URL links to.
    #
    # @raise [ArgumentError] then `url` is `nil`.
    # @raise [Ruqqus::Error] when the link is not for a Ruqqus comment.
    def self.from_url(url)
      raise(ArgumentError, 'url cannot be nil') unless url
      match = COMMENT_REGEX.match(url)
      raise(ArgumentError, 'invalid URL for a comment') unless match
      Ruqqus.comment_info($1)
    end
  end
end