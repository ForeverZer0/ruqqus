module Ruqqus
  ##
  # Describes a trophy that can be earned/issued to an account for specific accomplishments.
  class Badge

    ##
    # @!attribute [r] name
    #   @return [String?] the name of the badge.

    ##
    # @!attribute [r] text
    #   @return [String?] a brief description of the badge.

    ##
    # @!attribute [r] url
    #   @return [String?] the URL associated with the badge, or `nil` if not defined.

    ##
    # @!attribute [r] created_utc
    #   @return [Integer] the time the badge was earned in seconds since the Unix epoch, or `0` if not defined.

    ##
    # @!attribute [r] created
    #   @return [Time?] the time the badge was earned, or `nil` if not defined.

    ##
    # Creates a new instance of the {Badge} class.
    #
    # @param data [Hash] the parsed JSON payload defining this instance.
    def initialize(data)
      @data = data || raise(ArgumentError, 'data cannot be nil')
    end

    def name
      @data[:name]
    end

    def text
      @data[:text]
    end

    def url
      @data[:url]
    end

    def created_utc
      @data[:created_utc]
    end

    def created
      #noinspection RubyYardReturnMatch
      @data[:created_utc] ? Time.at(@data[:created_utc]) : nil
    end

    def to_s
      @data[:text]
    end
  end
end