# pSLOC
## (Print Source Lines of Code)

Concatenate all lines of source code in a project into a text file for printing. I recently have taken up printing out my source code and after every project found it inconvenient to use different variations of find and awk. To solve this I made this script which defines a source file as a file that isn't binary and isn't under any hidden directory.

### Add to PATH

To use pSLOC anywhere symlink pSLOC to `/usr/local/bin`:

`sudo ln -s pSLOC.sh /usr/local/bin/pSLOC`

### Usage

`pSLOC [-o output_file] [-e exclude_pattern] ...`

-o   Output file (default: pSLOC.txt)
-e   Exclude files/directories matching pattern
-h   Show help message

