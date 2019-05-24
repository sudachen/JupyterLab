from IPython import get_ipython
ip = get_ipython()

ip.magic('automagic off')
ip.magic('load_ext sql')
ip.magic('load_ext autoreload')
ip.magic('config SqlMagic.autopandas = True')

ip.run_cell('import matplotlib.pyplot as plt')
ip.run_cell('import numpy as np')
ip.run_cell('import pandas as pd')
ip.run_cell('import sys, os, os.path')

ip.run_cell('''
for k, v in os.environ.items():
    if k.endswith('_CONN'):
       globals()[k.upper()] = v
''')

ip.run_cell(''' 
import warnings
warnings.filterwarnings("ignore",category=FutureWarning)
''')

if getattr(sys,'pypy_version_info',None) is None:
    ip.magic('matplotlib inline')
else:
    os.environ['PATH'] = '/opt/pypy/bin:'+os.environ['PATH']

