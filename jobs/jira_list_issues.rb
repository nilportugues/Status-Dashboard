require 'jira-ruby'
require 'net/http'
require 'json'

########################################################

ISSUE_LISTS = [
  {:widget_id => 'jira-feueralarme', :title => "Feueralarme", 
    :query => "PROJECT = \"sc\" AND urgency = \"🔥🙀👩‍🚒Feueralarm!\"  AND SPRINT in openSprints()"
  },
  {:widget_id => 'jira-blocker', :title => "Blocker", 
    :query => "PROJECT = \"sc\" AND priority = \"Blocker\" AND SPRINT in openSprints()"
  },
]

########################################################

JIRA_CONFIG = {
  :site         => ENV['JIRA_URL'],
  :username     => ENV['JIRA_USERNAME'],
  :password     => ENV['JIRA_PASSWORD'],
  :auth_type    => :basic,
  :context_path => ''
}

# Constants (do not change)
JIRA_URI = URI.parse(JIRA_CONFIG[:site])
JIRA_ANON_AVATAR_ID = 10123


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
  if JIRA_CONFIG[:username]
    request.basic_auth(JIRA_CONFIG[:username], JIRA_CONFIG[:password])
  end
  return request
end

ISSUE_LISTS.each do |list_config| 
  SCHEDULER.every '5m', :first_in => 0 do |job|    
    issues = []
    query = list_config[:query]
    title = list_config[:title]
    client = JIRA::Client.new(JIRA_CONFIG)
    client.Issue.jql(query).each { |issue|
        assigneeAvatarUrl = issue.assignee.nil? ? URI.join(JIRA_URI.to_s, "secure/useravatar?avatarId=#{JIRA_ANON_AVATAR_ID}") : issue.assignee.avatarUrls["48x48"]
        assigneeName = issue.assignee.nil? ? "unassigned" : issue.assignee.name

        issues.push({
         id: issue.key,
         title: issue.summary,
         assigneeName: assigneeName,
         assigneeAvatarUrl: assigneeAvatarUrl
        })
    }

    send_event(list_config[:widget_id], { header: title, issues: issues})
  end
end