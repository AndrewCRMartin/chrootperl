#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    makepages
#   File:       makepages.pl
#   
#   Version:    V1.0
#   Date:       11.11.15
#   Function:   Create a (set of) HTML page(s) using attractive 
#               Bootstrap layout from very simple HTML meta-markup
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2015
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0    11.11.15 Original By: ACRM
#
#*************************************************************************
# Add the path of the executable to the library path
use FindBin;
use lib $FindBin::Bin;
# Or if we have a bin directory and a lib directory
#use Cwd qw(abs_path);
#use FindBin;
#use lib abs_path("$FindBin::Bin/../lib");

#*************************************************************************
use strict;
$::accordionCount = 0;
$::collapseCount  = 0;

UsageDie()   if(defined($::h));
CleanupDie() if(defined($::clean));

if(scalar(@ARGV))
{
    WriteCSSandJS();            # Write CSS and JavaScript files

    my @data = <>;              # Read the input HTML file

    # The title from the <title> tag
    my $title = GetTitle(@data);
    print "Title: $title\n" if(defined($::debug));

    # Any style information
    my $style = GetStyle(@data);
    print "Style: $style\n" if(defined($::debug));

    # Menu items from [page menu='xxx'] tags
    my $aMenu  = GetMenuItems(@data);
    if(defined($::debug))
    {
        print "Menu: |";
        foreach my $menu (@$aMenu)
        {
            print " $menu |";
        }
        print "\n";
    }
    
    # Taken from the [bigheading] <h1>
    my $homeMenu = GetHomeMenu(@data);
    print "Home menu item: $homeMenu\n" if(defined($::debug));
    
    # Split up the pages and create each one
    my $aPages = GetPages(@data);
    my $pageNum = 0;
    foreach my $aPage (@$aPages)
    {
        my $lastPage = 0;
        $lastPage = 1 if($pageNum == (scalar(@$aPages) - 1));
        WritePage($pageNum, $title, $style, $homeMenu, $aMenu, $aPage, $lastPage);
        $pageNum++;
    }
}
else
{
    UsageDie();
}


