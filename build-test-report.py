import requests
import sys

userName = sys.argv[1]
token = sys.argv[2]
urls = {
    "Docker Build and Test": "https://api.github.com/repos/opendistro-for-elasticsearch/opendistro-build/actions/workflows/305581/runs",
    "Debian Build and Test": "https://api.github.com/repos/opendistro-for-elasticsearch/opendistro-build/actions/workflows/373192/runs",
    "TAR Build and Test": "https://api.github.com/repos/opendistro-for-elasticsearch/opendistro-build/actions/workflows/373191/runs"
       }

for keys in urls:
    strTable = "<h2>" + keys + "</h2>"
    req = requests.get(url=urls[keys], auth=(userName, token))
    print(req.status_code)
