class FeatureBranch < ActiveRecord::Base
  belongs_to :repo
  belongs_to :docker_operation
  before_create :set_gh_info

  def self.from_request(request)
    branch, name, user, *host = request.host.split('.')
    self.from_data branch, name, user
  end

  def self.from_params(params)
    self.from_data params[:user], params[:name], params[:branch]
  end

  def docker_image?
    docker_image.present?
  end

  def docker_container?
    docker_container.present?
  end

  def port
    /0\.0\.0\.0:(\d+)->/.match(docker_container[5])[1]
  end

  def full_name
    "#{repo.full_name}/#{name}"
  end

  def build
    url = "https://#{Rails.application.secrets.gh_token}@github.com/#{repo.full_name}.git"
    commands = ["git clone -b #{name} #{url} repo",
            "cd repo && docker build -t #{docker_name} -f #{repo.dockerfile} ."]
    do_operation 'build', commands
  end

  def launch
    secrets = repo.secrets.map { |k,v| "-e #{k}=#{v}" }.join ' '
    command = "docker run -d -P --name #{docker_name} #{secrets} #{docker_name}"
    do_operation 'launch', command
  end

  def stop
    command = "docker stop #{docker_name}"
    do_operation 'stop', command
  end

  def rm
    commands = ["docker rm #{docker_name}", "docker rmi #{docker_name}"]
    do_operation 'rm', commands
  end

  private

  def self.from_data(user, name, branch)
    repo = Repo.where(name: name, user: user).first
    unless repo
      raise ActiveRecord::RecordNotFound
    end
    repo.feature_branches.where(name: branch).first_or_create
  end


  def do_operation(stage, commands)
    unless operation_pending?
      self.docker_operation = DockerOperation.new stage: stage
      save
      docker_operation.run commands
    end
  end

  def docker_name
    full_name.gsub '/', '_'
  end

  def docker_image
    docker('images').find { |x| x[0] == docker_name }
  end

  def docker_container
    docker('ps').find { |x| x[6] == docker_name }
  end

  def docker(command)
    `docker #{command}`.split("\n").map { |row| row.split("  ").select(&:present?).map(&:strip) }
  end

  def operation_pending?
    docker_operation && docker_operation.pending?
  end

  def set_gh_info
    branch = client.branch repo.full_name, name
    self.sha = branch.commit.sha
  end

  def client
    @client ||= Octokit::Client.new(:access_token => Rails.application.secrets.gh_token)
  end
end
