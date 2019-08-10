# Displays the board name, sprint name and remaining days for the active sprint for a specific board in Jira Agile

require 'net/http'
require 'json'
require 'time'

########################################################

SPRINTS = {
  'view1' => { :view_id => 29, :view_title => "Sprint Days" },
}

########################################################

JIRA_URI = URI.parse(ENV['JIRA_URL'])
JIRA_AUTH = {
  'name' => ENV['JIRA_USERNAME'],
  'password' => ENV['JIRA_PASSWORD'],
}

# gets the view for a given view id
def get_view_for_viewid(view_id)
  http = create_http
  request = create_request("/rest/greenhopper/1.0/rapidviews/list")
  response = http.request(request)
  views = JSON.parse(response.body)['views']
  views.each do |view|
    if view['id'] == view_id
      return view
    end
  end
end

# gets the active sprint for the view
def get_active_sprint_for_view(view_id)
  http = create_http
  request = create_request("/rest/greenhopper/1.0/sprintquery/#{view_id}")
  response = http.request(request)
  sprints = JSON.parse(response.body)['sprints']
  sprints.each do |sprint|
    if sprint['state'] == 'ACTIVE'
      return sprint
    end
  end
end

# gets the remaining days for the sprint
def get_remaining_days(view_id, sprint_id)
  http = create_http
  request = create_request("/rest/greenhopper/1.0/gadgets/sprints/remainingdays?rapidViewId=#{view_id}&sprintId=#{sprint_id}")
  response = http.request(request)
  JSON.parse(response.body)
end

# create HTTP
def create_http
  http = Net::HTTP.new(JIRA_URI.host, JIRA_URI.port)
  if ('https' == JIRA_URI.scheme)
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  return http
end

# create HTTP request for given path
def create_request(path)
  request = Net::HTTP::Get.new(JIRA_URI.path + path)
  if JIRA_AUTH['name']
    request.basic_auth(JIRA_AUTH['name'], JIRA_AUTH['password'])
  end
  return request
end

SPRINTS.each do |view, view_id|
  SCHEDULER.every '1h', :first_in => 0 do |id|
    sprint_name = ""
    days = ""
    view_json = get_view_for_viewid(view_id[:view_id])
    if (view_json)
      sprint_json = get_active_sprint_for_view(view_json['id'])
      if (sprint_json)
        sprint_name = sprint_json['name']
        days_json = get_remaining_days(view_json['id'], sprint_json['id'])
        days = days_json['days']
      end
    end

    send_event(view, {
      viewName: view_id[:view_title],
      sprintName: sprint_name,
      daysRemaining: days
    })
  end
end
