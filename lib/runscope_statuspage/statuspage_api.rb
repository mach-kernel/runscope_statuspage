require_relative 'exceptions'
require 'httparty'

module RunscopeStatuspage

class StatuspageAPI
	include HTTParty
	base_uri 'https://api.statuspage.io/v1/'

	def initialize(token)
		@options = { headers: {"Authorization" => "OAuth #{token}"} }
	end

	def create_realtime_incident(page, name, msg, status, twitter)
		self.class.post("/pages/#{page}/incidents.json", @options.merge!(body: {
			"name" => name,
			"message" => msg, 
			"status" => status.nil? ? 'investigating' : status,
			"twitter" => twitter
		}))
	end
end

end
