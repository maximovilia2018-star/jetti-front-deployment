#!/usr/bin/env python3
import sys
import time
import traceback
import firebase_admin
from firebase_admin import credentials, firestore

try:
    arg_names = ['command', 'json_cert', 'dlimit']
    args = dict(zip(arg_names, sys.argv))

    if 'dlimit' in args:
        dlimit=int(args['dlimit'])
    else:
        dlimit=1000

    d1=time.time()

    cred = credentials.Certificate(args['json_cert'])
    firebase_admin.initialize_app(cred)
    firestore_db = firestore.client()
    snapshots = list(firestore_db.collection(u'Employee').limit(dlimit).order_by('FullName').get())
    d2=time.time()

    print(round((d2-d1)*1000))

except Exception as e:
    print(str(e)+ '\n'+traceback.format_exc())
    exit(3)