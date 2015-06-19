require_relative 'exceptions'
require 'httparty'

module RunscopeStatuspage

  class StatuspageAPI
    include HTTParty
    base_uri 'https://api.statuspage.io/v1'

    # Set credentials
    def initialize(token)
      @options = { headers: {"Authorization" => "OAuth #{token}"} }
    end

    # Create incident
    def create_realtime_incident(page, name, msg, status, twitter)
      self.class.post("/pages/#{page}/incidents.json", @options.merge!(body: {"incident" => {
                                                                                "name" => name,
                                                                                "message" => msg,
                                                                                "status" => status.nil? ? 'investigating' : status,
                                                                                "wants_twitter_update" => twitter
      }}))
    end

    # Publish data for a custom page metric
    def push_metric_data(page_id, metric_id, data, timestamp)
      self.class.post("/pages/#{page_id}/metrics/#{metric_id}/data.json", @options.merge!(body: {"data" => {
                                                                                                   "value" => data,
                                                                                                   "timestamp" => timestamp
      }}))
    end

    # Delete all data for a custom page metric
    def clear_metric_data
      self.class.delete("/pages/#{page_id}/metrics/#{metric_id}/data.json", @options)
    end

  end

end
