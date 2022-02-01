# frozen_string_literal: true

module Response
  def parse_response
    @parse_response = (@response.class == RestClient::Response) ? JSON.parse(@response) : @response
  end

  def api_response_data(response=@response)
    if response.try(:body).class.name == 'OpenStruct'
      response.body.data
    else
      parse_response['data']
    end
  end

  def api_response_body(response=@response)
    response.body
  end

  def api_response_message(response=@response)
    if response.try(:body).class.name == 'OpenStruct'
      response.body.message
    else
      parse_response['message']
    end
  end

  def api_response_status(response=@response)
    if response.try(:body).class.name == 'OpenStruct'
      response.body.status
    else
      parse_response['status']
    end
  end

  def is_success_status?(response=@response)
    if response.try(:body).class.name == 'OpenStruct'
      case response.body.status
      when true, false
        response.body.status
      else
        response.body.status.try(:downcase) == 'success' ? true : false
      end
    else
      @status = (parse_response['status'] == 'success') ? true : false
    end
  end
end