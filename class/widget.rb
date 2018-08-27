class Widget
  attr_accessor :organizationId, :username, :token, :widgetCommonId

  def initialize(options)
    @organizationId = options[:organization_id]
    @widgetCommonId = options[:widget_id]
    @username = options[:username]
    @token = options[:token]

    # puts "@organizationId : #{@organizationId}"
    # puts "@widgetCommonId : #{@widgetCommonId}"
    # puts "@username : #{@username}"
    # puts "@token : #{@token}"
  end

  def execute_api(api, type, param="", page)
    cmd = nil
    raw_json_temp = nil

    cmd = setup_full_api(api, type , param, page)

    Open3.popen3(cmd) { |stdin, stdout, stderr, wait_thr| raw_json_temp = stdout.read }
    return JSON.parse(raw_json_temp)
  end

  def setup_full_api(api, type, param="", page=0)
    cmd = ""
    if type == "PUT"
      cmd = setup_put_api(api, param)
    elsif type == "GET"
      cmd = setup_get_api(api, page)
    end

    cmd
  end

  def setup_put_api(api, param="")
    cmd = "curl -X PUT \"#{api}\""
    cmd += " -H \"organizationId: #{organizationId}\""
    cmd += " -H \"Content-Type: application/json\""
    cmd += " -u \"#{username}\":\"#{token}\""

    unless param == ""
      cmd += " -d \'#{param}\'"
    end

    cmd
  end

  def setup_get_api(api, page)
    cmd = nil

    if page == 0
      # execute api for the first time
      cmd = "curl -X GET \"#{api}\" -H \"organizationId: #{organizationId}\" -u \"#{username}\":\"#{token}\""
    else
      # next api execution (get remaining pages)
      if api.include? "?"
        cmd = "curl -X GET \"#{api}&page=#{page}\" -H \"organizationId: #{organizationId}\" -u \"#{username}\":\"#{token}\""
      else
        cmd = "curl -X GET \"#{api}?page=#{page}\" -H \"organizationId: #{organizationId}\" -u \"#{username}\":\"#{token}\""
      end
    end

    cmd
  end

  def get_array_of_raw_json(api, type)
    raw_json_arr = []
    # puts setup_full_api(api, type, "", 0) # coba kita check
    # puts "............."

    # execute api for the first time
    raw_json_arr << execute_api(api, type, "", 0)

    next_page = raw_json_arr[-1]["page"] + 1
    total_page = raw_json_arr[-1]["pages"]

    if total_page > 1
      # next api execution (get remaining pages)
      while next_page < total_page do
        # puts setup_full_api(api, type, "", next_page) # coba kita check
        # puts "............."

        raw_json_arr << execute_api(api, type, "", next_page)
        next_page = raw_json_arr[-1]["page"] + 1
      end
    end

    return raw_json_arr
  end
end
