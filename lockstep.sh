#!/usr/bin/env bash

# Initialize a repo if necessary & check that no files are already in existance
if git status > /dev/null 2>&1
then
  if git status | grep -o "nothing to commit" > /dev/null
  then
    starting_branch=`git branch | grep -Po "(?<=\*\s).+"`
    screencast_branch="screencast_`date +"%Y-%m-%dT%H-%M-%S"`"
    git checkout -b $screencast_branch
  else
    echo "Please, commit your changes or stash them before running lockstep"
    exit
  fi
else
  echo "You are not in a git repository."
  echo "Would you like to create one here? (Y/n)"
  read should_create_repo
  if [ "$should_create_repo" != "y" ] && [ "$should_create_repo" != "Y" ]
  then
    git init
    git add .
    git commit -m "Lockstep commit at `date +"%Y-%m-%d %H:%M:%S"`" > /dev/null
    
    starting_branch=""
    screencast_branch="master"
  else
    exit
  fi
fi

echo "Let's do this!"

# I would like to log this contents, but don't know how to reprompt the user to
# stop recording after each iteration. As such, I send all output to /dev/null
# for now.
gitwatch -m "Lockstep commit at %d" . > /dev/null &

while [ "$should_stop" != "y" ] && [ "$should_stop" != "Y" ]
do
  echo "Stop recording? (y/N)"
  read should_stop
  # kill gitwatch
  kill %1
done

