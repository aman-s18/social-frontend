# frozen_string_literal: true

class ApiGatewayController < ActionController::API
  include ApiBase
  include Response

  def call
    url = "#{Rails.application.secrets.core_api_host}/#{@uri || api_permitted_params[:uri]}"
    data = api_permitted_params.except(:uri).merge(bank_data: params[:data])
    @response = call_api(request.method, url, headers, data)
    if is_success_status?
      render json: api_response_body, status: @response.status
    else
      render json: api_response_body, status: @response.status
    end
  end

  def kreditz
    @uri = "kreditz/#{api_permitted_params[:uri]}"
    call
  end

  private
    def headers
      except_headers = %w[REMOTE_ADDR VERSION SCRIPT_NAME SERVER_PROTOCOL SERVER_SOFTWARE GATEWAY_INTERFACE USER_AGENT CACHE_CONTROL POSTMAN_TOKEN HOST ACCEPT_ENCODING CONNECTION CONTENT_LENGTH SERVER_NAME SERVER_PORT QUERY_STRING REQUEST_METHOD PATH_INFO]
      request.headers
             .env
             .select{|k, _| k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || k =~ /^HTTP_/}
             .transform_keys{|k| k == 'CONTENT_TYPE' ? (k = 'Content-Type') : k.gsub('HTTP_', '')}
             .except(*except_headers)
    end

    def api_permitted_params
      params.permit(*params.except(:action, :controller, :api_gateway).keys)
    end
end
