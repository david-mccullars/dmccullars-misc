require 'rubygems'
require 'fileutils'
require 'highline'
require 'highline/import'

def ask_full_name
  HighLine.ask 'What is your full name' do |q|
    q.validate = /\A\S+\s+\S+/
  end
end

def ask_email
  HighLine.ask 'What is your email address' do |q|
    q.validate = /\A\S+@\S+\.\S+\z/
  end
end

HOME = File.expand_path('~')

FileUtils.cp_r 'auto', HOME, :remove_destination => true
FileUtils.cp_r 'auto_integrate', HOME, :remove_destination => true
FileUtils.cp_r 'auto_review', HOME, :remove_destination => true
FileUtils.cp_r '.bashgit', HOME, :remove_destination => true, :remove_destination => true
FileUtils.cp_r '.git-completion.bash', HOME, :remove_destination => true, :remove_destination => true

gitconfig = File.expand_path '~/.gitconfig'
unless File.exist?(gitconfig) && !HighLine.agree('Is it okay to overwrite your .gitconfig?')
  old_file = File.read(gitconfig) rescue ''
  user_section = old_file[/(^\[user\].*?(?=^\[|\z))/m] ||
                 "[user]\n\tname = #{ask_full_name}\n\temail = #{ask_email}"

  File.open(gitconfig, 'w') do |io|
    io.puts user_section
    io.puts File.read('.gitconfig')
  end
end

bashprofile = File.expand_path '~/.bash_profile'
unless File.exist?(bashprofile) && !HighLine.agree('Is it okay to modify your bash profile?')
  profile = File.read(bashprofile) rescue ''
  profile.sub! %r{\s*source ~/\.git-completion\.bash\s*}m, ''
  profile.sub! %r{\s*source ~/\.bashgit\s*}m, ''
  File.open(bashprofile, 'w') do |io|
    io.puts profile
    io.puts
    io.puts "source ~/.git-completion.bash"
    io.puts "source ~/.bashgit"
  end
end

dest_dir = nil
while dest_dir.nil? || !File.directory?(dest_dir)
  dest_dir = HighLine.ask 'Where should I put nimbus-trunk?' do |q|
    q.default = '~/work'
  end
  dest_dir = File.expand_path(dest_dir)
  dest_dir = nil if dest_dir =~ %r{^/tmp/selfgz\d+$}
end

exec <<-END
cd #{dest_dir} &&
svn checkout http://crds/svn/storage/nimbus/trunk nimbus-trunk &&
cd nimbus-trunk &&
git clone gitolite@crds:nimbus-trunk.git &&
mv nimbus-trunk/.git . &&
rm -fr nimbus-trunk &&
git config core.filemode false &&
(git update-index --refresh || echo) &&
sleep 2 &&
git reset --hard &&
svn status &&
git status
END