#*************************************************************************
#> void WriteCSSandJS(void)
#  ------------------------
#  Writes the supporting CSS and JavaScript files:
#     mptheme.css      - static menu theme support
#     mpcss.css        - special extras for makepages
#     mpautotooltip.js - activate tooltips
#
#  11.11.15 Original   By: ACRM
#
sub WriteCSSandJS
{
    # -------------------------- mptheme.css --------------------------- #
    if(open(my $fp, '>', 'mptheme.css'))
    {
        print $fp <<'__EOF';
        body {
            padding-top: 70px;
            padding-bottom: 30px;
        }

        .theme-dropdown .dropdown-menu {
          display: block;
          position: static;
            margin-bottom: 20px;
        }

        .theme-showcase > p > .btn {
          margin: 5px 0;
__EOF
        close $fp;
    }

    # -------------------------- mpcss.css   --------------------------- #
    if(open(my $fp, '>', 'mpcss.css'))
    {
        print $fp <<'__EOF';
        /* Base styles (regardless of theme) */
        .bs-callout {
           margin: 20px 0;
           padding: 15px 30px 15px 15px;
           border-left: 5px solid #eee;
        }
        .bs-callout h4 {
           margin-top: 0;
        }
        .bs-callout p:last-child {
           margin-bottom: 0;
        }
        .bs-callout code, .bs-callout .highlight {
           background-color: #fff;
        }
 
        /* Themes for different contexts */
        .bs-callout-danger {
           background-color: #fcf2f2;
           border-color: #dFb5b4;
        }
        .bs-callout-warning {
           background-color: #fefbed;
           border-color: #f1e7bc;
        }
        .bs-callout-info {
           background-color: #f0f7fd;
           border-color: #d0e3f0;
        }
        .center {
           text-align: center;
        }
        .instruction {
           background-color: #eeeeee;
           margin: 0 0 4pt 0;
           border: 1pt solid red;
           border-left: 6pt solid red;
           padding: 2pt 2pt 2pt 6pt;
           border-radius: 0px;
           border-top-right-radius: 5px;
           -moz-border-radius-topright: 5px;
           -webkit-border-top-right-radius: 5px;
           border-bottom-right-radius: 5px;
           -moz-border-radius-bottomright: 5px;
           -webkit-border-bottom-right-radius: 5px;
        }
        .instruction p {
           margin: 0;
           padding: 0;
        }
__EOF
        close $fp;
    }

    # ------------------------ mpautotooltip.js ------------------------ #
    if(open(my $fp, '>', 'mpautotooltip.js'))
    {
        print $fp <<'__EOF';
        // Auto-activate tooltips and popovers so they work like everything else
        // Taken from:
        // http://stackoverflow.com/questions/9302667/how-to-get-twitter-bootstrap-jquery-elements-tooltip-popover-etc-working/14761703#14761703
        //
        // Use as
        // <a rel="tooltip" title="My tooltip">Link</a>
        // <a data-toggle="popover" data-content="test">Link</a>
        // <button data-toggle="tooltip" data-title="My tooltip">Button</button>
        $(function () {
            $('body').popover({
              selector: '[data-toggle="popover"]'
                              });
            $('body').tooltip({
              selector: 'a[rel="tooltip"], [data-toggle="tooltip"]'
                              });
        });
__EOF
        close $fp;
    }

}


#*************************************************************************
#> void UsageDie(void)
#  -------------------
#  Prints a usage message and exits
#
#  11.11.15 Original   By: ACRM
#
sub UsageDie
{
    print <<__EOF;

makepages V1.0 (c) UCL, Dr. Andrew C.R. Martin

Usage: makepages file.html
       -or-
       makepages -clean

__EOF
}


#*************************************************************************
#> my $title = GetTitle(@data)
#  ---------------------------
#  Extracts the title from the <title> tag in the HTML
#
#  11.11.15 Original   By: ACRM
#
sub GetTitle
{
    my(@data) = @_;
    my $title = '';
    my $allData = join(' ', @data);
    $allData =~ s/\r//g;
    $allData =~ s/\n/<ret>/g;

    if($allData=~/<title>(.*?)<\/title>/)
    {
        $title = $1;
    }
    $title =~ s/<ret>/ /g;
    return($title);
}


#*************************************************************************
#> my $style = GetStyle(@data)
#  ---------------------------
#  Extracts any <style> information from the HTML. Only reads the 
#  first style tag - does not pick up external style information
#
#  11.11.15 Original   By: ACRM
#
sub GetStyle
{
    my(@data) = @_;
    my $style = '';
    my $allData = join(' ', @data);

    $allData =~ s/\r//g;
    $allData =~ s/\n/<ret>/g;

    if($allData=~/<style.*?>(.*?)<\/style>/)
    {
        $style = $1;
    }
    $style =~ s/<ret>/\n/g;
    return($style);
}


#*************************************************************************
#> $aMenu  = GetMenuItems(@data)
#  -----------------------------
#  Extracts menu items from [page menu='xxx'] metatags. Returns
#  an array reference
#
#  11.11.15 Original   By: ACRM
#
sub GetMenuItems
{
    my(@data) = @_;
    my @menu = ();
    foreach my $line (@data)
    {
        if($line =~ /<!--\s+\[page\s+menu=['"](.*?)['"]\]\s+--\>/)
        {
            push @menu, $1;
        }
    }
    return(\@menu);
}


#*************************************************************************
#> $aPages = GetPages(@data)
#  -------------------------
#  Splits the HTML into separate pages using the [page] metatags.
#  Returns an array reference
#
#  11.11.15 Original   By: ACRM
#
sub GetPages
{
    my(@data) = @_;
    my @Pages = ();
    my $inPage = 0;
    my $pageNum = 0;

    foreach my $line (@data)
    {
        if($inPage)
        {
            push(@{$Pages[$pageNum]}, $line);
        }

        if($line =~ /\<!--\s+\[page\s.*\]\s+--\>/)
        {
            @{$Pages[$pageNum]} = ();
            push(@{$Pages[$pageNum]}, $line);
            $inPage = 1;
        }
        elsif($line =~ /<!--\s+\[\/page\]\s+--\>/)
        {
            $inPage = 0;
            $pageNum++;
        }
    }    
    return(\@Pages);
}


#*************************************************************************
#> void WritePage($pageNum, $title, $style, $homeMenu, $aMenu, 
#                 $aPage, $lastPage)
#  --------------------------------------------------------------
#  $pageNum  - The page number.  0 gives index.html
#                               >0 gives pageN.html
#  $title    - Contents of <title> tag
#  $style    - Any contents of <style> tag
#  $homeMenu - A title-like home menu item taken from the 
#              [bigheading]<h1>
#  $aMenu    - Reference to array of menu items
#  $aPage    - Reference to array of lines for this page
#  $lastPage - Flag to indicate this is the last page so doesn't
#              need a Continue button
#
#  Writes an HTML page
#
#  11.11.15 Original   By: ACRM
#
sub WritePage
{
    my ($pageNum, $title, $style, $homeMenu, $aMenu, $aPage, $lastPage) = @_;

    my $filename = 'index.html';
    if($pageNum)
    {
        $filename = sprintf("page%02d.html", $pageNum);
    }

    if(open(my $fp, '>', $filename))
    {
        PrintHTMLHeader($fp, $title, $style);
        PrintHTMLMenu($fp, $homeMenu, $aMenu, $pageNum);
        PrintHTMLPage($fp, $aPage);
        PrintHTMLNextButton($fp, $pageNum) if(!$lastPage);
        PrintHTMLFooter($fp);
    }

}


#*************************************************************************
#> $homeMenu = GetHomeMenu(@data)
#  ------------------------------
#  Extracts a home menu title from [bigheading]<h1>
#
#  11.11.15 Original   By: ACRM
#
sub GetHomeMenu
{
    my (@data) = @_;
    my $inBigHeading = 0;
    my $inH1 = 0;
    my $h1 = '';
    foreach my $line (@data)
    {
        if($inBigHeading)
        {
            if($line =~ /<h1>/)
            {
                $inH1 = 1;
                $h1 .= $line;
            }
            if($line =~ /<\/h1>/)
            {
                $inH1 = 0;
            }
        }
        if($line =~ /\[bigheading\]/)
        {
            $inBigHeading = 1;
        }
        if($line =~ /\[\/bigheading\]/)
        {
            $inBigHeading = 0;
            last;
        }
    }
    $h1 =~ s/[\n\r]/ /g;
    $h1 =~ /<h1>(.*?)<\/h1>/;
    return($1);
}


#*************************************************************************
#> $line = Replace($line, $tag, $new, [$idStem, $sCounter])
#  --------------------------------------------------------
#  $line     - A line of HTML
#  $tag      - A metatag name to be replaced
#  $new      - The new HTML to relace the metatag
#  $idStem   - An ID to be inserted into the new HTML
#  $sCounter - Reference to a counter to be appended to the ID
#
#  Takes a metatag name and replaces it with the new text. e.g.
#     $line = Replace($line, 'foo', '<div class="bar">');
#     $line = Replace($line, '/foo', '</div>');
#  would replace
#     <!-- [foo] -->
#     <!-- [/foo] -->
#  with
#     <div class="bar">
#     </div>
#
#  Optionally can also build an id from a stem and counter
#  and inserts it into the replacement string. If using this
#  the replacement string must contain '{}' where the id must
#  go. So you could do something like:
#     $count = 0;
#     $line = Replace($line, 'foo', '<div id="{}">', 'bar', \$count);
#  Each call would then replace
#     <!-- [foo] -->
#  with
#     <div id="bar1">
#     <div id="bar2">
#  etc
#
#  11.11.15 Original   By: ACRM
#
sub Replace
{
    my($line, $tag, $new, $idStem, $sCounter) = @_;

    # Constract the regex: <!-- [$tag] -->
    my $regex = '<!--\s+\[' . $tag . '\]\s+--\>';
    if(scalar(@_) > 3)
    {
        if($line =~ /$regex/)
        {
            $$sCounter++;
            my $id = "$idStem$$sCounter";
            $new   =~ s/\{\}/$id/;
            $line  =~ s/$regex/$new/;
        }
    }
    else
    {
        $line =~ s/$regex/$new/;
    }
    return($line);
}


#*************************************************************************
#> $line = ReplaceParam($line, $tag, $attribute, $replace)
#  -------------------------------------------------------
#  $line      - A line of HTML
#  $tag       - The metatag name
#  $attribute - An attribue name
#  $replace   - Replacement text
#
#  Takes a metatag name with an associated attribute and replaces
#  it with the new text inserting the attribute value. e.g.
#     $line = ReplaceParam($line, 'foo', 'bar' '<div class="{}">');
#  would replace
#     <!-- [foo bar='value'] -->
#  with
#     <div class="value">
#
#  11.11.15 Original   By: ACRM
#
sub ReplaceParam
{
    my($line, $tag, $attribute, $replace) = @_;
    my $regex = '<!--\s+\[' . $tag . '\s+' . $attribute . "=['\"](.*)['\"]" . '\s*\]\s+--\>';
    if($line =~ $regex)
    {
        my $value = $1;
        $replace =~ s/\{\}/$value/;
        $line =~ s/$regex/$replace/;
    }
    return($line);
}


#*************************************************************************
#> void PrintHTMLFooter($fp)
#  -------------------------
#  Prints the footer for an HTML page
#
#  11.11.15 Original   By: ACRM
#
sub PrintHTMLFooter
{
    my($fp) = @_;

    print $fp <<'__EOF';

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" crossorigin="anonymous"></script>
<!--
    <script src="bootstrap/assets/js/jquery.js"></script>
    <script src="bootstrap/dist/js/bootstrap.min.js"></script>
-->
    <script src="mpautotooltip.js"></script>
  </body>
</html>
__EOF
}


#*************************************************************************
#> void PrintHTMLNextButton($fp, $pageNum)
#  ---------------------------------------
#  $fp      - File handle
#  $pageNum - The current page number
#
#  Creates an HTML 'Continue' button providing a link to the next
#  page.
#
#  11.11.15 Original   By: ACRM
#
sub PrintHTMLNextButton
{
    my($fp, $pageNum) = @_;
    my $filename = sprintf("page%02d.html", $pageNum+1);
    print $fp <<__EOF;
<div class='center'>
   <a class="btn btn-lg btn-primary" href="$filename">Continue</a>
</div>
__EOF
}


#*************************************************************************
#> void PrintHTMLMenu($fp, $homeMenu, $aMenu, $pageNum)
#  ----------------------------------------------------
#  $fp       - File handle
#  $homeMenu - The 'home menu' item
#  $aMenu    - Reference to an array of menu items
#  $pageNum  - The current page number (to highlight the current
#              menu item)
#
#  Prints the HTML menu. This is a list formatted with Bootstrap
#
#  11.11.15 Original   By: ACRM
#
sub PrintHTMLMenu
{
    my($fp, $homeMenu, $aMenu, $pageNum) = @_;

    print $fp <<__EOF;
    <!-- Fixed navbar -->
    <div class="navbar navbar-inverse navbar-fixed-top">

      <div class="container">

        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="index.html">$homeMenu</a>
        </div>

        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
__EOF

    for(my $i=0; $i<scalar(@$aMenu); $i++)
    {
        my $filename = 'index.html';
        my $active   = '';
        $active = " class='active'" if($i == $pageNum);
        if($i)
        {
            $filename = sprintf("page%02d.html", $i);
        }
        print $fp "<li$active><a href='$filename'>$$aMenu[$i]</a></li>\n";
    }

    print $fp <<__EOF;
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>
__EOF
}


#*************************************************************************
#> void PrintHTMLHeader($fp, $title, $style)
#  -----------------------------------------
#  $fp      - File handle
#  $title   - The <title> tag content
#  $style   - Optional style information
#
#  Creates an HTML header for a page
#
#  11.11.15 Original   By: ACRM
#
sub PrintHTMLHeader
{
    my($fp, $title, $style) = @_;

    if($style ne '')
    {
        $style = "<style type='text/css'>$style</style>\n";
    }

    print $fp <<__EOF;
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="favicon.png">

    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" crossorigin="anonymous">

    <!-- Bootstrap theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css" crossorigin="anonymous">

<!-- 
    <link href="bootstrap/dist/css/bootstrap.css" rel="stylesheet">
    <link href="bootstrap/dist/css/bootstrap-theme.min.css" rel="stylesheet">
-->

    <!-- Custom styles for this template -->
    <link href="mptheme.css" rel="stylesheet">

    <!-- And my own useful extras -->
    <link href="mpcss.css" rel="stylesheet"> 

    <!-- Any style information from the web page -->
    $style

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <title>$title</title>
  </head>

  <body>
__EOF
}


#*************************************************************************
#> void PrintHTMLPage($fp, $aPage)
#  -------------------------------
#  $fp     - File hanle
#  $aPage  - Reference to array of lines for the page
#
#  The main routine for printing a page of HTML. Calls the various
#  FixUp_*() routines to replace metatags with the relevant HTML.
#  Then prints the lines of HTML to the file
#
#  11.11.15 Original   By: ACRM
#
sub PrintHTMLPage
{
    my($fp, $aPage) = @_;

    print $fp " <div class='container theme-showcase'>\n";

    FixUp_bigheading($aPage);
    FixUp_callout($aPage);
    FixUp_warning($aPage);
    FixUp_important($aPage);
    FixUp_note($aPage);
    FixUp_information($aPage);
    FixUp_popup($aPage);
    FixUp_help($aPage);
    FixUp_instruction($aPage);
    FixUp_accordion($aPage);
    FixUp_ai($aPage);
    FixUp_box($aPage);
    FixUp_confirm($aPage);

    foreach my $line (@$aPage)
    {
        print $fp $line;
    }

    print $fp " </div> <!-- /container -->\n";
}


#*************************************************************************
#> void FixUp_bigheading($aPage)
#  -----------------------------
#  Replaces the [bigheading] metatag with a Bootstrap jumbotron
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_bigheading
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'bigheading','<div class="jumbotron">');
        $line = Replace($line, '/bigheading','</div> <!-- jumbotron -->');
    }
}


#*************************************************************************
#> void FixUp_callout($aPage)
#  --------------------------
#  Replaces the [callout] metatag with a Bootstrap info callout
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_callout
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'callout','<div class="bs-callout bs-callout-info">');
        $line = Replace($line, '/callout','</div> <!-- callout -->');
    }
}


