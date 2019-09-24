#!/usr/bin/perl

# This script reads the indicated file (notionally a .tsv tab-separated-value file
# extracted from the spreadsheet with sea-shore flow data) and dumps a more or less
# plain HTML table to the output.
#
# You'll need to manually fix up the table header, if the header is the first row
# of the .tsv. Note that non-SSF ratings and nuclear ratings are skipped entirely;
# you need to manually scrub these with each update for now.
#
# Call like: perl build.pl ssf-2019-09.tsv > output.html

use strict;
use 5.018;
use autodie;

die "Enter a file to open" unless @ARGV;
open my $fh, '<', $ARGV[0];

while (my $line = <$fh>) {
    my ($rating, $sea1, @fields) = split("\t", $line);
    next if $sea1 =~ /^Career Path/;
    next if $sea1 =~ /^Refer to/;

    # Passed idiot checks, we won't use $sea1 separately anymore
    unshift @fields, $sea1;

    chomp foreach @fields;

    # Two last fields are individual "NOTES" columns which we'll combine
    my ($note1, $note2) = splice(@fields, -2);

    # Convert to hyperlink if present
    foreach my $note ($note1, $note2) {
        next unless $note;
        my $note_id = lc $note;
        $note = "<a href=\"ssf-notes-2019-09.html#note-$note_id\">See Note $note<\/a>";
    }

    # note1 will have only note field after this
    $note1 = "$note1, $note2" if ($note1 && $note2);
    $note1 = $note2 if ($note2 && !$note1);
    push @fields, $note1;

    say "<tr id=\"rating_$rating\">";
    say "  <th>$rating</th>";
    say "  <td>$_</td>" foreach @fields;
    say "</tr>\n";
}
