module Ruqqus

  ##
  # A module containing constants that define the method routes for the Ruqqus REST API.
  module Routes

    ##
    # The Ruqqus API version.
    API_VERSION = 1

    ##
    # The top-level site URL.
    HOME = 'https://ruqqus.com'.freeze

    ##
    # The base URL for the Ruqqus REST API.
    API_BASE = "#{HOME}/api/v#{API_VERSION}".freeze

    ##
    # The endpoint for the GET method to obtain user information.
    USER = "#{API_BASE}/user/".freeze

    ##
    # The endpoint for the GET method to obtain guild information.
    GUILD = "#{API_BASE}/guild/".freeze

    ##
    # The endpoint for the GET method to obtain post information.
    POST = "#{API_BASE}/post/".freeze

    ##
    # The endpoint for the GET method to obtain comment information.
    COMMENT = "#{API_BASE}/comment/".freeze

    ##
    # The endpoint for the POST method to place a vote on a post.
    POST_VOTE = "#{API_BASE}/vote/post/".freeze

    ##
    # The endpoint for the GET method to query guild availability.
    GUILD_AVAILABLE = "#{HOME}/api/board_available/".freeze

    ##
    # The endpoint for the GET method to query username availability.
    USERNAME_AVAILABLE = "#{HOME}/api/is_available/".freeze

    ##
    # The endpoint for the POST method to submit a post.
    SUBMIT = "#{Routes::API_BASE}/submit/".freeze

    ##
    # The endpoint for the GET method to get the current user.
    IDENTITY = "#{Routes::API_BASE}/identity".freeze

    ##
    # The endpoint for the GET method to get the guild listings.
    GUILDS = "#{Routes::API_BASE}/guilds".freeze

    ##
    # The endpoint for the GET method to get the front page listings.
    FRONT_PAGE = "#{Routes::API_BASE}/front/listing".freeze

    ##
    # The endpoint for the GET method to get all post listings.
    ALL_LISTINGS = "#{Routes::API_BASE}/all/listing".freeze

  end
end