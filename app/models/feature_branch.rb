class FeatureBranch < ActiveRecord::Base
  validates :port, uniqueness: true
  belongs_to :repo
  belongs_to :docker_operation
  before_create :set_gh_info

  def self.from_request(request)
    branch, name, user, *host = request.host.split('.')
    repo = Repo.where(name: name, user: user).first
    repo.feature_branches.where(name: branch).first_or_create
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
    unless operation_pending?
      self.docker_operation = DockerOperation.new stage: 'build'
      save
      commands = ["git clone -b #{name} git@github.com:#{repo.full_name}.git repo",
                  "cd repo && docker build -t #{docker_name} -f #{repo.dockerfile} ."]
      docker_operation.run commands
    end
  end

  def launch
    unless operation_pending?
      self.docker_operation = DockerOperation.new stage: 'launch'
      save
      commands = ["docker run -d -P --name #{docker_name} #{docker_name}"]
      docker_operation.run commands
    end
  end

  private

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
