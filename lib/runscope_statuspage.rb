require_relative "runscope_statuspage/version"
require_relative "runscope_statuspage/runscope_api"
require_relative "runscope_statuspage/statuspage_api"

module RunscopeStatuspage
	class << self; attr_accessor :rs_key, :sp_key, :name, :msg; end

	@rs_key = ""
	@sp_key = ""

	@name = "Suspected issues with /testname/"
	@msg = "Our automated test detected an issue while testing the /url/ endpoint. We are currently investigating this issue."

	def self.parameterize(name, url)
		[ @name.sub!('/testname/', name), @msg.sub!('/url/', url) ]
	end

	def self.report_all_radars(page)
		rs = RunscopeAPI.new(@rs_key)
		sp = StatuspageAPI.new(@sp_key)

		rs.buckets.each do |bucket|
			rs.radars(bucket["key"]).each do |radar|
				if rs.latest_radar_result(bucket["key"], radar["uuid"])["requests"]["result"] == false
					sp.create_realtime_incident(page, *parameterize(radar["name"], radar["test_url"]), 'investigating', false)
				end
			end
		end
	end

	def self.report_radar_by_name(bucket_name, radar)
	end

	def self.report_bucket_by_name(bucket)
	end
	
end
