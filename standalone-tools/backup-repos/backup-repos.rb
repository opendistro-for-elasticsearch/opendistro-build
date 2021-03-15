# This script will read a manifest from the "backup-repos.yml" file and back up GitHub repositories into S3
# The manifest specifies the organizations and repositories to grab, and a destination bucket.
# This is a quick-and-dirty tool with no fault tolarance. You must run it as a user with SSH access to github, and IAM permissions to write to the destination bucket. It uses the standard AWS CLI environment variables and defaults to talk to S3 (see https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html). Recommended usage is to use a profile name, for example "AWS_PROFILE=production ruby backup-repos.rb", but you can use the AWS_ACCESS_KEY_ID and AWS_SECRET_KEY variables if you really want to.

require 'yaml'
require 'aws-sdk-s3'
require 'tmpdir'

# TODO: Make this a command line argument
manifest_filename = 'backup-repos.yml'

@manifest = YAML.safe_load(File.read(manifest_filename), :symbolize_names => true)
@s3 = Aws::S3::Client.new({
                            region: 'us-east-1'
                          })
@timestamp = Time.now.utc.strftime('%Y-%m-%d.%H%M%S')

def backup(organization, repository, bucket)
  puts "Backing up #{organization}/#{repository} into #{bucket}"
  Dir.mktmpdir do |dir|
    work_dir = File.absolute_path(dir)
    url = "git@github.com:#{organization}/#{repository}.git"
    git_dir = File.join(work_dir, repository)
    archive_file = File.join(work_dir, "#{repository}.tgz")
    key = "#{@timestamp}/#{organization}/#{repository}.tgz"
    puts "Cloning"
    `git clone #{url} #{git_dir}`
    puts "Generating tarball"
    `tar -czf #{archive_file} -C #{git_dir} .`
    puts "Writing to S3: #{bucket}/#{key}"
    begin
      File.open(archive_file, 'rb') do |file|
        pp @s3.put_object({
                            body: file,
                            bucket: @manifest[:destination],
                            key: key
                          })
      end
      puts "Finished"
    rescue => e
      pp e
      raise e
    end
  end
end

bucket = @manifest[:destination]
@manifest[:repositories].each do |organization, repositories|
  puts "#{organization} has #{repositories.length} repositories"
  repositories.each do |repository|
    backup(organization, repository, bucket)
  end
end
