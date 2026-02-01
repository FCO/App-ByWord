#!/usr/bin/env raku

use App::ByWord;

my %*SUB-MAIN-OPTS =
	:named-anywhere,
	:bundling,
	:coerce-allomorphs-to(Int),
	:allow-no,
	:numeric-suffix-as-value,
;

multi MAIN(
	*@files                 ,
	UInt :w(:$wpm          ),
	Bool :b(:$border       ),
	UInt :l(:$line-no      ),
	Int  :t(:$to-left      ),
	UInt :s(:$starting-word),
	UInt :$wait             ,
	UInt :$wait-to-start    ,
	UInt :$wait-to-finish   ,
) {
	my $words = by-word Supply.merge(|@files.map(*.IO.Supply) || $*IN.Supply),
		|(:$wpm            with $wpm           ),
		|(:$border         with $border        ),
		|(:$line-no        with $line-no       ),
		|(:$to-left        with $to-left       ),
		|(:$starting-word  with $starting-word ),
		|(:$wait           with $wait          ),
		|(:$wait-to-start  with $wait-to-start ),
		|(:$wait-to-finish with $wait-to-finish),
	;

	say "Read $words words"
}

=begin pod

=head1 NAME

by-word — CLI for App::ByWord

=head1 SYNOPSIS

    # From a file
    by-word --wpm=450 --no-border text.txt

    # From STDIN
    cat text.txt | by-word --wpm=350

    # Multiple files (merged)
    by-word file1.txt file2.txt

=head1 DESCRIPTION

This script drives App::ByWord to render one word at a time in your terminal using RSVP. It accepts either STDIN or any number of file paths. When file paths are given, they are merged into a single stream.

=head1 OPTIONS

Usage: C<by-word [<files> ...] [-w|--wpm[=UInt]] [-b|--border] [-l|--line-no[=UInt]] [-t|--to-left[=Int]] [-s|--starting-word[=UInt]] [--wait[=UInt]] [--wait-to-start[=UInt]] [--wait-to-finish[=UInt]]>

- C<-w|--wpm[=UInt]>           Words per minute (pace).
- C<-b|--[no-]border>          Draw guide bars above/below the focus line.
- C<-l|--line-no[=UInt]>       1-based line number for the word.
- C<-t|--to-left[=Int]>        Horizontal offset left of center for the anchor.
- C<-s|--starting-word[=UInt]> Start from this word index (skip).
- C<--wait[=UInt]>             Base delay unit in empty intervals; default C<wpm div 50>.
- C<--wait-to-start[=UInt]>    Empty intervals before the first word of each line; defaults to C<--wait>.
- C<--wait-to-finish[=UInt]>   Empty intervals after the last word of each line; defaults to C<--wait>.

=head1 INPUTS

- STDIN: If no files are provided, STDIN is used.
- Files: One or more file paths are read and merged.

=head1 SIGNALS

- C<SIGINT> (Ctrl‑C): stops playback and restores the terminal state.
- C<SIGTERM>: also stops playback and restores the terminal state.

=head1 SEE ALSO

L<App::ByWord>

=end pod
