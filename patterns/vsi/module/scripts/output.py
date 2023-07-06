#!/usr/bin/python
import json
import sys

data = sys.argv[1]
print(
    '{ "data": "'
    + json.dumps(json.loads(data.replace('\\"', '"')[1:-1]), indent=4, sort_keys=True)
    .replace("\n", "\\n")
    .replace('"', '\\"')
    + '"}'
)
