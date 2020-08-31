
module Ruqqus

  ##
  # Describes a title associated with a username.
  class Title

    ##
    # @!attribute [r] id
    #   @return [Integer] a unique ID associated with this title.

    ##
    # @!attribute [r] text
    #   @return [String] the text value of the title.

    ##
    # @!attribute [r] color
    #   @return [String] the color used to display the title in HTML format.

    ##
    # @!attribute [r] kind
    #   @return [Integer] an integer determining the "rank" of the title.

    ##
    # Creates a new instance of the {Title} class.
    #
    # @param data [Hash] the parsed JSON payload defining this instance.
    def initialize(data)
      @data = data || raise(ArgumentError, 'data cannot be nil')
    end

    def id
      @data[:id]
    end

    def text
      @data[:text]
    end

    def color
      @data[:color]
    end

    def kind
      @data[:kind]
    end
  end
end
