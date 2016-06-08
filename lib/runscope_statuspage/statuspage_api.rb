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
      incident = self.class.post("/pages/#{page}/incidents.json",
        @options.merge!(
          body: {"incident" => {
                 "name" => name,
                 "message" => msg,
                 "status" => status.nil? ? 'investigating' : status,
                 "wants_twitter_update" => twitter
      }}))

      raise StatuspageAPIException.new,
            "Could not create incident: #{incident}" if incident.key?('error')
    end

    # Publish data for a custom page metric
    def push_metric_data(page_id, metric_id, data, timestamp)
      reply = self.class.post("/pages/#{page_id}/metrics/#{metric_id}/data.json",
        @options.merge!(
          body: {"data" => {
                 "value" => data,
                 "timestamp" => timestamp
      }}))

      raise StatuspageAPIException.new,
            "Could not push to #{page_id}/#{metric_id}: #{reply}" if reply.key?('error')
    end

    # Delete all data for a custom page metric
    def clear_metric_data(page_id, metric_id)
      reply = self.class.delete("/pages/#{page_id}/metrics/#{metric_id}/data.json", @options)

      raise StatuspageAPIException.new,
            "Could not delete all data for #{page_id}/#{metric_id}: #{reply}" if reply.key?('error')
    end

  end

end
