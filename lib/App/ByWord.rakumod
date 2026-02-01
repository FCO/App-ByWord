unit class App::ByWord;
use Terminal::Width;
use Terminal::ANSI;

my Supplier $intervaller .= new;
my Supply   $interval     = $intervaller.Supply.migrate;

my $status = False;

sub calc-orp(Str() $word) is export {
	return 0 unless $word.chars > 1;
	min(4, max(1, floor($word.chars div 3)))
}

sub by-word(
	Supply() $supply,
	UInt :$wpm            = 200,
	Bool :$border         = True,
	UInt :$line-no        = 11,
	Int  :$to-left        = 5,
	UInt :$starting-word  = 0,
	UInt :$wait           = $wpm div 50,
	UInt :$wait-to-start  = $wait,
	UInt :$wait-to-finish = $wait,
	--> UInt
) is export {
	my sub toggle-status {
		$status .= not;
		$intervaller.emit: do if $status {
		 	Supply.interval: 60 / $wpm;
		} else {
			Supplier.new.Supply
		}
	}

	save-screen;
	clear-screen;
	home;
	hide-cursor;

	my Supply $words .= zip: :with{@_.tail}, $interval, supply {
		whenever $supply -> $line {
			LAST {
				emit("") xx $wait-to-finish;
				done;
			}
			emit("") xx $wait-to-start;
			for $line.comb: / \w+ | <+[\S]-[\w]>+/ {
				.emit
			}
		}
	}.skip: $starting-word;

	my UInt $read = $starting-word;

	react {
		whenever signal SIGINT { done }
		whenever signal SIGTERM { done }
		whenever $words -> $word {
			LAST done;
			$read++;

			my $width      = terminal-width;
			my $half-width = $width div 2;

			my $left-half  = $half-width - $to-left;
			my $right-half = $half-width - $to-left + 1;

			next if $line-no > $width;

			if $border {
				if $line-no > 0 {
					print-at $line-no - 1, 0          , "━" x $left-half - 1;
					print-at $line-no - 1, $left-half , "┯";
					print-at $line-no - 1, $right-half, "━" x $half-width + $to-left;
				}

				if $line-no < $width {
					print-at $line-no + 1, 0          , "━" x $left-half - 1;
					print-at $line-no + 1, $left-half , "┷";
					print-at $line-no + 1, $right-half, "━" x $half-width + $to-left;
				}
			}

			next unless $word;

			my $orp  = calc-orp $word;
			my $pre  = $word.substr: 0, $orp;
			my $char = $word.substr: $orp, 1;
			my $post = $word.substr: $orp + 1;

			my $right      = $right-half + $post.chars;

			print-at $line-no, 0                , " " x $left-half - $orp;
			print-at $line-no, $left-half - $orp, $pre;
			print-at $line-no, $left-half       , "\o33[31m{ $char }\o33[m";
			print-at $line-no, $right-half      , $post.substr: 0, $width - $right-half;
			print-at $line-no, $right           , " " x 1 + $width - $right;
		}

		# $intervaller.emit: Supply.interval: 60 / $wpm;
		toggle-status
	}

	show-cursor;
	restore-screen;
	$read
}

=begin pod

=head1 NAME

App::ByWord — Rapid serial word presentation in the terminal

=head1 SYNOPSIS

=begin code :lang<raku>
use App::ByWord;

by-word "very-big-file.txt".IO, :wpm(400), :border, :line-no(12), :to-left(5);
=end code

=head1 DESCRIPTION

App::ByWord renders one word at a time centered in the terminal, highlighting the letter at the Optimal Recognition Point (ORP) in red. This follows the RSVP (Rapid Serial Visual Presentation) approach to minimize eye movement and speed up reading. The pace is controlled via words per minute (WPM). The terminal screen is saved/restored and the cursor is hidden while rendering; pressing Ctrl‑C (SIGINT) stops playback and restores the terminal state.

=head1 INTERFACE

=head2 sub by-word

    sub by-word(
        Supply() $supply,
        UInt :$wpm            = 200,
        Bool :$border         = True,
        UInt :$line-no        = 11,
        Int  :$to-left        = 5,
        UInt :$starting-word  = 0,
        UInt :$wait           = $wpm div 50,
        UInt :$wait-to-start  = $wait,
        UInt :$wait-to-finish = $wait,
    ) is export

=item C<$supply>: A C<Supply> of lines. Each line is split into words and emitted one by one.
=item C<:$wpm>: Words per minute; base interval C<60 / $wpm>.
=item C<:$border>: When true, draws guide bars above/below the focus line for visual anchoring.
=item C<:$line-no>: 1‑based line number where the word is drawn.
=item C<:$to-left>: Horizontal offset (to the left of the terminal center) of the anchor position.
=item C<:$starting-word>: Start from this word index (skip).
=item C<--wait>: Base delay unit used for empty intervals (no word emitted). Defaults to C<$wpm div 50>.
=item C<--wait-to-start>: Number of empty intervals emitted before the first word of each input line. Defaults to C<--wait>.
=item C<--wait-to-finish>: Number of empty intervals emitted after the last word of each input line. Defaults to C<--wait>.

=head2 Return Value

Returns the total number of words read (C<UInt>). This value is useful to resume later using C<:starting-word>.

=head2 ORP (Optimal Recognition Point)

The ORP index is computed as:

    min(4, max(1, floor($word.chars div 3)))

This picks an internal index (1..4) for the character to highlight in each word, aiding faster recognition.

=head1 DEMO

![by-word demo](docs/by-word-demo.gif)

=head1 EXAMPLES

=item From STDIN:

=begin code :lang<raku>

    by-word $*IN.Supply, :starting-word(100);

=end code

=item From file(s):

=begin code :lang<raku>

    by-word Supply.merge(|@files.map(*.IO.open.Supply)), :wpm(400), :border, :line-no(12), :to-left(5);

=end code

Or use the CLI command C<by-word>:

=begin code :lang<bash>

    by-word [<files> ...] [-w|--wpm[=UInt]] [-b|--border] [-l|--line-no[=UInt]] [-t|--to-left[=Int]] [-s|--starting-word[=UInt]] [--wait[=UInt]] [--wait-to-start[=UInt]] [--wait-to-finish[=UInt]]

=end code

=head1 SIGNALS

=item C<SIGINT> (Ctrl‑C): stops playback and restores screen/cursor.

=head1 INSTALLATION

Install via C<zef>:

=begin code :lang<bash>

zef install .
# Or from GitHub:
zef install https://github.com/FCO/App-ByWord.git

=end code

After installation, invoke the CLI:

=begin code :lang<bash>

by-word --wpm=450 --no-border text.txt
cat text.txt | by-word --wpm=350
by-word file1.txt file2.txt

=end code

=head1 DEPENDENCIES

=item C<Terminal::Width> — terminal width detection.
=item C<Terminal::ANSI>  — cursor movement, screen control, and styling (red ORP character).

=head1 SEE ALSO

C<Terminal::Width>, C<Terminal::ANSI>

=head1 AUTHOR

Fernando Correa de Oliveira <fco@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2026 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
