
module Ruqqus

  ##
  # Represents a Ruqqus user account.
  class User < ItemBase

    ##
    # @!attribute [r] comment_count
    #   @return [Integer] the number of comments the user has created.

    ##
    # @!attribute [r] post_count
    #   @return [Integer] the number of posts the user has created.

    ##
    # @!attribute [r] comment_rep
    #   @return [Integer] the amount of rep the user has earned from comments.

    ##
    # @!attribute [r] post_rep
    #   @return [Integer] the amount of rep the user has earned from posts.

    ##
    # @!attribute [r] total_rep
    #   @return [Integer] the total amount of rep the user has earned from comments and posts.

    ##
    # @!attribute [r] badges
    #   @return [Array<Badge>] an array of badges associated with this account.

    ##
    # @!attribute [r] title
    #   @return [Title?] the title the user has associated with their account, or `nil` if none is assigned.

    ##
    # @!attribute [r] banner_url
    #   @return [String] the URL for the banner image associated with the account.

    ##
    # @!attribute [r] profile_url
    #   @return [String] the URL for the profile image associated with the account.

    ##
    # @!attribute [r] bio
    #   @return [String] A brief statement/biography the user has associated with their account.

    ##
    # @!attribute [r] bio_html
    #   @return [String] a brief statement/biography the user has associated with their account in HTML format.

    ##
    # @!attribute [r] ban_reason
    #   @return [String?] the reason the user was banned if they were, otherwise `nil`.

    ##
    # @return [String] the string representation of the object.
    def to_s
      @data[:username] || inspect
    end

    def comment_count
      @data[:comment_count] || 0
    end

    def post_count
      @data[:post_count] || 0
    end

    def comment_rep
      @data[:comment_rep] || 0
    end

    def post_rep
      @data[:post_rep] || 0
    end

    def total_rep
      comment_rep + post_rep
    end

    ##
    # @return [String] the username of the account.
    def username
      @data[:username]
    end

    def badges
      #noinspection RubyResolve
      @badges ||= @data[:badges].map { |b| Badge.new(b) }
    end

    def title
      #noinspection RubyYardReturnMatch,RubyResolve
      @title ||= @data[:title] ? Title.new(@data[title]) : nil
    end

    def banner_url
      @data[:banner_url]
    end

    def profile_url
      @data[:profile_url]
    end

    def bio
      @data[:bio]
    end

    def bio_html
      @data[:bio_html]
    end

    def ban_reason
      @data[:ban_reason]
    end
  end
end