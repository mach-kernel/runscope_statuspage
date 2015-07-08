require_relative 'runscope_statuspage/version'
require_relative 'runscope_statuspage/exceptions'
require_relative 'runscope_statuspage/runscope_api'
require_relative 'runscope_statuspage/statuspage_api'

module RunscopeStatuspage
  # Let Ruby write boring getters and setters
  class << self; attr_accessor :rs_key, :sp_key, :sp_page, :name, :msg, :rs, :sp; end

  # API credentials and IDs
  @rs_key, @sp_key, @sp_page = ''

  # Verbage sent to statuspage
  @name = 'Suspected issues with /name/'
  @msg = 'Our automated test detected an issue while testing the /description/ endpoint. We are currently investigating this issue.'

  # As the user may decide (for whatever reason)
  # to change API keys after one request, we re-initialize
  # these objects.
  def self.reinit_rest
    @rs = RunscopeAPI.new(@rs_key)
    @sp = StatuspageAPI.new(@sp_key)
  end

  # Splice radar hash values from keys defined in
  # @name and @msg.
  def self.parameterize(radar)
    rname = @name
    rmsg = @msg

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

  # Update status page with all radars, from all buckets.
  # An error will most likely be thrown if you have empty buckets.
  #
  # Parameters: {:status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report and return data}
  def self.report_everything(opts={})
    raise MissingArgumentException.new, 'report_everything is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update))

    opts[:fail_on] = opts.key?(:fail_on) ? opts[:fail_on] : 0
    opts[:no_sp] = opts.key?(:no_sp) ? opts[:no_sp] : false

    failed_radars = []

    reinit_rest
    @rs.buckets.each do |bucket|
      @rs.radars(bucket['key']).each do |radar|
        begin
          if @rs.latest_radar_result(bucket['key'], radar['uuid'])['result'] != 'pass'
            failed_radars.push radar
          end
        rescue RunscopeAPIException => r
          p r
          next
        end
      end
    end

    if failed_radars.length >= opts[:fail_on]
      failed_radars.each do |radar|
        data = *parameterize(radar)

        @sp.create_realtime_incident(@sp_page, data.concat([opts[:status], opts[:twitter_update]])) if not opts[:no_sp]
        data if opts[:no_sp]
      end
    end
  end

  # Update status page with one radar, from one bucket.
  #
  # Parameters: {:bucket_name => name of bucket containing radars,
  #              :radar_name => name of radar within bucket,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report and return data}
  def self.report_radar(opts = {})
    raise MissingArgumentException.new, 'report_radar is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name) or opts.key?(:radar_name))

    opts[:fail_on] = opts.key?(:fail_on) ? opts[:fail_on] : 0
    opts[:no_sp] = opts.key?(:no_sp) ? opts[:no_sp] : false

    failed_radars = []

    reinit_rest
    @rs.buckets.each do |bucket|
      if bucket['name'] == bucket_name
        @rs.radars(bucket['key']).each do |radar|
          begin
            if @rs.latest_radar_result(bucket['key'], radar['uuid'])['result'] != 'pass' and radar['name'] == radar_name
              failed_radars.push radar
            end
          rescue RunscopeAPIException => r
            p r
            next
          end
        end
      end
    end

    if failed_radars.length >= opts[:fail_on]
      failed_radars.each do |radar|
        data = *parameterize(radar)

        @sp.create_realtime_incident(@sp_page, data.concat([opts[:status], opts[:twitter_update]])) if not opts[:no_sp]
        data if opts[:no_sp]
      end
    end
  end

  # Update status page with list of radars, from one bucket.
  #
  # Parameters: {:bucket_name => name of bucket containing radars,
  #              :radar_names => list of names of radars within bucket,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report and return data}
  def self.report_radars(opts = {})
    raise MissingArgumentException.new, 'report_radars is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name) or opts.key?(:radar_names))

    opts[:fail_on] = opts.key?(:fail_on) ? opts[:fail_on] : 0
    opts[:no_sp] = opts.key?(:no_sp) ? opts[:no_sp] : false

    failed_radars = []

    reinit_rest
    @rs.buckets.each do |bucket|
      if bucket['name'] == opts[:bucket_name]
        @rs.radars(bucket['key']).each do |radar|
          begin
            if @rs.latest_radar_result(bucket['key'], radar['uuid'])['result'] != 'pass' and opts[:radar_names].include?(radar['name'])
              failed_radars.push radar
            end
          rescue RunscopeAPIException => r
            p r
            next
          end
        end
      end
    end

    if failed_radars.length >= opts[:fail_on]
      failed_radars.each do |radar|
        data = *parameterize(radar)

        @sp.create_realtime_incident(@sp_page, data.concat([opts[:status], opts[:twitter_update]])) if not opts[:no_sp]
        data if opts[:no_sp]
      end
    end
  end

  # Update status page with all radars under passed
  # bucket name.
  #
  # Parameters: {:bucket_name => name of bucket containing radars,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report and return data}
  def self.report_bucket(opts={})
    raise MissingArgumentException.new, 'report_bucket is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name))

    opts[:fail_on] = opts.key?(:fail_on) ? opts[:fail_on] : 0
    opts[:no_sp] = opts.key?(:no_sp) ? opts[:no_sp] : false

    failed_radars = []

    reinit_rest
    @rs.buckets.each do |bucket|
      if bucket['name'] == opts[:bucket_name]
        @rs.radars(bucket['key']).each do |radar|
          begin
            if @rs.latest_radar_result(bucket['key'], radar['uuid'])['result'] != 'pass'
              failed_radars.push radar
            end
          rescue RunscopeAPIException => r
            p r
            next
          end
        end
      end
    end

    if failed_radars.length >= opts[:fail_on]
      failed_radars.each do |radar|
        data = *parameterize(radar)

        @sp.create_realtime_incident(@sp_page, data.concat([opts[:status], opts[:twitter_update]])) if not opts[:no_sp]
        data if opts[:no_sp]
      end
    end
  end

  # Update status page with all radars under the specified
  # buckets
  #
  # Parameters: {:bucket_names => list of names of buckets containing radars,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report and return data}
  def self.report_buckets(bucket_names, status, twitter_update)
    raise MissingArgumentException.new, 'report_buckets is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name))

    opts[:fail_on] = opts.key?(:fail_on) ? opts[:fail_on] : 0
    opts[:no_sp] = opts.key?(:no_sp) ? opts[:no_sp] : false
    
    failed_radars = []

    reinit_rest

    @rs.buckets.each do |bucket|
      if opts[:bucket_names].include?(bucket['name'])
        @rs.radars(bucket['key']).each do |radar|
          begin
            if @rs.latest_radar_result(bucket['key'], radar['uuid'])['result'] != 'pass'
              failed_radars.push radar
            end
          rescue RunscopeAPIException => r
            p r
            next
          end
        end
      end
    end

    if failed_radars.length >= opts[:fail_on]
      failed_radars.each do |radar|
        data = *parameterize(radar)

        @sp.create_realtime_incident(@sp_page, data.concat([opts[:status], opts[:twitter_update]])) if not opts[:no_sp]
        data if opts[:no_sp]
      end
    end
  end

end
