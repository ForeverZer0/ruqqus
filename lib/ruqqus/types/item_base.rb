
module Ruqqus

  ##
  # @abstract
  # Base class for all all major API types.
  class ItemBase

    ##
    # @return [Boolean] `true` if item has been banned, otherwise `false`.
    def banned?
      !!@data[:is_banned]
    end

    ##
    # @return [Integer] the time the item was created, in seconds since the Unix epoch.
    def created_utc
      @data[:created_utc]
    end

    ##
    # @return [Time] the time the item was created.
    def created
      Time.at(created_utc)
    end

    ##
    # @return [String] a unique ID for this item.
    def id
      @data[:id]
    end

    ##
    # @return [Boolean] `true` if this object is equal to another, otherwise `false`.
    def ==(other)
      self.class == other.class && id == other.id
    end

    ##
    # @return [String] a relative link to this item.
    def permalink
      @data[:permalink]
    end

    ##
    # Loads the object from a JSON-formatted string.
    #
    # @param json [String,Hash] a JSON string representing the object.
    #
    # @return [Object] the loaded object.
    def self.from_json(json)
      obj = allocate
      data = json.is_a?(Hash) ? json : JSON.parse(json, symbolize_names: true)
      obj.instance_variable_set(:@data, data)
      obj
    end

    private_class_method :new
  end
end