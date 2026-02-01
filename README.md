[![Actions Status](https://github.com/FCO/App-ByWord/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/App-ByWord/actions)

NAME
====

App::ByWord — Rapid serial word presentation in the terminal

SYNOPSIS
========

```raku
use App::ByWord;

by-word "very-big-file.txt".IO, :wpm(400), :border, :line-no(12), :to-left(5);
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
        UInt :$wpm            = 200,
        Bool :$border         = True,
        UInt :$line-no        = 11,
        Int  :$to-left        = 5,
        UInt :$starting-word  = 0,
        UInt :$wait           = $wpm div 50,
        UInt :$wait-to-start  = $wait,
        UInt :$wait-to-finish = $wait,
    ) is export

  * `$supply`: A `Supply` of lines. Each line is split into words and emitted one by one.

  * `:$wpm`: Words per minute; base interval `60 / $wpm`.

  * `:$border`: When true, draws guide bars above/below the focus line for visual anchoring.

  * `:$line-no`: 1‑based line number where the word is drawn.

  * `:$to-left`: Horizontal offset (to the left of the terminal center) of the anchor position.

  * `:$starting-word`: Start from this word index (skip).

  * `--wait`: Base delay unit used for empty intervals (no word emitted). Defaults to `$wpm div 50`.

  * `--wait-to-start`: Number of empty intervals emitted before the first word of each input line. Defaults to `--wait`.

  * `--wait-to-finish`: Number of empty intervals emitted after the last word of each input line. Defaults to `--wait`.

Return Value
------------

Returns the total number of words read (`UInt`). This value is useful to resume later using `:starting-word`.

ORP (Optimal Recognition Point)
-------------------------------

The ORP index is computed as:

    min(4, max(1, floor($word.chars div 3)))

This picks an internal index (1..4) for the character to highlight in each word, aiding faster recognition.

EXAMPLES
========

  * From STDIN:

```raku
    by-word $*IN.Supply, :starting-word(100);
```

  * From file(s):

```raku
    by-word Supply.merge(|@files.map(*.IO.open.Supply)), :wpm(400), :border, :line-no(12), :to-left(5);
```

Or use the CLI command `by-word`:

```bash
    by-word [<files> ...] [-w|--wpm[=UInt]] [-b|--border] [-l|--line-no[=UInt]] [-t|--to-left[=Int]] [-s|--starting-word[=UInt]] [--wait[=UInt]] [--wait-to-start[=UInt]] [--wait-to-finish[=UInt]]
```

SIGNALS
=======

  * `SIGINT` (Ctrl‑C): stops playback and restores screen/cursor.

INSTALLATION
============

Install via `zef`:

```bash
zef install .
# Or from GitHub:
zef install https://github.com/FCO/App-ByWord.git
```

After installation, invoke the CLI:

```bash
by-word --wpm=450 --no-border text.txt
cat text.txt | by-word --wpm=350
by-word file1.txt file2.txt
```

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

