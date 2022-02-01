# frozen_string_literal: true

module ApiBase
  def self.included(base)
    base.extend(Methods)
    base.send(:include, Methods)
  end

  module Methods
    def call_api(method_type, url, headers={}, data={})
      headers = headers.with_indifferent_access
      @connection = Faraday.new(url: url, ssl: { verify: true }) do |f|
        if is_json_request?(method_type, headers)
          f.request :json
          data = data.to_json
        elsif headers[:'Content-Type']&.include?('multipart/form-data')
          f.request :multipart
          data = data.to_hash
        else
          f.request :url_encoded
        end
        f.response :json, parser_options: { object_class: OpenStruct }
        f.options.params_encoder, f.headers = Faraday::FlatParamsEncoder, headers
        f.adapter Faraday.default_adapter
        f.options.open_timeout = f.options.timeout = 180
      end
      @connection.send(method_type.downcase.to_sym, url, data)
      rescue Faraday::Error => e
        OpenStruct.new({status: 500, body: { message: e.message }})
    end

    def parse_response(response=@response)
      if (200..299).include?(response.try(:status)) || (response.class == String)
        row_json = response.try(:body).presence || response
      else
        return response.to_hash.slice(:status, :body)
      end
      JSON.parse(row_json.presence || {}.to_json) rescue row_json
    end

    private
      def is_json_request?(method_type, headers)
        %i[post put patch].include?(method_type.to_sym.downcase) &&
        headers[:'Content-Type']&.include?('application/json')
      end
  end
end