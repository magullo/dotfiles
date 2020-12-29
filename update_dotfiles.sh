#!/bin/sh

set -x

for dotfile in .*; do
  rsync -av --exclude=.git ~/$dotfile .
done
