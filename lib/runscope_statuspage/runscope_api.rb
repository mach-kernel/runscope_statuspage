require_relative 'runscope_statuspage/exceptions'

module RunscopeStatuspage

class RunscopeAPI
	include HTTParty
	base_uri 'https://api.runscope.com/'

	def initialize(token)
		@options = { headers: {"Authorization": "Bearer #{token}"} }
	end

	def buckets
		buckets = self.class.get("/buckets", @options)
		if buckets.has_key?("meta") and buckets.has_key?("data")
			if buckets["meta"]["status"] == "success"
				buckets["data"]
			else
				raise RunscopeAPIException.new, buckets.to_s
			end
		end
	end

	def all_radars(bucket)
		all_radars = self.class.get("/buckets/#{bucket}/radar", @options)
		if all_radars.has_key?("meta") and all_radars.has_key?("data")
			if all_radars["meta"]["status"] == "success"
				all_radars["data"]
			else
				raise RunscopeAPIException.new, all_radars.to_s
			end
		end
	end

	def one_radar(bucket, radar)
		one_radar = self.class.get("/buckets/#{bucket}/radar/#{radar}", @options)
		if one_radar.has_key?("meta") and one_radar.has_key?("data")
			if one_radar["meta"]["status"] == "success"
				one_radar["data"]
			else
				raise RunscopeAPIException.new, one_radar.to_s
			end
		end
	end

	def latest_radar_result(bucket, radar)
		lrr = self.class.get("/buckets/#{bucket}/radar/#{radar}/results/latest", @options)
		if lrr.has_key?("meta") and lrr.has_key?("data")
			if lrr["meta"]["status"] == "success"
				lrr["data"]
			else
				raise RunscopeAPIException.new, lrr.to_s
			end
		end
	end
end

end
