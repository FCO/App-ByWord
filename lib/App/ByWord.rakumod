unit class App::ByWord;
use Terminal::Width;
use Terminal::ANSI;

my Supplier $intervaller .= new;
my Supply   $interval     = $intervaller.Supply.migrate;

sub calc-orp(Str() $word) is export {
	return 0 unless $word.chars > 1;
	min(4, max(1, floor($word.chars div 3)))
}

sub by-word(
	Supply() $supply,
	Int  :$wpm     = 300,
	Bool :$border  = True,
	Int  :$line-no = 11,
	Int  :$to-left = 5,
) is export {
	save-screen;
	clear-screen;
	home;
	hide-cursor;

	my Supply $words .= zip: :with{@_.tail}, $interval, supply {
		whenever $supply -> $line {
			LAST done;
			.emit for $line.words;
		}
	}

	react {
		whenever signal SIGINT { done }
		whenever $words -> $word {
			LAST done;
			my $orp  = calc-orp $word;
			my $pre  = $word.substr: 0, $orp;
			my $char = $word.substr: $orp, 1;
			my $post = $word.substr: $orp + 1;

			my $width      = terminal-width;
			my $half-width = $width div 2;

			my $left-half  = $half-width - $to-left;
			my $right-half = $half-width - $to-left + 1;
			my $right      = $right-half + $post.chars;

			if $border {
				print-at $line-no - 1, 0          , "━" x $left-half - 1;
				print-at $line-no - 1, $left-half , "┯";
				print-at $line-no - 1, $right-half, "━" x $half-width + $to-left;

				print-at $line-no + 1, 0          , "━" x $left-half - 1;
				print-at $line-no + 1, $left-half , "┷";
				print-at $line-no + 1, $right-half, "━" x $half-width + $to-left;
			}

			print-at $line-no, 0                , " " x $left-half - $orp;
			print-at $line-no, $left-half - $orp, $pre;
			print-at $line-no, $left-half       , "\o33[31m{ $char }\o33[m";
			print-at $line-no, $right-half      , $post;
			print-at $line-no, $right           , " " x $width - $right;
		}

		$intervaller.emit: Supply.interval: 60 / $wpm;
	}

	show-cursor;
	restore-screen;
}

=begin pod

=head1 NAME

App::ByWord — Rapid serial word presentation in the terminal

=head1 SYNOPSIS

=begin code :lang<raku>
use App::ByWord;

my $s = supply {
    .emit for "This is an accelerated reading example.".words;
    done;
}

by-word $s, :wpm(400), :border, :line-no(12), :to-left(5);
=end code

=head1 DESCRIPTION

App::ByWord renders one word at a time centered in the terminal, highlighting the letter at the Optimal Recognition Point (ORP) in red. This follows the RSVP (Rapid Serial Visual Presentation) approach to minimize eye movement and speed up reading. The pace is controlled via words per minute (WPM). The terminal screen is saved/restored and the cursor is hidden while rendering; pressing Ctrl‑C (SIGINT) stops playback and restores the terminal state.

=head1 INTERFACE

=head2 sub by-word

    sub by-word(
        Supply() $supply,
        Int  :$wpm     = 300,
        Bool :$border  = True,
        Int  :$line-no = 11,
        Int  :$to-left = 5,
    ) is export

=item C<$supply>: A C<Supply> of lines. Each line is split into words (C<.words>) and emitted one by one.
=item C<:$wpm>: Words per minute; the inter‑word interval is C<60 / $wpm>.
=item C<:$border>: When true, draws guide bars above/below the focus line for visual anchoring.
=item C<:$line-no>: 1‑based line number where the word is drawn.
=item C<:$to-left>: Horizontal offset (to the left of the terminal center) of the anchor position.

=head2 ORP (Optimal Recognition Point)

The ORP index is computed as:

    min(4, max(1, floor($word.chars div 3)))

This picks an internal index (1..4) for the character to highlight in each word, aiding faster recognition.

=head1 EXAMPLES

=item From STDIN:

=begin code :lang<raku>

    by-word $*IN.Supply;

=end code

=item From file(s):

=begin code :lang<raku>

    by-word Supply.merge(|@files.map(*.IO.open.Supply));

=end code

Or use the CLI script in C<bin/by-word.raku>:

=begin code :lang<bash>

    by-word --wpm=450 --no-border text.txt

=end code

=head1 SIGNALS

=item C<SIGINT> (Ctrl‑C): stops playback and restores screen/cursor.

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
