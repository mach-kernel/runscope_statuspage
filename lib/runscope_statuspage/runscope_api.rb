require_relative 'exceptions'
require 'httparty'

module RunscopeStatuspage

  class RunscopeAPI
    include HTTParty
    base_uri 'https://api.runscope.com'

    # Set credentials
    def initialize(token)
      @options = { headers: {"Authorization" => "Bearer #{token}"} }
    end

    # Get list of buckets
    def buckets
      buckets = self.class.get('/buckets', @options)
      if buckets.has_key?('meta') and buckets.has_key?('data')
        if buckets['meta']['status'] == 'success'
          buckets['data']
        else
          raise RunscopeAPIException.new, buckets['error']
        end
      end
    end

    # Get bucket ID by name
    def bucket_id_by_name(name)
      self.buckets.each do |bucket|
        return bucket["key"] if bucket["name"] == name
      end
    end

    # Get list of radars for bucket
    def radars(bucket)
      radars = self.class.get("/buckets/#{bucket}/radar", @options)
      if radars.has_key?('meta') and radars.has_key?('data')
        if radars['meta']['status'] == 'success'
          radars['data']
        else
          raise RunscopeAPIException.new, radars['error']
        end
      end
    end

    # Get a radar, from a bucket
    def get_radar(bucket, radar)
      get_radar = self.class.get("/buckets/#{bucket}/radar/#{radar}", @options)
      if get_radar.has_key?('meta') and get_radar.has_key?('data')
        if get_radar['meta']['status'] == 'success'
          get_radar['data']
        else
          raise RunscopeAPIException.new,
                "Error attempting to get radar info for #{bucket}, #{radar}: #{get_radar['error']}"
        end
      end
    end

    # Get latest result from radar
    def latest_radar_result(bucket, radar)
      lrr = self.class.get("/buckets/#{bucket}/radar/#{radar}/results/latest", @options)
      if lrr.has_key?('meta') and lrr.has_key?('data')
        if lrr['meta']['status'] == 'success'
          lrr['data']
        else
          raise RunscopeAPIException.new,
                "Error attempting to fetch latest radar result for #{bucket}, #{radar}: #{lrr['error']}"
        end
      end
    end

    # Get latest messages
    def messages(bucket, count)
      messages = self.class.get("/buckets/#{bucket_id_by_name(bucket)}/messages?count=#{count}", @options)
      if messages.has_key?('meta') and messages.has_key?('data')
        if messages['meta']['status'] == 'success'
          messages['data']
        else
          raise RunscopeAPIException.new,
                "Error attempting to fetch messages for #{bucket}: #{detail['error']}"
        end
      end
    end

    # Get message detail
    def message_detail(bucket, message)
      detail = self.class.get("/buckets/#{bucket}/messages/#{message}", @options)
      if detail.has_key?('meta') and detail.has_key?('data')
        if detail['meta']['status'] == 'success'
          detail['data']
        else
          raise RunscopeAPIException.new,
                "Error attempting to fetch message detail for #{bucket}, #{message}: #{detail['error']}"
        end
      end
    end
  end

end