#*************************************************************************
#> void FixUp_warning($aPage)
#  --------------------------
#  Replaces the [warning] metatag with a Bootstrap danger alert
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_warning
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'warning','<div class="alert alert-danger">');
        $line = Replace($line, '/warning','</div> <!-- alert-danger -->');
    }
}


#*************************************************************************
#> void FixUp_important($aPage)
#  ----------------------------
#  Replaces the [important] metatag with a Bootstrap danger callout
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_important
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'important','<div class="bs-callout bs-callout-danger">');
        $line = Replace($line, '/important','</div> <!-- bs-callout-danger -->');
    }
}


#*************************************************************************
#> void FixUp_note($aPage)
#  -----------------------
#  Replaces the [note] metatag with a Bootstrap warning callout
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_note
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'note','<div class="bs-callout bs-callout-warning">');
        $line = Replace($line, '/note','</div> <!-- bs-callout-warning -->');
    }
}


#*************************************************************************
#> void FixUp_information($aPage)
#  ------------------------------
#  Replaces the [information] metatag with  a Bootstrap info alert
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_information
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'information','<div class="alert alert-info">');
        $line = Replace($line, '/information','</div> <!-- alert-info -->');
    }
}


#*************************************************************************
#> void FixUp_instruction($aPage)
#  ------------------------------
#  Replaces the [instruction] metatag with our own instruction class
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_instruction
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'instruction','<div class="instruction">');
        $line = Replace($line, '/instruction','</div> <!-- instruction -->');
    }
}


