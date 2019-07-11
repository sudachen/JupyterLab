# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import errno
import stat

c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.token = ''
c.FileContentsManager.delete_to_trash = False
c.NotebookApp.notebook_dir = '/lab/work'
c.NotebookApp.allow_origin = 'https://colab.research.google.com'
c.NotebookApp.disable_check_xsrf = True

if os.environ.get('GITHUB_ACCESS_TOKEN','NONE') != 'NONE':
    c.GitHubConfig.access_token = os.environ['GITHUB_ACCESS_TOKEN']

try:
    c.NotebookApp.iopub_data_rate_limit=100000000
except:
    pass

try:
    a = c.TerminalIPythonApp.extensions
    if 'line_profiler' not in a:
        a = a + ['line_profiler']
    if 'memory_profiler' not in a:
        a = a + ['memory_profiler']
    c.TerminalIPythonApp.extensions = a
except:
    pass
