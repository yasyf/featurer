class FeatureBranch < ActiveRecord::Base
  belongs_to :repo
  belongs_to :docker_operation
  before_create :set_gh_info

  def self.from_request(request)
    branch, name, user, *host = request.host.split('.')
    self.from_branch branch, name, user
  end

  def self.from_params(params)
    self.from_branch params[:user], params[:name], params[:branch]
  end

  def self.from_pr(repo_name, pr)
    user, name = repo_name
    pull = client.pull_request repo_name, pr
    self.from_branch user, name, pull.head.ref, pr
  end

  def self.from_ref(repo_name, ref)
    user, name = repo_name
    self.from_branch user, name, ref
  end

  def matches_pr?
    pull = client.pull_request repo.full_name, pr
    pull.head.sha == sha
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
    do_operation 'build', build_commands
  end

  def launch
    do_operation 'launch', launch_commands
  end

  def build_and_launch
    do_operation 'launch', build_commands + launch_commands
  end

  def build_and_relaunch
    do_operation 'launch', build_commands + stop_commands + launch_commands
  end

  def stop
    do_operation 'stop', stop_commands
  end

  def rm
    do_operation 'rm', rm_commands
  end

  def stop_and_rm
    do_operation 'rm', stop_commands + rm_commands
  end

  private

  def docker_version
    `docker -v`[/\d\.\d\.\d/].to_f
  end

  def build_commands
    url = "https://#{Rails.application.secrets.gh_token}@github.com/#{repo.full_name}.git"
    commands = ["git clone -b #{name} #{url} repo"]
    if docker_version >= 1.5
      commands << "cd repo && sudo docker build -t #{docker_name} -f #{repo.dockerfile} ."
    else
      commands << "mv repo/#{repo.dockerfile} repo/Dockerfile"
      commands << "cd repo && sudo docker build -t #{docker_name} ."
    end
  end

  def launch_commands
    secrets = repo.secrets.map { |k,v| "-e #{k}=#{v}" }.join ' '
    ["sudo docker run -d -P --name #{docker_name} #{secrets} #{docker_name}"]
  end

  def stop_commands
    ["sudo docker stop #{docker_name}", "sudo docker rm #{docker_name}"]
  end

  def rm_commands
    ["sudo docker rmi #{docker_name}"]
  end

  def self.from_branch(user, name, branch, pr = nil)
    repo = Repo.where(name: name, user: user).first
    unless repo
      raise ActiveRecord::RecordNotFound
    end
    feature_branch = repo.feature_branches.where(name: branch).first_or_create
    if pr
      feature_branch.pr = pr
      feature_branch.save
    end
    feature_branch
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
    `sudo docker #{command}`.split("\n").map { |row| row.split("  ").select(&:present?).map(&:strip) }
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
