
module Ruqqus

  ##
  # Describes a comment in a post.
  class Comment < Submission

    ##
    # @!attribute [r] level
    #   @return [Integer] the level of "nesting" in the comment tree, starting at `1` when in direct reply to the post.

    ##
    # @!attribute parent_id
    #   @return [String] the unique ID of the parent for this comment.

    ##
    # @!attribute [r] post_id
    #   @return [String] the ID of the post this comment belongs to.

    ##
    # @return [Boolean] `true` if the comment's parent is comment, otherwise `false` if it is a post.
    def parent_comment?
      level > 1
    end

    ##
    # @return [Boolean] `true` if the comment's parent is post, otherwise `false` if it is a comment.
    def parent_post?
      level == 1
    end

    def level
      @data[:level]
    end

    def parent_id
      @data[:parent]
    end

    def post_id
      @data[:post]
    end
  end
end