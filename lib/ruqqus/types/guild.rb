module Ruqqus

  ##
  # Represents a Ruqqus guild.
  class Guild < ItemBase

    ##
    # @!attribute [r] name
    #   @return [String] the name of the guild.

    ##
    # @!attribute [r] member_count
    #   @return [Integer] the number of members subscribed to the guild.

    ##
    # @!attribute [r] fullname
    #   @return [String] the full ID of the guild.

    ##
    # @!attribute [r] guildmaster_count
    #   @return [Integer] the number of guild masters who moderate this guild.

    ##
    # @!attribute [r] profile_url
    #   @return [String] the URL for the profile image associated with the guild.

    ##
    # @!attribute [r] color
    #   @return [String] the accent color used for the guild, in HTML format.

    ##
    # @!attribute [r] description
    #   @return [String] the description of the guild.

    ##
    # @!attribute [r] description_html
    #   @return [String] the description of the guild in HTML format.

    ##
    # @!attribute [r] banner_url
    #   @return [String] the URL for the banner image associated with the guild.

    ##
    # @return [Boolean] `true` if the guild contains adult content and flagged as NSFW, otherwise `false`.
    def nsfw?
      @data[:over_18]
    end

    ##
    # @return [Boolean] `true` if guild is private and required membership to view content, otherwise `false`.
    def private?
      !!@data[:is_private]
    end

    ##
    # @return [Boolean] `true` if posting is restricted byy guild masters, otherwise `false`.
    def restricted?
      !!@data[:is_restricted]
    end

    ##
    # @return [String] the string representation of the object.
    def to_s
      @data[:name] || inspect
    end

    def description
      @data[:description]
    end

    def banner_url
      @data[:banner_url]
    end

    def description_html
      @data[:description_html]
    end

    def profile_url
      @data[:profile_url]
    end

    def color
      @data[:color]
    end

    def name
      @data[:name]
    end

    def member_count
      @data[:subscriber_count]&.to_i || 0
    end

    def guildmaster_count
      @data[:mods_count]&.to_i || 0
    end

    def fullname
      @data[:fullname]
    end
  end
end