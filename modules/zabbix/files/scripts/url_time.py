#!/usr/bin/env python3

import sys
import requests
import traceback

try:
  if len(sys.argv) > 1:
     print(int(requests.get(sys.argv[1]).elapsed.total_seconds()*1000))
  else:
     raise RuntimeError('No arg found')
except Exception as ee:
    print(str(ee)+ '\n'+traceback.format_exc())
finally:
    exit(0)