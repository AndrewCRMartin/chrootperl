#!/usr/bin/perl -s

use strict;
my $noflags = 1;

if(defined($::h))
{
    UsageDie();
}

if(scalar(@ARGV))
{
    WriteCSS();

    my @data = <>;

    my $title = GetTitle(@data);
    print "Title: $title\n";

    my $style = GetStyle(@data);
    print "Style: $style\n";
    
    my $aMenu  = GetMenuItems(@data);
    print "Menu: |";
    foreach my $menu (@$aMenu)
    {
        print " $menu |";
    }
    print "\n";
    
    my $homeMenu = GetHomeMenu(@data);
    print "Home menu item: $homeMenu\n";
    
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
elsif($noflags)
{
    UsageDie();
}

#******************************************************************
sub WriteCSS
{
    if(open(my $fp, '>', 'theme.css'))
    {
        print $fp <<__EOF;
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

    if(open(my $fp, '>', 'mycss.css'))
    {
        print $fp <<__EOF;

/* Side notes for calling out things
-------------------------------------------------- */
 
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
.bs-callout code,
.bs-callout .highlight {
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

.question {
background-color: #eeeeee;
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

__EOF
        close $fp;
    }
}

#******************************************************************
sub UsageDie
{
    print <<__EOF;

makepages V1.0 (c) UCL, Dr. Andrew C.R. Martin

Usage: makepages [-bootstrap] [file.html]
       makepages file.html

__EOF
}

#******************************************************************
#> my $title = GetTitle(@data);
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

#******************************************************************
#> my $style = GetStyle(@data);
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

#******************************************************************
#> $aMenu  = GetMenuItems(@data);
sub GetMenuItems
{
    my(@data) = @_;
    my @menu = ();
    foreach my $line (@data)
    {
        if($line =~ /\[page\s+menu\s*=\s*['"](.*?)['"]\]/)
        {
            push @menu, $1;
        }
    }
    return(\@menu);
}

#******************************************************************
#> @aPages = GetPages(@data);
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

        if($line =~ /\[page\s.*\]/)
        {
            @{$Pages[$pageNum]} = ();
            push(@{$Pages[$pageNum]}, $line);
            $inPage = 1;
        }
        elsif($line =~ /\[\/page\]/)
        {
            $inPage = 0;
            $pageNum++;
        }
    }    
    return(\@Pages);
}

#******************************************************************
#>     WritePage($pageNum, $title, $style, $homeMenu, $aMenu, $aPage, $lastPage);
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


#******************************************************************
#> $homeMenu = GetHomeMenu(@data);
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


#******************************************************************
#> PrintHTMLPage($fp, $aPage);
sub PrintHTMLPage
{
    my($fp, $aPage) = @_;

    print $fp " <div class='container theme-showcase'>\n";

    FixUp_bigheading($aPage);

    foreach my $line (@$aPage)
    {
        print $fp $line;
    }

    print $fp " </div> <!-- /container -->\n";
}

#******************************************************************
sub FixUp_bigheading
{
    my($aPage) = @_;

    foreach my $line (@$aPage)
    {
        $line = Replace($line, 'bigheading','<div class="jumbotron">');
        $line = Replace($line, '/bigheading','</div> <!-- jumbotron -->');
    }
}

#******************************************************************
sub Replace
{
    my($line, $old, $new) = @_;
    my $regex = '<!--\s+\[' . $old . '\]\s+--\>';
    $line =~ s/$regex/$new/;
    return($line);
}


#******************************************************************
#> PrintHTMLFooter($fp);
sub PrintHTMLFooter
{
    my($fp) = @_;

    print $fp <<__EOF;

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->

    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" crossorigin="anonymous"></script>

<!--
    <script src="bootstrap/assets/js/jquery.js"></script>
    <script src="bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="bootstrap/assets/js/holder.js"></script>
    <script src="autotooltip.js"></script>
-->
  </body>
</html>
__EOF
}


#******************************************************************
#> PrintHTMLNextButton($fp, $pageNum);
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

#******************************************************************
#> PrintHTMLMenu($fp, $homeMenu, $aMenu, $pageNum);
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

#******************************************************************
#> PrintHTMLHeader($fp, $title, $style);
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
    <link rel="shortcut icon" href="bootstrap/dist/ico/favicon.png">

    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" crossorigin="anonymous">

    <!-- Bootstrap theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css" crossorigin="anonymous">

<!-- 
    <link href="bootstrap/dist/css/bootstrap.css" rel="stylesheet">
    <link href="bootstrap/dist/css/bootstrap-theme.min.css" rel="stylesheet">
-->

    <!-- Custom styles for this template -->
    <link href="theme.css" rel="stylesheet">

    <!-- And my own useful extras -->
    <link href="mycss.css" rel="stylesheet"> 

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