#*************************************************************************
#> void FixUp_popup($aPage)
#  ------------------------
#  Replaces the [popup] metatag with a Bootstrap popup
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_popup
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = ReplaceParam($line, 'popup', 'text', '<a data-toggle="popover" data-trigger="focus" data-content="{}">');
        $line = Replace($line, '/popup','</a>');
    }

}


#*************************************************************************
#> void FixUp_help($aPage)
#  -----------------------
#  Replaces the [help] metatag with a Bootstrap popup and a question mark
#  glyph
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_help
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = ReplaceParam($line, 'help', 'text', '<a data-toggle="popover" data-trigger="focus" data-content="{}">');
        $line = Replace($line, '/help','<span class="glyphicon glyphicon-question-sign"></span></a>');
    }

}


#*************************************************************************
#> void FixUp_accordion($aPage)
#  ----------------------------
#  Replaces the [accordion] metatag with a Bootstrap accordion panel group
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_accordion
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'accordion', '<div class="panel-group" id="{}">', 'accordion', \$::accordionCount);
        $line = Replace($line, '/accordion','</div> <!-- panel-group -->');
    }

}


#*************************************************************************
#> void FixUp_ai($aPage)
#  ---------------------
#  Replaces the [ai title='xxx'] metatag with an accordion item
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_ai
{
    my($aPage) = @_;

    my $regexStart = '<!--\s+\[ai\s+title=[\'\"](.*)[\'\"]\s*\]\s+--\>';
    my $regexStop  = '<!--\s+\[\/ai\]\s+--\>';
    my $accordion  = "accordion$::accordionCount";

    foreach my $line (@$aPage)
    {
        if($line =~ /$regexStart/)
        {
            my $title = $1;
            $::collapseCount++;
            my $collapse = "collapse$::collapseCount";
            $line = "  <div class='panel panel-default'>
    <div class='panel-heading'>
      <h4 class='panel-title'>
        <a class='accordion-toggle' data-toggle='collapse' data-parent='#$accordion' href='#$collapse'>
           <span class='glyphicon glyphicon-collapse-down'></span> $title
        </a>
      </h4>
    </div>
    <div id='$collapse' class='panel-collapse collapse'>
      <div class='panel-body'>";
        }
        elsif($line =~ /$regexStop/)
        {
            $line = "      </div>\n    </div>\n  </div>\n";
        }
    }
}


