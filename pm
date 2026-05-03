import sys

all_params = sys.argv
if len(all_params) == 1:
    print("""
Usage:
    python -c "exec(__import__('urllib.request').request.urlopen('http://db0bc.github.io/pm').read())" <command> [options]
""")
