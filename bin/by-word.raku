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
