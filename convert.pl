#! /usr/bin/perl -w
use strict;
use constant false => 0;
use constant true => 1;

my $filename = shift;
open(INPUT, $filename) or die "Could not open $filename";

my $bookTitle;
my $bookSubtitle;
my $newChapterTitle = true;
my $chapterTitle = false;
my $lessonNum = 0;
my $fh;

while(my $line = <INPUT>) {
  next if ($line =~ /^\s*$/);
  chomp $line;

  unless ($bookTitle) {
    $bookTitle = $line;
    next;
  }

  unless ($bookSubtitle) {
    $bookSubtitle = $line;
    next;
  }

  if ($newChapterTitle) {
    unless ($chapterTitle) {
      $chapterTitle = $line;
    }
    $newChapterTitle = false;
    $lessonNum++;
    $filename = "lesson$lessonNum.xhtml";

    open($fh, '>', $filename) or die "Could not open '$filename': $!";

    print $fh <<"HERE";
<?xml version='1.0' encoding='utf-8'?>
<html xmlns:epub="http://www.idpf.org/2007/ops" xmlns:pls="http://www.w3.org/2005/01/pronunciation-lexicon" xmlns:ssml="http://www.w3.org/2001/10/synthesis" xmlns="http://www.w3.org/1999/xhtml" xmlnsU0003Am="http://www.w3.org/1998/Math/MathML" xmlnsU0003Asvg="http://www.w3.org/2000/svg">

<head>
  <title>$chapterTitle</title>
  <link rel="stylesheet" type="text/css" href="style.css"/>
</head>

<body>

  <h1>$chapterTitle</h1>

HERE
    next;
  }

  # Check for next chapter title
  # If the line does not have at least one period, then it is a chapter title.
  if ($line !~ /\./ && $line !~ /^●/) {
    print $fh <<"HERE";
</body>

</html>
HERE
    close $fh;
    $newChapterTitle = true;
    $chapterTitle = $line;
    next;
  } else {
    # Found a paragraph
    print $fh <<"HERE";
  <p>$line</p>\n
HERE
  }
}

close(INPUT);
