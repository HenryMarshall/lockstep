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

echo "Enter the path to the recorded screencast:"
read screencast_path

read -e -p "Enter the path to the recorded screencast: " screencast_path


# If $starting_branch is an empty string, there were no commits in the repo
# when be began (and thus no branches). In that case, *all* commits belong in
# screencast. We don't use the initial `git status` check, as the user could
# have manually created a repo, but never committed anything.
if [ "$starting_branch" == "" ]
then
  commits=`git log --oneline> $1`
else
  commits=`git log -v "$starting_branch..$screencast_branch" --oneline > $1`
fi

video_start_malformed=`exiftool "$screencast_path" | grep -Po "(?<=File Access Date/Time {11}: ).+"`
video_start_time="`echo $video_start_malformed | cut -d' ' -f1 | sed 's/:/-/g'` `echo $video_start_malformed | cut -d' ' -f2`"
video_start_epoch=date -d "$formatted_date" +%s

video_duration=`exiftool "$screencast_path" | grep -Po "(?<=File Access Date/Time {24}: ).+"`

