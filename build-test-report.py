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
    payload = req.json()
    latest_job_run = payload['workflow_runs'][0]
    job_run_id = latest_job_run['id']

    job_details_url = 'https://api.github.com/repos/opendistro-for-elasticsearch/opendistro-build/actions/runs/' + \
                      str(job_run_id) + '/jobs'
    job_req = requests.get(url=job_details_url, auth=(userName, token))
    all_jobs = job_req.json()

    strTable = strTable + """<html><table border="1" width=50% >
                    <tr><th>Job Name</th><th>Status</th><th>Logs</th></tr>"""
    for jobs in all_jobs['jobs']:
        print(jobs)
