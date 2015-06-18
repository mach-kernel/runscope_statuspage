require_relative "runscope_statuspage/version"
require_relative "runscope_statuspage/exceptions"
require_relative "runscope_statuspage/runscope_api"
require_relative "runscope_statuspage/statuspage_api"

module RunscopeStatuspage
	class << self; attr_accessor :rs_key, :sp_key, :sp_page, :name, :msg; end

	@rs_key = ""
	@sp_key = ""
	@sp_page = ""

	@name = "Suspected issues with /name/"
	@msg = "Our automated test detected an issue while testing the /description/ endpoint. We are currently investigating this issue."

	def self.reinit_rest
		@rs = RunscopeAPI.new(@rs_key)
		@sp = StatuspageAPI.new(@sp_key)
	end

	def self.parameterize(radar)
		rname = @name
		rmsg = @msg

		# Do actual tokenization, skip delimiters
		@name.scan(/.*?(\/)([A-Za-z]*)(\/)/).each do |set|
			set.each do |token|
				if radar.has_key?(token)
					rname = rname.sub!("/#{token}/", radar[token]) unless (token == "/" and token.length == 1)
				end
			end
		end

		@msg.scan(/.*?(\/)([A-Za-z]*)(\/)/).each do |set|
			set.each do |token|
				if radar.has_key?(token)
					rmsg = rmsg.sub!("/#{token}/", radar[token]) unless (token == "/" and token.length == 1)
				end
			end
		end

		return rname, rmsg
	end

	def self.report_everything(page, status, twitter_update)
		reinit_rest

		@rs.buckets.each do |bucket|
			@rs.radars(bucket["key"]).each do |radar|
				if @rs.latest_radar_result(bucket["key"], radar["uuid"])["result"] != "pass"
					@sp.create_realtime_incident(@sp_page, *parameterize(radar).concat([status, twitter_update]))
				end
			end
		end
	end

	def self.report_radar(bucket_name, radar, status)

	end

	def self.report_bucket(bucket_name, status, twitter_update)
		reinit_rest

		@rs.buckets.each do |bucket|
			if bucket["name"] == bucket_name
				@rs.radars(bucket["key"]).each do |radar|					
					if @rs.latest_radar_result(bucket["key"], radar["uuid"])["result"] != "pass"
						@sp.create_realtime_incident(@sp_page, *parameterize(radar).concat([status, twitter_update]))
					end
				end
			end
		end		
	end
	
end
