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
	*@files,
	Int  :$wpm     is copy,
	Bool :$border  is copy,
	Int  :$line-no is copy,
	Int  :$to-left is copy,
) {
	by-word Supply.merge(|@files.map(*.IO.open.Supply) || $*IN.Supply),
		|(:$wpm     with $wpm    ),
		|(:$border  with $border ),
		|(:$line-no with $line-no),
		|(:$to-left with $to-left),
}

=begin pod

=head1 NAME

by-word.raku — CLI for App::ByWord

=head1 SYNOPSIS

    # From a file
    by-word.raku --wpm=450 --no-border text.txt

    # From STDIN
    cat text.txt | by-word.raku --wpm=350

    # Multiple files (merged)
    by-word.raku file1.txt file2.txt

=head1 DESCRIPTION

This script drives App::ByWord to render one word at a time in your terminal using RSVP. It accepts either STDIN or any number of file paths. When file paths are given, they are merged into a single stream.

=head1 OPTIONS

- C<--wpm=Int>         Words per minute (pace).
- C<--[no-]border>     Draw guide bars above/below the focus line.
- C<--line-no=Int>     1-based line number for the word.
- C<--to-left=Int>     Horizontal offset left of center for the anchor.

=head1 INPUTS

- STDIN: If no files are provided, STDIN is used.
- Files: One or more file paths are read and merged.

=head1 SIGNALS

- C<SIGINT> (Ctrl‑C): stops playback and restores the terminal state.

=head1 SEE ALSO

L<App::ByWord>

=end pod
