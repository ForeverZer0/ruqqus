require_relative 'item_base'

module Ruqqus

  ##
  # @abstract
  # Base class for {Post} and {Comment} types.
  class Submission < ItemBase

    ##
    # @return [String?] the name of the creator of the item, or `nil` if deleted account.
    def author_name
      @data[:author]
    end

    ##
    # @return [String] the creator of the item, or `nil` if deleted account.
    def author
      #noinspection RubyYardReturnMatch
      @author ||= author_name ? Ruqqus.user(author_name) : nil
    end

    ##
    # @return [String] the text body of the item.
    def body
      @data[:body]
    end

    ##
    # @return [String] the text body of the item in HTML format.
    def body_html
      @data[:body_html]
    end

    ##
    # @return [Integer] the time of the last edit in seconds since the Unix epoch, or `0` if never edited.
    def last_edit_utc
      @data[:edited_utc]
    end

    ##
    # @return [Time] the time of the last edit.
    def last_edit
      Time.at(@data[:edited_utc])
    end

    ##
    # @return [Boolean] `true` if post has been edited, otherwise `false`.
    def edited?
      @data[:edited_utc] != 0
    end

    ##
    # @return [Integer] the number of upvotes this item has received.
    def upvotes
      @data[:upvotes]
    end

    ##
    # @return [Integer] the number of downvotes this item has received.
    def downvotes
      @data[:downvotes]
    end

    ##
    # @return [Integer] a score calculated by adding upvotes and subtracting downvotes.
    def score
      @data[:score]
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
    # @return [String] the full ID of this item.
    def full_name
      @data[:fullname]
    end

    ##
    # @return [String] the name of the guild this item is contained within.
    def guild_name
      @data[:guild_name]
    end

    ##
    # @return [Guild?] the guild this item is contained within.
    def guild
      #noinspection RubyYardReturnMatch
      @guild ||= guild_name ? Ruqqus.guild(guild_name) : nil
    end

    ##
    # @return [String] a unique ID associated with this item.
    def id
      @data[:id]
    end

    ##
    # @return [String] the name/title of this item.
    def title
      @data[:title]
    end
  end
end