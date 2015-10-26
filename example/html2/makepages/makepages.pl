#!/usr/bin/perl 

use strict;

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
    WritePage($pageNum, $title, $style, $aMenu, $aPage, $lastPage);
    $pageNum++;
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
#>     WritePage($pageNum, $title, $style, $aMenu, $aPage, $lastPage);
sub WritePage
{
    my ($pageNum, $title, $style, $aMenu, $aPage, $lastPage) = @_;

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

    print $fp <<__EOF;
 <div class="container theme-showcase">
__EOF

    foreach my $line (@$aPage)
    {
        print $fp $line;
    }

}

#******************************************************************
#> PrintHTMLFooter($fp);
sub PrintHTMLFooter
{
    my($fp) = @_;

    print $fp <<__EOF;

 </div> <!-- /container -->

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="bootstrap/assets/js/jquery.js"></script>
    <script src="bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="bootstrap/assets/js/holder.js"></script>
    <script src="autotooltip.js"></script>

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
            print $fp "<li$active><a href='$filename'>$$aMenu[$i]</a></li>\n";
        }
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

    <title>$title</title>

    <!-- Bootstrap core CSS -->
    <link href="bootstrap/dist/css/bootstrap.css" rel="stylesheet">
    <!-- Bootstrap theme -->
    <link href="bootstrap/dist/css/bootstrap-theme.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="theme.css" rel="stylesheet">

    <!-- And my own useful extras -->
<!--    <link href="mycss.css" rel="stylesheet"> 
-->

    <!-- Any style information from the web page -->
    $style

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="../../assets/js/html5shiv.js"></script>
      <script src="../../assets/js/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>
__EOF
}

