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

# If $starting_branch is an empty string, there were no commits in the repo
# when be began (and thus no branches). In that case, *all* commits belong in
# screencast. We don't use the initial `git status` check, as the user could
# have manually created a repo, but never committed anything.
if [ "$starting_branch" == "" ]
then
  commits=`git log --oneline --reverse`
else
  commits=`git log -v "$starting_branch..$screencast_branch" --oneline --reverse`
fi

read -e -p "Enter the path to the recorded screencast: " screencast_path
exif=$(exiftool "$screencast_path")

read_exif_value () {
  grep -P "$1" <<< "$exif" | grep -Po "(?<=: ).*"
}

video_start_malformed=$(read_exif_value "Create Date")
video_start_date=$(echo $video_start_malformed | cut -d' ' -f1 | sed 's/:/-/g')
video_start_time=$(echo $video_start_malformed | cut -d' ' -f2)
video_start_epoch=$(date -ud "$video_start_date $video_start_time" +"%s")

# SimpleScreenRecorder and Kazam write "12.345 s" if less than a minute,
# but "0:12:34" if longer.
video_duration=$(read_exif_value "^Duration")

# TODO: the [[]] notation isn't POSIX compliant and should be replaced for
# maximum cross compatability. It works in bash, ksh, and zsh IIRC.
if [[ $video_duration =~ ":" ]]
then
  video_duration_seconds=$(date -ud "1970-01-01 $video_duration" +%s)
else
  video_duration_seconds=$(echo $video_duration | grep -Po "^\d+")
fi

# echo "video_start_time: $video_start_time"
echo "video_duration_seconds: $video_duration_seconds"
echo "video_start_epoch: $video_start_epoch"
