#! /bin/bash

echo "I'm assuming you have not created an Heroku instance or anything."
read -p "Are you _sure_ about this?"
echo "Ok, here goes."

heroku create --stack cedar
heroku config:add HUBOT_HISTORY_LINES=10000
heroku config:add HUBOT_IRC_SERVER="irc.freenode.net"
heroku config:add HUBOT_IRC_ROOMS="#jekyll"
heroku config:add HUBOT_IRC_NICK="stenographer"
#heroku config:add HUBOT_IRC_UNFLOOD="false"
git push heroku master
heroku ps:scale web=1
