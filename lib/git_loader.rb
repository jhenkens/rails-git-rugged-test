class GitLoader
  require 'rugged'
  require 'fileutils'
  require 'open3'

  def self.load
    clear
    @_repo = Rugged::Repository.clone_at LaPlaya.git_remote_path, LaPlaya.git_local_path
  end

  def self.clear
    FileUtils.rm_rf(LaPlaya.git_local_path)
  end

  def self.get_hash_for_file(file)
    result = if LaPlaya.git_use_rugged_for_log_hash
               rugged_hash_helper(file)
             else
               shell_hash_helper(file)
             end
    unless result =~ /[0-9a-f]{40}/
      return nil
    end
    result
  end

  def self.repo
    @_repo ||= Rugged::Repository.new(LaPlaya.git_local_path)
  end

  private
  def self.creds
    @_creds ||= Rugged::Credentials::SshKey.new(
        username: LaPlaya.ssh_username,
        publickey: LaPlaya.ssh_public_key,
        privatekey: LaPlaya.ssh_private_key
    )
    @_creds
  end

  def self.shell_hash_helper(file)
    args = ['git', 'log', '--pretty=format:%H', file]
    o, s = Open3.capture2(*args, chdir: LaPlaya.git_local_path)
    o
  end

  def self.rugged_hash_helper(file)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE)
    walker.push(repo.last_commit)
    walker.inject([]) do |a, c|
      if c.diff(paths: [file]).size > 0
        return c.oid
      end
    end
    return nil
  end
end