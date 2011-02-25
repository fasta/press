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

  OLD_IFS=$IFS
  IFS="
"
  for LINE in $(cat $TEMPLATE)
  do
    eval "echo \"${LINE}\""
  done
  IFS=$OLD_IFS
}


for ARTICLE in $($REPO/articles.sh)
do
  function article_name()
  {
    echo $ARTICLE
  }
  function article_body()
  {
    $REPO/article.sh $ARTICLE
  }

  template "article" > $DEST/$ARTICLE.html
done


function articles_list()
{
  for ARTICLE in $($REPO/articles.sh)
  do
    function article_name()
    {
      echo $ARTICLE
    }

    template "articles_item"
  done
}
template "articles" > $DEST/index.html

