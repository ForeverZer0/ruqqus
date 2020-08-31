
module Ruqqus

  ##
  # Represents a Ruqqus user account.
  class User < ItemBase

    ##
    # @return [Integer] the number of comments the user has created.
    def comment_count
      @data[:comment_count] || 0
    end

    ##
    # @return [Integer] the number of posts the user has created.
    def post_count
      @data[:post_count] || 0
    end

    ##
    # @return [Integer] the amount of rep the user has earned from comments.
    def comment_rep
      @data[:comment_rep] || 0
    end

    ##
    # @return [Integer] the amount of rep the user has earned from posts.
    def post_rep
      @data[:post_rep] || 0
    end

    ##
    # @return [Integer] the total amount of rep the user has earned from comments and posts.
    def total_rep
      comment_rep + post_rep
    end

    ##
    # @return [String] the username of the account.
    def username
      @data[:username]
    end

    ##
    # @return [Array<Badge>] an array of badges associated with this account.
    def badges
      @badges ||= @data[:badges].map { |b| Badge.new(b) }
    end

    ##
    # @return [Title?] the title the user has associated with their account, or `nil` if none is assigned.
    def title
      #noinspection RubyYardReturnMatch
      @title ||= @data[:title] ? Title.new(@data[title]) : nil
    end

    ##
    # @return [String] the URL for the banner image associated with the account.
    def banner_url
      @data[:banner_url]
    end

    ##
    # @return [String] the URL for the profile image associated with the account.
    def profile_url
      @data[:profile_url]
    end

    ##
    # @return [String] A brief statement/biography the user has associated with their account.
    def bio
      @data[:bio]
    end

    ##
    # @return [String] a brief statement/biography the user has associated with their account in HTML format.
    def bio_html
      @data[:bio_html]
    end

    ##
    # @return [String?] the reason the user was banned if they were, otherwise `nil`.
    def ban_reason
      @data[:ban_reason]
    end

    ##
    # @return [String] the string representation of the object.
    def to_s
      @data[:username] || inspect
    end
  end
end