%w{yaml rubygems rest_client}.each {|lib| require lib}

class ChompyMcUpload
  def initialize
    @github_credentials = YAML::load(File.open("github.yml"))
    @railscast_repos = "/Users/giles/dev/railscasts-episodes"
  end

  def create(repo_name)
    begin
      new_repo = @github_credentials.merge :public => 1, :name => "railscasts/#{repo_name}"
      RestClient.post("https://github.com/api/v2/json/repos/create", new_repo)
    rescue RestClient::ResourceNotFound
      puts 404
    rescue SocketError
      puts "probable wifi fail"
    end
  end

  def list
    (Dir.new(@railscast_repos).collect do |railscast_repo|
      next unless (episode = railscast_repo.match /episode-(\d+)/)
      episode[0].chomp
    end).compact
  end

  # assumes you've already removed the .git dir
  def push(episode)
    puts "creating repo    #{episode}"
    create episode
    puts "pushing episode  #{episode}"
    command_line = <<-COMMAND_LINE
      cp -r #{@railscast_repos}/#{episode} episodes/#{episode}
      cd episodes/#{episode}
      git init
      git add .
      git commit -m 'automatic import from ryanb/railscasts-episodes'
      git remote add origin git@github.com:railscasts/#{episode}.git
      git push -u origin master
      cd -
    COMMAND_LINE
    puts command_line
    system command_line
  end

  def import
    list.each {|episode| push episode}
  end
end

ChompyMcUpload.new.import

