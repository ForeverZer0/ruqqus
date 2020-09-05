
module Ruqqus

  ##
  # @abstract
  # Base class for {Post} and {Comment} types.
  class Submission < ItemBase

    ##
    # @!attribute [r] title
    #   @return [String] the name/title of this item.

    ##
    # @!attribute [r] author_name
    #   @return [String?] the name of the creator of the item, or `nil` if deleted account.

    ##
    # @!attribute [r] body
    #   @return [String] the text body of the item.

    ##
    # @!attribute [r] body_html
    #   @return [String] the text body of the item in HTML format.

    ##
    # @!attribute [r] last_edit_utc
    #   @return [Integer] the time of the last edit in seconds since the Unix epoch, or `0` if never edited.

    ##
    # @!attribute [r] last_edit
    #   @return [Time] the time of the last edit.

    ##
    # @!attribute [r] upvotes
    #   @return [Integer] the number of upvotes this item has received.

    ##
    # @!attribute [r] downvotes
    #   @return [Integer] the number of downvotes this item has received.

    ##
    # @!attribute [r] score
    # @return [Integer] a score calculated by adding upvotes and subtracting downvotes.

    ##
    # @!attribute [r] fullname
    #   @return [String] the full ID of this item.

    ##
    # @!attribute [r] guild_name
    #   @return [String] the name of the guild this item is contained within.

    ##
    # @return [Boolean] `true` if post has been edited, otherwise `false`.
    def edited?
      @data[:edited_utc] != 0
    end

    ##
    # @return [Boolean] `true` if item is adult content and flagged as NSFW, otherwise `false`.
    def nsfw?
      !!@data[:is_nsfw]
    end

    ##
    # @return [Boolean] `true` if item is adult content and flagged as NSFL, otheriwse `false`.
    def nsfl?
      !!@data[:is_nsfl]
    end

    ##
    # @return [Boolean] `true` if item has been archived, otherwise `false`.
    def archived?
      !!@data[:is_archived]
    end

    ##
    # @return [Boolean] `true` if item has been deleted, otherwise `false`.
    def deleted?
      !!@data[:is_deleted]
    end

    ##
    # @return [Boolean] `true` if item has been classified has offensive, otherwise `false`.
    def offensive?
      !!@data[:is_offensive]
    end

    ##
    # @return [String] the string representation of the object.
    def to_s
      @data[:id]
    end

    def author_name
      @data[:author]
    end

    def body
      @data[:body]
    end

    def body_html
      @data[:body_html]
    end

    def last_edit_utc
      @data[:edited_utc]
    end

    def last_edit
      Time.at(@data[:edited_utc])
    end

    def upvotes
      @data[:upvotes]
    end

    def downvotes
      @data[:downvotes]
    end

    def score
      @data[:score]
    end

    def fullname
      @data[:fullname]
    end

    def guild_name
      @data[:guild_name]
    end

    def title
      @data[:title]
    end
  end
end