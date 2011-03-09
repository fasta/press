#!/bin/bash

cd $(dirname $0)
BASEDIR=$(pwd)
cd - > /dev/null

REPO=$BASEDIR/example
DEST=$BASEDIR/tmp
mkdir -p $DEST


# Globals
#
#REPO=""
#DEST=""
INDEX="1"
FEED="1"


# Functions
#
function template()
{
  TEMPLATE=$REPO/$1
  [ ! -e "$TEMPLATE" ] && TEMPLATE=$BASEDIR/default/$1

  OLD_IFS=$IFS
  IFS="
"
  for LINE in $(cat $TEMPLATE)
  do
    eval "echo \"${LINE}\""
  done
  IFS=$OLD_IFS
}

function content()
{
  FILE=$1
  shift

  if [ -x "$FILE" ]; then
    $FILE $@
  else
    cat $FILE
  fi
}


# Content
#
function entries()
{
  content $REPO/entries
}

function def_feed()
{
  function feed_title()
  {
    content $REPO/title
  }
  function feed_updated()
  {
    ENTRY=$(entries | tail -1)
    content $REPO/entry/updated $ENTRY
  }
  function feed_url()
  {
    content $REPO/url
  }
  function feed_id()
  {
    HOST=$(feed_url | cut -d/ -f3)
    ENTRY=$(entries | head -1)
    DATE=$(content $REPO/entry/updated | cut -dT -f1)

    echo "tag:$HOST,$DATE:/"
  }
}

function def_entry()
{
  function entry_name()
  {
    echo $ENTRY
  }
  function entry_author()
  {
    content $REPO/entry/author $ENTRY
  }
  function entry_updated()
  {
    content $REPO/entry/updated $ENTRY
  }
  function entry_content()
  {
    content $REPO/entry/content $ENTRY
  }
  function entry_id()
  {
    HOST=$(content $REPO/url | cut -d/ -f3)
    DATE=$(entry_updated | cut -dT -f1)

    echo "tag:$HOST,$DATE:/$ENTRY"
  }

  PLUGIN=$REPO/entry/plugin
  if [ -e "$PLUGIN" ]; then
    . $PLUGIN
  fi
}

function entries_templated()
{
  TEMPL=$1

  for ENTRY in $(entries)
  do
    def_entry

    template $TEMPL
  done
}


# Parse Args
#
while [ "$#" -gt "0" ]
do
  case $1 in
    "-r" | "--repo")
      REPO=$2
      shift
      ;;
    "-d" | "--dest")
      DEST=$2
      shift
      ;;
    "--no-index")
      INDEX=""
      ;;
    "--no-feed")
      FEED=""
      ;;
  esac
  shift
done

[ ! -d "$REPO" ] && echo "error: repository needs to be a directory" && exit 1
[ ! -d "$DEST" ] && echo "error: destination needs to be a directory" && exit 1


# Main
#

# generate article pages
for ENTRY in $(content $REPO/entries)
do
  def_entry

  template "entry.html" > $DEST/$ENTRY.html
done

# generate index page
if [ ! -z "$INDEX" ]; then
  def_feed

  function index_entries()
  {
    entries_templated "index_entry.html"
  }
  template "index.html" > $DEST/index.html
fi

# generate atom feed
if [ ! -z "$FEED" ]; then
  def_feed

  function feed_entries()
  {
    entries_templated "feed_entry.xml"
  }
  template "feed.xml" > $DEST/feed.xml
fi

