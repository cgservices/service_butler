module ServiceButler
  class Configuration
    # Controls wether to fail silently when the host is unavailable.
    attr_writer :fail_connection_silently

    # X-CG-AUTH-Token which will be added to the request header
    attr_accessor :x_cg_auth_token

    def initialize
      @fail_connection_silently = true
    end

    def fail_connection_silently?
      @fail_connection_silently
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  # Modify the current configuration
  # ```
  # ServiceButler.configure do |config|
  #   config.fail_connection_silently = false
  # end
  # ```
  def self.configure
    yield configuration
  end
end
