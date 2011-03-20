# Press

Simple static HTML generator with (almost) full control over the source
structure.


## About

A simple bash script for generating static HTML pages including an index and an
Atom feed. Inspired by [NanoBlogger](http://nanoblogger.sourceforge.net/) and
[Jekyll](http://jekyllrb.com/) but with less features and more control over the
source of the site's content. This is achieved by providing the content through
other small scripts.

The central script is the **entries** script which should provide an ID for all
entries of the site. Each of these IDs is then used to generate a single HTML
page. The content for such a page is then retrieved by calling the
**entry/...** scripts with the ID as argument. For even more flexibility a
**entry/plugin** file can be created which will be sourced before the entry
template is rendered. There you can define or overwrite other custom functions
and variables.

Custom HTML templates can be used by simply creating and editing a file with the
same name.


## Installation

Simply clone the git repository in a convenient directory on your system:

    $ cd ~/Applications
    $ git clone git://github.com/fasta/press.git

If you want add an alias to your bash profile for easier access to the script:

    $ echo "alias 'press'='~/Applications/press/press.sh'" >> ~/.profile


## Usage

### Setup

First you have to create the directory where your site's defining scripts will
be stored:

    $ cd ~/Documents
    $ mkdir Press

Change into this directory to setup the site. First you need to configure the
site's title and URL as these are both needed to generate a valid Atom feed.

    $ cd Press
    $ echo "Example Press Site" > title
    $ echo "http://example.com/" > url

As next step, create a list of the site's **entries**. The list can either be a
script or a plain text file.

    $ cat <<EoT > entries
    first_entry_id
    second_entry_id
    third_entry_id
    EoT

Now you can define the content for each entry. Again this can be done through a
script or plain text files. If for example all entries are written by the same
author just write his name in a plain text file.

    $ mkdir entry
    $ echo "John Doe" > entry/author

To get the content of an entry write a script that uses the ID argument to print
HTML formatted text in the terminal.

    $ cat <<EoT > entry/content
    #!/bin/bash
    ENTRY_ID=$1
    markdown ~/Documents/$ENTRY_ID.mdwn
    EoT
    $ chmod 755 entry/content

All that's left for a valid Atom feed now is the modification date for entries.
As this is individual for each entry using a script is recommended. It is
important that dates are presented in ISO-8601 date/time format, otherwise your
Atom feed will not be valid (and probably also not usable). This means a date or
a time should look like this:

    2011-03-20T14:35:26Z

### Run

Finally you can generate the pages by running the script:

    $ press --repo ~/Documents/Press --dest ~/Sites

If you want only to generate the entry pages run the script with the following
options:

    $ press --repo $REPO --dest $DEST --no-index --no-feed

### Customize

Shoud you find the default templates not to your liking (as will most likely be
the case), you can create your own templates. If they are located in your site's
definition directory they will be used automatically. There are five templates:

  * index.html
  * index_entry.html
  * feed.xml
  * feed_entry.xml
  * entry.html

Both the index and feed templates use another template to represent single
entries. To display all formatted entries in the index and feed templates use
the appropriate function:

    $(index_entries)
    $(feed_entries)

All content from the scripts and/or plain text files can also be inserted by
bash function calls.

    $(feed_title)
    $(feed_url)
    $(entry_author)
    $(entry_content)
    $(entry_updated)

