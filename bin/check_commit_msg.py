#!/usr/bin/env python3
import sys
import re
import os

def main():
    commit_msg_filepath = sys.argv[1]
    with open(commit_msg_filepath, 'r') as f:
        commit_msg = f.read()

    # Expected format: fix/refactor/...: [package, e.g. vis/server] message \n Signed-off-by: Name <email>
    # Regex explanation:
    # ^(fix|refactor|feat|docs|style|test|chore|ci|perf|revert)  -> starts with one of these types
    # :                                                          -> followed by a colon
    # \s+                                                       -> one or more spaces
    # \[                                                        -> open bracket
    # ([^\]]+)                                                  -> package name (anything but close bracket)
    # \]                                                        -> close bracket
    # \s+                                                       -> space(s)
    # .*                                                        -> message
    # \n                                                        -> newline
    # ([\s\S]*\n)?                                              -> optional body lines
    # Signed-off-by:                                            -> literally "Signed-off-by:"
    # \s+                                                       -> space(s)
    # .+                                                        -> name (one or more characters)
    # \s+                                                       -> space(s)
    # <[^>]+>                                                   -> email in angle brackets

    pattern = r'^(fix|refactor|feat|docs|style|test|chore|ci|perf|revert): \[([^\]]+)\] .*\n([\s\S]*\n)?Signed-off-by: .+ <[^>]+>$'
    
    if not re.search(pattern, commit_msg, re.MULTILINE):
        print("ERROR: Commit message does not match the required format.")
        print("Expected: <type>: [<package>] <message>")
        print("          <optional body>")
        print("          Sign-Off")
        print("-" * 40)
        print("Types: fix, refactor, feat, docs, style, test, chore, ci, perf, revert")
        print("Example:")
        print("fix: [vis] fix button color")
        print("")
        print("Sign-Off")
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
