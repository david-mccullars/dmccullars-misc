date > src/VERSION
rev=`git rev-parse HEAD`
if [ "0" -ne `git status --porcelain | wc -l` ]; then
  rev="$rev-DIRTY"
fi
echo $rev >> src/VERSION

./makeself-2.1.5/makeself.sh --follow src git-over-svn.sh "Git-over-svn one-time setup" ruby one-time-setup.rb

# Bypass the makeself stuff
cat git-over-svn.sh \
| sed "s/\$print_cmd \$print_cmd_arg/ignore=1 # \0/g" \
| sed "s/echo . All good/ignore=1 # \0/g" \
| sed "s/while true/while false # \0/g" \
| sed "s/^echo$/ignore=1 # \0/g" \
> git-over-svn.sh.new
mv git-over-svn.sh.new git-over-svn.sh
chmod a+x git-over-svn.sh
