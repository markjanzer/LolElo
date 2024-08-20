class PandaScoreAPI
  class Request

    RESULTS_PER_PAGE = 100
    
    def initialize(path: '', params: {})
      puts "PandaScoreAPI::Request path: #{path}, params: #{params}"
      @path = path
      @params = params
      @result = []
    end

    def call(page_number: 1)
      response = HTTParty.get(
        path,
        query: params_with_pagination(page_number)
      )
      json_response = JSON.parse(response.body)
      
      if json_response.is_a?(Hash)
        if json_response.keys.include?("error")
          raise error_string(json_response)
        else
          return json_response
        end
      end

      result.concat(json_response)

      if json_response.length >= RESULTS_PER_PAGE
        call(page_number: page_number + 1)
      else
        return result
      end
    end

    private

    attr_accessor :result
    attr_reader :path, :params

    def params_with_pagination(page_number)
      pagination_hash = {
        'page[size]' => RESULTS_PER_PAGE,
        'page[number]' => page_number
      }
      params_with_token.merge(pagination_hash)
    end

    def params_with_token
      token_hash = { 'token' => ENV['PANDA_SCORE_API_KEY'] }
      params.merge(token_hash)
    end

    def error_string(response)
      "#{response['error']}: #{response['message']}"
    end
  end
end