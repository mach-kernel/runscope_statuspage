require "runscope_statuspage/version"
require "runscope_statuspage/runscope_api"
require "runscope_statuspage/statuspage_api"

module RunscopeStatuspage
	attr_accessor :rs_key, :sp_key, :name, :msg

	@rs_key = nil
	@sp_key = nil

	@name = "Suspected issues with /testname/"
	@msg = "Our automated test detected an issue while testing the /url/ endpoint. We are currently investigating this issue."

	def self.parameterize
		
	end

	def self.report_all_radars
		rs = new RunscopeAPI(@rs_key)

		rs.buckets.each do |bucket|
			rs.all_radars(bucket["key"]).each do |radar|
				if rs.latest_radar_result(bucket, radar)["requests"]["result"] == false

				end
			end
		end
	end

	def self.report_one_radar(bucket_name, radar)
	end

	def self.report_one_bucket(bucket)
	end
	
end
