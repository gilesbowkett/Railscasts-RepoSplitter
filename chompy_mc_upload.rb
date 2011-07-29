%w{yaml rubygems rest_client}.each {|lib| require lib}

class ChompyMcUpload
  def initialize
    @github_credentials = YAML::load(File.open("github.yml"))
    @railscast_repos = "/Users/giles/dev/railscasts-episodes"
  end

  def create(repo_name)
    begin
      new_repo = github_credentials.merge :public => 1, :name => "railscasts/#{repo_name}"
      RestClient.post("https://github.com/api/v2/json/repos/create", new_repo)
    rescue RestClient::ResourceNotFound
      puts 404
    rescue SocketError
      puts "probable wifi fail"
    end
  end

  def list
    Dir.new(@railscast_repos).collect do |railscast_repo|
      next unless (episode = railscast_repo.match /episode-(\d+)/)
      episode.chomp
    end
  end
end

ChompyMcUpload.new.list

