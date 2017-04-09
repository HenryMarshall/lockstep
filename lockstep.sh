#!/usr/bin/env bash

if git status > /dev/null
then
  if ! git status | grep -o "nothing to commit" > /dev/null
  then
    echo "Please, commit your changes or stash them before running lockstep"
    exit
  fi
else
  echo "Initializing a git repository"
  git init
fi

echo "Let's do this!"

