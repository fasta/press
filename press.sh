#!/bin/bash

cd $(dirname $0)
BASEDIR=$(pwd)
cd - > /dev/null


REPO=$BASEDIR/example
DEST=$BASEDIR/tmp
mkdir -p $DEST


function template()
{
  OLD_IFS=$IFS
  IFS="
"
  for LINE in $(cat $BASEDIR/default/article.html)
  do
    eval "echo \"${LINE}\""
  done
  IFS=$OLD_IFS
}


for ARTICLE in $($REPO/articles.sh)
do
  function article_body()
  {
    $REPO/article.sh $ARTICLE
  }

  template > $DEST/$ARTICLE.html
done

