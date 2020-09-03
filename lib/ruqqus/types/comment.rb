
module Ruqqus

  ##
  # Describes a comment in a post.
  class Comment < Submission

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
  end
end