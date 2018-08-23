class Organization
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

  def get_array_of_raw_json(api)
    raw_json_temp = nil
    raw_json_arr = []

    # execute api for the first time
    cmd = "curl -X GET \"#{api}\" -H \"organizationId: #{organizationId}\" -u \"#{username}\":\"#{token}\""
    Open3.popen3(cmd) { |stdin, stdout, stderr, wait_thr| raw_json_temp = stdout.read }
    raw_json_arr << JSON.parse(raw_json_temp)

    next_page = raw_json_arr[-1]["page"] + 1
    total_page = raw_json_arr[-1]["pages"]

    if total_page > 1
      # next api execution (get remaining pages)
      while next_page < total_page do
        if api.include? "?"
          cmd = "curl -X GET \"#{api}&page=#{next_page}\" -H \"organizationId: #{organizationId}\" -u \"#{username}\":\"#{token}\""
        else
          cmd = "curl -X GET \"#{api}?page=#{next_page}\" -H \"organizationId: #{organizationId}\" -u \"#{username}\":\"#{token}\""
        end

        Open3.popen3(cmd) { |stdin, stdout, stderr, wait_thr| raw_json_temp = stdout.read }
        raw_json_arr << JSON.parse(raw_json_temp)

        next_page = raw_json_arr[-1]["page"] + 1
      end
    end

    return raw_json_arr
  end
end
