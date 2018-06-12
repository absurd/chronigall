# Chronigall
*A Markdown based format for invoiceable timekeeping*


![Screenshot](/screenshots/screenshot.png)

## Overview

This repository comprises the specification of the Chronigall format for
keeping records of work done for such purposes as billing hourly clients as
well as a reference implementation of a command line timer which automatically
appends to a timelog file in the Chronigall markdown format and tools for
creating timelog artifcats from a master project timelog suitable for client
review.



## Format

A Chronigall timelog is a Markdown file with entries of the following form:

```
#2018-05-21 15:03:56-0400
03:03:23 -- new feature backend module-- ported to the new project
repo and got tests passing (mostly a pain in the ass w/ pk values changing
courtesy of postgresql vis-a-vis deprecated sqlite expectations)
> 01:32:34 -- repose
> Efficiency: 66%

#2018-05-21 15:38:45-0400
00:09:48 -- fielding Matej question regarding search by assoc entity
> 00:00:02 -- repose
> Efficiency: 99%

```

Each Chronigall timelog entry consists of four parts:

1. A first level Atx-style header beginning with a single hash (pound sign)
   character followed by the date in RFC-3339 format with second resolution.
2. A duration in the form `HH:MM:SS`
3. A description beginning on the same line as the duration, separated by a
   space padded double-hyphen (but not an emdash character).
4. (Optional) Lines beginning with the Markdown quote character `>` which are
   treated as annotating comments.

Note the following properties:

* The description can contain single linebreaks so long as it begins on the
  same line as the duration.
* Each entry is separated by at least one empty line (i.e. `\n\n`)



## Specification Extensions

### Billing Periods / Sections

An organization might request a Chronigall timelog format file covering a
billable period. While the specification does not dictate the manner in which
these files are generated or organized, the reference implementation tools
included in this repository enable the generation of billing period specific
timelog extracts from a project's master timelog.

To this end, the reference implementation tools recognize a line beginning with
`>>>` as the delimiter between sections of a timelog, for example:

```
#2018-05-11 19:57:20-0400
00:36:00 -- Amos, Alan consult

>>> INVOICE #033171501

#2018-05-18 20:19:54-0400
00:09:52 -- merging foo_widget branch into master
> 00:00:00 -- repose
> Efficiency: 100%

#2018-05-19 15:05:54-0400
00:10:43 -- cont'd

#2018-05-21 09:45:31-0400
03:34:07 -- fixing up foo_widget failing tests in preparation for merge with
new_feature branch
> 03:54:40 -- repose
> Efficiency: 48%

```

In the above, the creation of an extract will begin after the last `>>>` line,
i.e. the entry on May 18.


### Annotations Omitted From Extracts

The reference implementation tools also provide the ability to track break/idle
time during a workblock, which are recorded as "repose" and efficiency
percentage annotations. As these are intended for internal use and
self-actualization, they are omitted from the extract created for external
consumption.

While not a part of the current specification version nor supported by the
included tools, a future version of Chronigall reserves the use of the `>>`
prefix for annotation lines that *should* be included in the extract, for
instance for the purpose of category tracking.


### Location of the Timelog File

The reference implementation timer tool has the ability to write to Chronigall
timelog files on a per project basis. As such, it has the following
expectations:

1. That it will be invoked from within the project directory or one of its
   subdirectories (with no limit to how deeply nested the current subdirectory
   is within the project root directory).
2. That the project root directory contains a top-level `meta` subdirectory
   containing a file `timelog.md`.

A valid directory structure might look like this:

```
. (INVOKE TIMER FROM HERE)
├── src (OR HERE)
│   ├── Pipfile
│   ├── Pipfile.lock
│   ├── backend_core
│   ├── database (OR HERE)
│   │   ├── foo.sql
│   │   ├── wp_import.py
│   ├── db_utils.py
│   ├── etl
│   ├── frontend
├── meta (OR HERE)
│   ├── milestones.md
│   ├── notes.md
│   ├── spec.md
│   ├── spec_annotated.md
│   ├── timelog.md

```



## Reference Implementation Tools

Included are the following tools:

1. A command line modal timer bash script that will prompt for description and
   automatically write a properly formatted entry to the local project timelog
   on workblock completion.

3. ~~A tool for creating an extract from a project's master timelog since the
   last invoice date.~~ (Not finished yet)


## Installation

On cloning this repository, `cd` into the repo directory and run `install.sh`.
May need to run as sudo depending on `/usr/local/bin` permissions.

Alternatively, the scripts `chronigall_timer.sh` and
`find_local_file.sh`, and `left_center_pad.sh` should be given execution
permission (`chmod +x`) And at least the latter should be placed in the PATH
and aliased to `findlocalest`.

Example:

```
git clone <repository-url>
cd <repository-dir>
chmod +x find_local_file.sh
chmod +x chronigall_timer.sh
ln -s "$(pwd)"/find_local_file.sh /usr/local/bin/findlocalest
ln -s "$(pwd)"/chronigall_timer.sh /usr/local/bin/chronigall

```

### Installation Jankiness

On OSX/MacOS, the bundled BSD implementation of `date` functions differently
than the GNU implementation. The `chronigall_timer.sh` script invokes `gdate`.

`gdate` can be installed as part of `coreutils`:

`brew install coreutils`

On Linux systems, the reference to `gdate` on line 74 of `chronigall_timer.sh`
should be changed to `date`.

`left_center_pad.sh` which provides center formatting for the timer is a ZSH
script. Make sure that zsh is available or remove the references to `centerpad`
on lines 10, 11, and 12.



## Usage

Assuming the above installation aliases, `chronigall` invokes the timer in
`ready` mode (useful with iTerm2 window arrangements and profile start
commands, for example). Pressing the any key will start the timer in `work`
mode. While the timer is running, pressing space pauses work mode and switches
the timer into `repose` mode.

Notice that once the duration of repose exceeds the duration of work, the
repose mode label will turn red. From either mode, pressing `q` will end the
workblock and prompt for a description of work done.

Fill in the description and press `<enter>` and an entry will be written to
the local timelog file.

If SIGINT is sent (i.e. `ctrl-c`) then the workblock will be aborted and the
duration of work will be dumped to stdout without writing to the local timelog
file.



## License

The MIT License (MIT)

Copyright (c) 2018 Gallus Absurd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
