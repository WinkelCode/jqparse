# jqparse
Parse mixed content with `jq`

# Usage:

```
Usage: mycommand | jqparse.sh [options]
Purpose: Via stdin, parse JSON from mixed input (for instance, Ansible).
Tip: Set variable 'ANSIBLE_FORCE_COLOR=true' or 'force_color=True' in 'ansible.cfg' to re-enable colors.
Options:
        -o, --output <dir>      Parse JSON into files instead of to stdout (implies -nc)
        -c, --convert           Try to convert invalid JSON into valid JSON
        -nc, --no-colors        Disable colors in jq output
        -h, --help, --usage     Show this help message
```
