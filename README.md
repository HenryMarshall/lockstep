# Lockstep

## Description

Video tutorials are one of the best ways to learn how to code, but it can be an
exercise in frustration following along at home. Sometimes the line you need to
type will be just off the screen, and other times entire files will never be
shown. Lockstep links every save in your video to a git commit. This lets
viewers checkout the code, experiment, stash their changes and resuming progress
in the video all with familiar git commands!


## Usage

- Navigate to where you want to record a screencast.
- Run `lockstep`, it will set up a git repo or create a new branch as needed.
- Start a screen capture software of your choice (see below for notes on
  compatibility).
- Follow the prompts. Lockstep will never delete any files, commits, branches or
  repos so no need to worry!


## Installation

Lockstep depends on [gitwatch](github.com/nevik/gitwatch), `git`,
`inotifywait`, and `ffmpeg` to run. Actually recording your screencast is
**not** handled by lockstep.

Then simply place lockstep.sh in your path.


## Screen casting software

You are welcome to use any screencapture software so long as it populates the
"Create Date" exif field  with the **start time** of the recording. You can
easily check this by recording a clock (with a second hand) with the screen
capture software and seeing if that matches `exiftool screencast.mp4 | grep -P
"^Create Date"`. You could also theoretically use this technique to manually set
the "Create Date" field if you are wedded to a particular workflow.

If you try a different piece of screen capture software, please add it to the
appropriate list and file a PR. I want lockstep.sh to be as cross-platform as
possible.

### Works
- [Kazam](https://launchpad.net/kazam) (Linux)

### Doesn't Work
- [SimpleScreenRecorder](http://www.maartenbaert.be/simplescreenrecorder/)
  (Linux)