#*************************************************************************
#> void FixUp_box($aPage)
#  ----------------------
#  Replaces the [box title='xxx'] metatag with a Bootstrap panel
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_box
{
    my($aPage) = @_;

    my $replace = "<div  class='panel panel-default'>
   <div class='panel-heading'>
      <h4 class='panel-title'>{}</h4>
   </div>
   <div class='panel-body'>";


    foreach my $line (@$aPage)
    {
        $line = ReplaceParam($line, 'box', 'title', $replace);
        $line = Replace($line, '/box',"   </div>\n</div>");
    }
}


#*************************************************************************
#> WriteAjaxAndCGI(void)
#  ---------------------
#  Writes the Ajax and CGI script to support the confirm box as well
#  as the .htacess file to enable the CGI script
#
#  11.11.15 Original   By: ACRM
#
sub WriteAjaxAndCGI
{
    # --------------------------- mpajax.js ---------------------------- #
    if(open(my $fp, '>', 'mpajax.js'))
    {
        print $fp <<'__EOF';
        var gRequest = null;
        function createRequest() {
            var req = null;
            try {
                req = new XMLHttpRequest();
            } catch (trymicrosoft) {
                try {
                    req = new ActiveXObject("Msxml2.XMLHTTP");
                } catch (othermicrosoft) {
                    try {
                        req = new ActiveXObject("Microsoft.XMLHTTP");
                    } catch (failed) {
                        req = null;
                    }
                }
            }
            
            return(req);
        }
        
        function DisplayPage()
        {
            gRequest = createRequest();
            if (gRequest==null)
            {
                alert ("Browser does not support HTTP Request");
                return;
            } 
            
            var confirmed = document.getElementById("confirmed").checked;
            var name  = document.getElementById("name").value;
            var email = document.getElementById("email").value;
            
            name = name.replace(/^\s+/, '');
            
            if(!confirmed)
            {
                alert("You must tick the confirm box.");
            }
            else if(name.length < 2)
            {
                alert("You must provide your name.");
            }
            else if(! email.match(/.*\@.*\..*/))
            {
                alert("You must provide a valid email address.");
            }
            else
            {
                var url="./mpparticipation.cgi?name="+name+"&amp;email="+email+"&amp;confirmed="+confirmed;
                var throbberElement = document.getElementById("throbber");
                throbberElement.style.display = 'inline';
                
                gRequest.open("GET",url,true);
                
                gRequest.onreadystatechange=updatePage;
                gRequest.send(null);
            }
        }
        
        function updatePage() 
        { 
            if (gRequest.readyState==4 || gRequest.readyState=="complete")
            { 
                var responseElement  = document.getElementById("response");
                var throbberElement  = document.getElementById("throbber");
                var nameentryElement = document.getElementById("nameentry");
                
                var response = gRequest.responseText;
                
                responseElement.innerHTML      = response;
                throbberElement.style.display  = 'none';
                nameentryElement.style.display = 'none';
                responseElement.style.display  = 'inline';
            } 
        } 
__EOF
        close $fp;
    }

    # ----------------------- mpparticipation.cgi ---------------------- #
    if(open(my $fp, '>', 'mpparticipation.cgi'))
    {
        print $fp <<'__EOF';
#!/usr/bin/perl
        use strict;
        use CGI;
        $|=1;

        my $cgi = new CGI;

        my $name      = $cgi->param('name');
        my $email     = $cgi->param('email');
        my $confirmed = $cgi->param('confirmed');
        
        print $cgi->header();
        
        my $ok = 0;
        if($confirmed)
        {
            if(StoreParticipant($name, $email))
            {
                print <<__EOFX;
                <h4>Your details have been saved as:</h4>
                    <table>
                    <tr><th>Name:</th><td>$name</td></tr>
                    <tr><th>Email:</th><td>$email</td></tr>
                    </table>
__EOFX
                $ok = 1;
            }
        }

        if(!$ok)
        {
            print <<__EOFX;
            <h4>An error occurred</h4>

                <p>You need to reload this page and tick the confirmation box. Make
                sure you do not have any non-standard characters (particularly '#') in your name or email
                address.
                </p>
                <pre>
$name
$email
                </pre>
__EOFX
        }

        sub StoreParticipant
        {
            my($name, $email) = @_;
            
            my $user = "${name}_$email";
            $user =~ s/[^A-Za-z0-9]/_/g;    # Remove odd chars and whitespace
            $user =~ s/_+/_/g;              # Collapse multiple _ to one
            $user = "./participants/${user}.txt";
            my $time = GetTime();

            if(open(my $fp, '>', $user))
            {
                print $fp "$name\t$email\t$time\n";
                close $fp;
            }
            else
            {
                return(0);
            }
            return(1);
        }

        sub GetTime
        {
            my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
            $year += 1900;
            my $timeStr = sprintf("%02d-%02d-%04d:%02d:%02d:%02d",
                                  $mday,$mon,$year,
                                  $hour,$min,$sec);
            return($timeStr);
        }
__EOF
        close $fp;
        `chmod +x mpparticipation.cgi`;
    }

    # -------------------------- .htaccess   --------------------------- #
    if(open(my $fp, '>', '.htaccess'))
    {
        print $fp <<'__EOF';
Options +ExecCGI
AddHandler cgi-script .cgi
__EOF
        close $fp;
    }
}


