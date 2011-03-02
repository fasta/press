#!/bin/bash

cd $(dirname $0)
BASEDIR=$(pwd)
cd - > /dev/null


REPO=$BASEDIR/example
DEST=$BASEDIR/tmp
mkdir -p $DEST


function template()
{
  TEMPLATE=$BASEDIR/default/$1.html
  [ ! -e "$TEMPLATE" ] && TEMPLATE=$BASEDIR/default/$1.xml

  OLD_IFS=$IFS
  IFS="
"
  for LINE in $(cat $TEMPLATE)
  do
    eval "echo \"${LINE}\""
  done
  IFS=$OLD_IFS
}

function define_article()
{
  function article_name()
  {
    echo $ARTICLE
  }
  function article_author()
  {
    $REPO/article/author.sh $ARTICLE
  }
  function article_date()
  {
    $REPO/article/date.sh $ARTICLE
  }
  function article_body()
  {
    $REPO/article/body.sh $ARTICLE
  }
}



for ARTICLE in $($REPO/articles.sh)
do
  define_article

  template "article" > $DEST/$ARTICLE.html
done


function articles_list()
{
  for ARTICLE in $($REPO/articles.sh)
  do
    define_article

    template "articles_item"
  done
}
template "articles" > $DEST/index.html

function feed_title()
{
  echo "Example Feed"
}
function feed_entries()
{
  for ARTICLE in $($REPO/articles.sh)
  do
    define_article

    template "feed_entry"
  done
}
template "feed" > $DEST/feed.xml
