#!/bin/bash
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
cd /Users/tatsuya/src/github.com/ttakamura/TkTaskServer
source /Users/tatsuya/src/github.com/ttakamura/TkTaskServer/.env && bundle exec ruby import_today.rb -f /tmp/my_org_mobile_push.org -r true