#*************************************************************************
#> void MakeResponseDirectory(void)
#  --------------------------------
#  Creates a directory for the participants' responses
#
#  11.11.15 Original   By: ACRM
#
sub MakeResponseDirectory
{
    my $dir = 'participants';
    if(! -d $dir)
    {
        `mkdir $dir`;
        `chmod a+w $dir`;
        `chmod a+t $dir`;
        `chmod u+s $dir`;
    }
}


#*************************************************************************
#> void FixUp_confirm($aPage)
#  --------------------------
#  Replaces the [confirm] metatag with our AJAX/CGI for confirming
#  participation
#
#  11.11.15 Original   By: ACRM
#
sub FixUp_confirm
{
    my($aPage) = @_;

    my $regexStart = '<!--\s+\[confirm]\s+--\>';
    my $regexStop  = '<!--\s+\[\/confirm\]\s+--\>';

    foreach my $line (@$aPage)
    {
        if($line =~ /$regexStart/)
        {
            WriteAjaxAndCGI();
            MakeResponseDirectory();
            $line = "
<script src='mpajax.js'></script>
<div class='bs-callout bs-callout-warning'> 
   <div id='nameentry'>
      <h4>
";
        }
        elsif($line =~ /$regexStop/)
        {
            $line = "
      </h4>
      <form>
         <table>
            <tr><th>Name:</th><td><input type='text' size='40' name='name' id='name' /></td</tr>
            <tr><th>Email:</th><td><input type='text' size='40' name='email' id='email' /></td></tr>
         </table>
         <p><input type='checkbox' name='confirmed' id='confirmed' /> I confirm the above statement.</p>
         <p>&nbsp;</p>
         <p><input type='button' value='Submit' onclick='DisplayPage()' />
            <span id='throbber' style='display:none'><img src='throbber.gif' alt='throbber'/>Saving details...</span>
         </p>
      </form>
      <p>&nbsp;</p>
   </div>
   <div id='response' style='display:none'>&nbsp;</div>
</div>
";
        }
    }
}


#*************************************************************************
#> void CleanupDie(void)
#  ---------------------
#  Remove files generated by the script
#
#  11.11.15 Original   By: ACRM
#
sub CleanupDie
{
    `\\rm -f mpajax.js`;
    `\\rm -f mpcss.css`;
    `\\rm -f mptheme.css`;
    `\\rm -f mpautotooltip.js`;
    `\\rm -f mpparticipation.cgi`;
    `\\rm -i index.html page*.html`;

    exit(0);
}
