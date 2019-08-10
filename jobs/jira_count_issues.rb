require 'jira-ruby'

########################################################

ISSUE_COUNTER = {
	'jira_open_issues' => { 
		:query => "(Status = \"SELECTED FOR DEVELOPMENT\" OR Status = \"IN PROGRESS\" OR Status = \"REVIEW\") AND PROJECT = \"sc\" AND SPRINT in openSprints()" 
	},
}

########################################################

JIRA_PROPS = {
	'url' => URI.parse(ENV['JIRA_URL']),
	'username' => ENV['JIRA_USERNAME'],
	'password' => ENV['JIRA_PASSWORD'],
	'proxy_address' => nil,
	'proxy_port' => nil
}

jira_options = {
	:username => JIRA_PROPS['username'],
	:password => JIRA_PROPS['password'],
	:context_path => JIRA_PROPS['url'].path,
	:site => JIRA_PROPS['url'].scheme + "://" + JIRA_PROPS['url'].host,
	:auth_type => :basic,
	:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
	:use_ssl => JIRA_PROPS['url'].scheme == 'https' ? true : false,
	:proxy_address => JIRA_PROPS['proxy_address'],
	:proxy_port => JIRA_PROPS['proxy_port']
}

ISSUE_COUNTER.each do |filter_data_id, filter|
	SCHEDULER.every '5m', :first_in => 0 do |job|
		client = JIRA::Client.new(jira_options)
		query = filter[:query]
		current_number_issues = client.Issue.jql(query).size
		send_event(filter_data_id, { current: current_number_issues })
	end
end