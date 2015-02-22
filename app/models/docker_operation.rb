class DockerOperation < ActiveRecord::Base
  has_one :feature_branch
  before_create :set_output

  def run(commands)
    self.pending = true
    save
    Thread.new do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          Array.wrap(commands).each do |command|
            IO.popen(command, err: [:child, :out]) do |io|
              while (line = io.gets) do
                 self.output << "#{line.strip}\n"
                 save
              end
            end
          end
        end
      end
      self.succeeded = $?.exitstatus == 0
      self.pending = false
      save
    end
  end

  private

  def set_output
    self.output = ''
  end

end
