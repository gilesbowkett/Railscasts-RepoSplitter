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

  def regex(repo)
    repo.match /episode-(\d+)/
  end

  def list
    (Dir.new(@railscast_repos).collect do |railscast_repo|
      next unless (episode = regex(railscast_repo))
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

  def get_real_url(episode)
    redirect = fetch(episode)
    redirect.match(%r{(http://railscasts.com/episodes/[^"]+)})[1]
  end

  # FIXME: all these xyz(episode) methods strongly suggest the need for an Episode object
  def fetch(episode)
    if (match = regex(episode))
      episode_number = match[1]
      Net::HTTP.get URI.parse("http://railscasts.com/episodes/#{episode_number}")
    end
  end
end

@chompy = ChompyMcUpload.new

# import everything (FYI: kaboom! unless Dir.exists? "episodes")
#   @chompy.import

# had some trouble with these, redid them manually
#   @chompy.push "episode-174"
#   @chompy.push "episode-277"

# with this, I can get the GitHub "homepage" attribute for each repo
puts @chompy.list.each {|episode| puts episode; puts @chompy.get_real_url(episode)}

# getting descriptions requires that I hit the real URLs and parse the title tag

