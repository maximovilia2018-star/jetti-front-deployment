#!/usr/bin/env python3

import sys
import re
import requests
import traceback

try:
  if len(sys.argv) > 2:
    page=requests.get(sys.argv[1]).text
    print(int(len(re.findall(sys.argv[2],page))>0))
  else:
     raise RuntimeError('args less 2')
except Exception as ee:
  print(str(ee)+ '\n'+traceback.format_exc())
finally:
  exit(0)