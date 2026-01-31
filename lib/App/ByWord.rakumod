unit class App::ByWord;
use Terminal::Width;
use Terminal::ANSI;

my Supplier $intervaller .= new;
my Supply   $interval     = $intervaller.Supply.migrate;

sub calc-orp(Str() $word) {
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

App::ByWord - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use App::ByWord;

=end code

=head1 DESCRIPTION

App::ByWord is ...

=head1 AUTHOR

Fernando Correa de Oliveira <fco@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2026 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
