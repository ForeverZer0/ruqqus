module Ruqqus

  ##
  # A module containing constants the define the method routes for the Ruqqus REST API.
  module Routes

    ##
    # The Ruqqus API version.
    API_VERSION = 1

    ##
    # The base URL for the Ruqqus REST API.
    API_BASE = "https://ruqqus.com/api/v#{API_VERSION}".freeze

    ##
    # The route for the GET methods to obtain user information.
    USER_INFO = "#{API_BASE}/user/".freeze

    ##
    # The route for the GET methods to obtain guild information.
    GUILD_INFO = "#{API_BASE}/guild/".freeze

    ##
    # The route for the GET methods to obtain post information.
    POST_INFO = "#{API_BASE}/post/".freeze

    ##
    # The route for the GET methods to obtain comment information.
    COMMENT_INFO = "#{API_BASE}/comment/".freeze
  end
end