#!/usr/bin/env bash

# `sed` command reverses order
commits=`git log --oneline | sed '1!G;h;$!d'`
video_start_time=`date -d "2017-04-09T18:48:45-0400" +%s` 
video_length=120

idx=0
IFS=$'\n'
for commit in $commits
do
  shas[idx]=`echo $commit | cut -d' ' -f1`

  commit_time=`date -d \`echo $commit | cut -d' ' -f5-6\` +%s`

  # gitwatch waits 2 seconds before committing -- this compensates
  seconds_into_video=`expr $commit_time - $video_start_time - 2`

  # We abuse `date` to show time, by displaying the time since the epoch
  timestamps[idx]=`date -ud "@$seconds_into_video" +"%H:%M:%S,000"`

  (( idx++ ))
done

timestamps+=(`date -ud "@$video_length" +"%H:%M:%S,000"`)

idx=0
for sha in ${shas[@]}
do
  echo $idx
  echo "${timestamps[$idx]} --> ${timestamps[`expr $idx + 1`]}"
  echo $sha
  echo
  (( idx++ ))
done

