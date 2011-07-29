%w{yaml rubygems rest_client}.each {|lib| require lib}

github_credentials = YAML::load(File.open("github.yml"))

begin
  new_repo = github_credentials.merge :public => 1, :name => "railscasts/asdf23"
  RestClient.post("https://github.com/api/v2/json/repos/create", new_repo)
rescue RestClient::ResourceNotFound
  puts 404
end

