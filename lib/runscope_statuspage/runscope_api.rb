require_relative 'exceptions'
require 'httparty'

module RunscopeStatuspage

  class RunscopeAPI
    include HTTParty
    base_uri 'https://api.runscope.com'

    # Set credentials
    def initialize(token)
      @options = { headers: {:Authorization => "Bearer #{token}"} }
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

    # Get a radar, from a bucket.
    def get_radar(bucket, radar)
      get_radar = self.class.get("/buckets/#{bucket}/radar/#{radar}", @options)
      if get_radar.has_key?('meta') and get_radar.has_key?('data')
        if get_radar['meta']['status'] == 'success'
          get_radar['data']
        else
          raise RunscopeAPIException.new, get_radar['error']
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
          raise RunscopeAPIException.new, lrr['error']
        end
      end
    end
  end

end
