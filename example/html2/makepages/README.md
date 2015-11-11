makepages
=========

`makepages` is a small script for splitting a single large HTML file
into separate pages with a Continue button to progress through pages
and a menu, all formatted using Bootstrap. The idea is to make things
a little easier than creating pages from scratch.

The single page is designed to be normal viewable HTML. 

The additional markup is inserted using 'metatags' that are contained
in HTML comments. The metatags are contained in [] rather than <>:

    <!-- [tagname attribute='value'] -->
    ...Content...
    <!-- [/tagname] -->


Creating pages
--------------

Each page is separated with

    <!-- [page menu='xxx'] -->
    <!-- [/page] -->

These comments are wrapped around each page - the 'xxx' is the menu
item to access this page.

The title (index) page
----------------------

The title (index) page is expected to have a big heading. This should
contain a short <h1> heading (which will also be used as a 'home' menu
item on each page), and maybe an <h2> heading and some <p> text.

    <!-- [bigheading] -->
    <!-- [/bigheading] -->

Information and callouts
------------------------

A callout box

    <!-- [callout] -->
    <!-- [/callout] -->

A warning box

    <!-- [warning] -->
    <!-- [/warning] -->

An important box

    <!-- [important] -->
    <!-- [/important] -->

A note box

    <!-- [note] -->
    <!-- [/note] -->

An information box

    <!-- [information] -->
    <!-- [/information] -->

An instruction that the reader might be expected to follow

    <!-- [instruction] -->
    <!-- [/instruction] -->

Popups
------

You can create a popup link within the text with

    <!-- [popup text='xxx'] -->
    <!-- [/popup] -->

Or, if it's specifically a help popup where you want a question mark glyph, then:

    <!-- [help text='xxx'] -->
    <!-- [/help] -->

Accordions and box-outs
-----------------------

You can create an accordion as follows - `ai` is analagous to `<li>`

    <!-- [accordion] -->
    <!-- [ai title='xxx'] -->
    <!-- [/ai] -->
    <!-- [/accordion] -->

A box has similar styling to an accordion but doesn't shrink and expand

    <!-- [box title='xxx'] -->
    <!-- [/box] -->

Confirmation box
----------------

This is designed to provide a box where a user of the page can enter a
name and email and confirm something - e.g. that they have done an
exercise to the best of their ability or that they have read terms and
conditions.

    <!-- [confirm script='xxx'] -->
    I confirm that I have done the tutorial to the best of my ability
    <!-- [/confirm] -->

A `participants` directory will be created containing a file for each
user. This file contains the name and email information and the time
at which the clicked the confirm box.

Additional style information
----------------------------

The contents of the first `<style>` tag in the HTML `<head>` section
will be copied onto each page.

Favicon
-------

You can place a file 'favicon.png' in the directory if you wish to set
the favourites icon on each page.

