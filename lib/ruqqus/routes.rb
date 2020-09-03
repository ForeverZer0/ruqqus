module Ruqqus

  ##
  # A module containing constants that define the method routes for the Ruqqus REST API.
  module Routes

    ##
    # The Ruqqus API version.
    API_VERSION = 1

    ##
    # The base URL for the Ruqqus REST API.
    API_BASE = "https://ruqqus.com/api/v#{API_VERSION}".freeze

    ##
    # The endpoint for the GET method to obtain user information.
    USER_INFO = "#{API_BASE}/user/".freeze

    ##
    # The endpoint for the GET method to obtain guild information.
    GUILD_INFO = "#{API_BASE}/guild/".freeze

    ##
    # The endpoint for the GET method to obtain post information.
    POST_INFO = "#{API_BASE}/post/".freeze

    ##
    # The endpoint for the GET method to obtain comment information.
    COMMENT_INFO = "#{API_BASE}/comment/".freeze

    ##
    # The endpoint for the POST method to place a vote on a post.
    POST_VOTE = "#{API_BASE}/vote/post/".freeze

    ##
    # The endpoint for the POST method to create comments.
    COMMENT = "#{API_BASE}/comment".freeze

    ##
    # The endpoint for the GET method to query guild availability.
    GUILD_AVAILABLE = 'https://ruqqus.com/api/board_available/'.freeze

    ##
    # The endpoint for the GET method to query username availability.
    USERNAME_AVAILABLE = 'https://ruqqus.com/api/is_available/'.freeze
  end
end