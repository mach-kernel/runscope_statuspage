require_relative 'runscope_statuspage/version'
require_relative 'runscope_statuspage/exceptions'
require_relative 'runscope_statuspage/runscope_api'
require_relative 'runscope_statuspage/statuspage_api'

module RunscopeStatuspage
  class << self; attr_accessor :rs_key, :sp_key, :sp_page, :name, :msg, :rs, :sp; end
  @rs_key, @sp_key, @sp_page = ''

  # Re-initialize in case user changes API keys
  def self.reinit_rest
    @rs = RunscopeAPI.new(@rs_key)
    @sp = StatuspageAPI.new(@sp_key)
  end

  # Verbage sent to statuspage
  @name = 'Suspected issues with "/name/"'
  @msg = 'Our automated test detected an issue while testing the "/description/" endpoint and our team was notified of the issue.'

  # Splice radar hash values from keys defined in @name and @msg.
  def self.parameterizeMsg(radar, msg)
    rmsg = msg

    msg.scan(/.*?(\/)([A-Za-z]*)(\/)/).each do |set|
      set.each do |token|
        if radar.has_key?(token)
          next if radar["#{token}"].nil?
          rmsg = rmsg.sub!("/#{token}/", radar[token]) unless (token == "/" and token.length == 1)
        end
      end
    end

    return rmsg
  end

  def self.parameterize(radar)
    return *parameterizeMsg(radar, @name), *parameterizeMsg(radar, @msg)
  end

  def self.get_failure_msgs_and_create_incidents(failed_radars, status, twitter_update, fail_on, no_sp)
    failure_msgs = []

    if failed_radars.length >= fail_on
      failed_radars.each do |radar|
        data = *parameterize(radar)

        @sp.create_realtime_incident(@sp_page, data.concat([status, twitter_update])) if not no_sp
        failure_msgs.push data
      end
    end

    return failure_msgs
  end

  def self.get_bucket(bucket_name)
    @rs.buckets.each do |bucket|
      if bucket['name'] == bucket_name
        return bucket
      end
    end
  end

  def self.radar_failed?(bucket, radar)
    @rs.latest_radar_result(bucket['key'], radar['uuid'])['result'] != 'pass'
  end

  def self.get_failed_radars(bucket, radar_names, all_radars = false)
    failed_radars = []

    if  bucket
      @rs.radars(bucket['key']).each do |radar|
          begin
            if (all_radars or radar_names.include?(radar['name'])) and radar_failed?(bucket, radar)
              failed_radars.push radar
            end
          rescue RunscopeAPIException => r
            p r
            next
          end
        end
    end

    return failed_radars
  end

  # Update status page with the specified radar from the specified bucket.
  #
  # Parameters: {:bucket_name => name of bucket containing radars,
  #              :radar_name => name of radar within bucket,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report}
  def self.report_radar(opts = {})
    raise MissingArgumentException.new, 'report_radar is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name) or opts.key?(:radar_name))
    reinit_rest

    bucket = get_bucket(opts[:bucket_name])
    return get_failure_msgs_and_create_incidents(
      get_failed_radars(bucket, [opts[:radar_name]]),
      opts[:status],
      opts[:twitter_update],
      opts.key?(:fail_on) ? opts[:fail_on] : 0,
      opts.key?(:no_sp) ? opts[:no_sp] : false)
  end

  # Update status page with all specified radars from the specified bucket.
  #
  # Parameters: {:bucket_name => name of bucket containing radars,
  #              :radar_names => list of names of radars within bucket,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report}
  def self.report_radars(opts = {})
    raise MissingArgumentException.new, 'report_radars is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name) or opts.key?(:radar_names))
    reinit_rest

    bucket = get_bucket(opts[:bucket_name])
    return get_failure_msgs_and_create_incidents(
      get_failed_radars(bucket, opts[:radar_names]),
      opts[:status],
      opts[:twitter_update],
      opts.key?(:fail_on) ? opts[:fail_on] : 0,
      opts.key?(:no_sp) ? opts[:no_sp] : false)
  end

  # Update status page with all radars from the specified bucket.
  #
  # Parameters: {:bucket_name => name of bucket containing radars,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report}
  def self.report_bucket(opts={})
    raise MissingArgumentException.new, 'report_bucket is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name))
    reinit_rest

    bucket = get_bucket(opts[:bucket_name])
    return get_failure_msgs_and_create_incidents(
      get_failed_radars(bucket, [], true),
      opts[:status],
      opts[:twitter_update],
      opts.key?(:fail_on) ? opts[:fail_on] : 0,
      opts.key?(:no_sp) ? opts[:no_sp] : false)
  end

  # Update status page with all radars from all specified buckets.
  #
  # Parameters: {:bucket_names => list of names of buckets containing radars,
  #              :status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report}
  def self.report_buckets(opts={})
    raise MissingArgumentException.new, 'report_buckets is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update) \
      or opts.key?(:bucket_name))
    reinit_rest

    failed_radars = []

    @rs.buckets.each do |bucket|
      if opts[:bucket_names].include?(bucket['name'])
        failed_radars.concat get_failed_radars(bucket, [], true)
      end
    end

    return get_failure_msgs_and_create_incidents(
      failed_radars,
      opts[:status],
      opts[:twitter_update],
      opts.key?(:fail_on) ? opts[:fail_on] : 0,
      opts.key?(:no_sp) ? opts[:no_sp] : false)
  end

  # Update status page with all radars from all buckets.
  #
  # Parameters: {:status => page status (either 'investigating|identified|monitoring|resolved'),
  #              :twitter_update => do you want to post status to twitter (bool),
  #              :fail_on => number of failures to induce statuspage update (int, default 0),
  #              :no_sp => skip statuspage.io report}
  def self.report_everything(opts={})
    raise MissingArgumentException.new, 'report_everything is missing arguments' \
      if not (opts.key?(:status) or opts.key?(:twitter_update))
    reinit_rest

    failed_radars = []

    @rs.buckets.each do |bucket|
      failed_radars.concat get_failed_radars(bucket, [], true)
    end

    return get_failure_msgs_and_create_incidents(
      failed_radars,
      opts[:status],
      opts[:twitter_update],
      opts.key?(:fail_on) ? opts[:fail_on] : 0,
      opts.key?(:no_sp) ? opts[:no_sp] : false)
  end
end
