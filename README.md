[![Actions Status](https://github.com/FCO/App-ByWord/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/App-ByWord/actions)

NAME
====

App::ByWord — Rapid serial word presentation in the terminal

SYNOPSIS
========

```raku
use App::ByWord;

my $s = supply {
    .emit for "This is an accelerated reading example.".words;
    done;
}

by-word $s, :wpm(400), :border, :line-no(12), :to-left(5);
```

DESCRIPTION
===========

App::ByWord renders one word at a time centered in the terminal, highlighting the letter at the Optimal Recognition Point (ORP) in red. This follows the RSVP (Rapid Serial Visual Presentation) approach to minimize eye movement and speed up reading. The pace is controlled via words per minute (WPM). The terminal screen is saved/restored and the cursor is hidden while rendering; pressing Ctrl‑C (SIGINT) stops playback and restores the terminal state.

INTERFACE
=========

sub by-word
-----------

    sub by-word(
        Supply() $supply,
        Int  :$wpm     = 300,
        Bool :$border  = True,
        Int  :$line-no = 11,
        Int  :$to-left = 5,
    ) is export

  * `$supply`: A `Supply` of lines. Each line is split into words (`.words`) and emitted one by one.

  * `:$wpm`: Words per minute; the inter‑word interval is `60 / $wpm`.

  * `:$border`: When true, draws guide bars above/below the focus line for visual anchoring.

  * `:$line-no`: 1‑based line number where the word is drawn.

  * `:$to-left`: Horizontal offset (to the left of the terminal center) of the anchor position.

ORP (Optimal Recognition Point)
-------------------------------

The ORP index is computed as:

    min(4, max(1, floor($word.chars div 3)))

This picks an internal index (1..4) for the character to highlight in each word, aiding faster recognition.

EXAMPLES
========

  * From STDIN:

```raku
    by-word $*IN.Supply;
```

  * From file(s):

```raku
    by-word Supply.merge(|@files.map(*.IO.open.Supply));
```

Or use the CLI script in `bin/by-word.raku`:

```bash
    by-word --wpm=450 --no-border text.txt
```

SIGNALS
=======

  * `SIGINT` (Ctrl‑C): stops playback and restores screen/cursor.

DEPENDENCIES
============

  * `Terminal::Width` — terminal width detection.

  * `Terminal::ANSI` — cursor movement, screen control, and styling (red ORP character).

SEE ALSO
========

`Terminal::Width`, `Terminal::ANSI`

AUTHOR
======

Fernando Correa de Oliveira <fco@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2026 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

