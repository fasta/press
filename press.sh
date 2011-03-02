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
  TEMPLATE=$BASEDIR/default/$1

  OLD_IFS=$IFS
  IFS="
"
  for LINE in $(cat $TEMPLATE)
  do
    eval "echo \"${LINE}\""
  done
  IFS=$OLD_IFS
}


# Content
#
function articles()
{
  $REPO/articles
}

function def_article()
{
  function article_name()
  {
    echo $ARTICLE
  }
  function article_author()
  {
    $REPO/article/author $ARTICLE
  }
  function article_date()
  {
    $REPO/article/date $ARTICLE
  }
  function article_body()
  {
    $REPO/article/body $ARTICLE
  }
}

function articles_templated()
{
  TEMPL=$1

  for ARTICLE in $(articles)
  do
    def_article

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
for ARTICLE in $($REPO/articles)
do
  def_article

  template "article.html" > $DEST/$ARTICLE.html
done

# generate index page
if [ ! -z "$INDEX" ]; then
  function index_entries()
  {
    articles_templated "index_entry.html"
  }
  template "index.html" > $DEST/index.html
fi

# generate atom feed
if [ ! -z "$FEED" ]; then
  function feed_entries()
  {
    articles_templated "feed_entry.xml"
  }
  template "feed.xml" > $DEST/feed.xml
fi

