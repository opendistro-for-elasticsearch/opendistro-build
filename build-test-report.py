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
    payload = req.json()
    latest_job_run = payload['workflow_runs'][0]
    job_run_id = latest_job_run['id']

    job_details_url = 'https://api.github.com/repos/opendistro-for-elasticsearch/opendistro-build/actions/runs/' + \
                      str(job_run_id) + '/jobs'
    job_req = requests.get(url=job_details_url, auth=('rishabh6788', 'ad177e31e186d04be441ac7f351d09bc72abe0aa'))
    all_jobs = job_req.json()

    strTable = strTable + """<html><table border="1" width=50% >
                    <tr><th>Job Name</th><th>Status</th><th>Logs</th></tr>"""
    for jobs in all_jobs['jobs']:
        if jobs['conclusion'].upper() != 'SUCCESS':
            strRW = "<tr><td>" + jobs['name'] + """</td><td bgcolor="red">""" + jobs['conclusion'].upper() + "</td><td>" + jobs['html_url'] + "</td></tr>"
        else:
            strRW = "<tr><td>" + jobs['name'] + """</td><td bgcolor="green">""" + jobs['conclusion'].upper() + "</td><td>" + jobs['html_url'] + "</td></tr>"
        strTable = strTable + strRW
    strTable = strTable + """<tr><td>Test SQL Plugin</td><td bgcolor="yellow">Test Not Available</td><td>Not Available</td></tr>
                  <tr><td>Test Job Scheduler Plugin</td><td bgcolor="yellow">Test Not Available</td><td>Not Available</td></tr>
                  <tr><td>Test Performance Analyzer Plugin</td><td bgcolor="yellow">Test Not Available</td><td>Not Available</td></tr>
                  <tr><td>Test Security Plugin</td><td bgcolor="yellow">Test Not Available</td><td>Not Available</td></tr>
                  <tr><td>Test kNN Plugin</td><td bgcolor="yellow">Test Not Available</td><td>Not Available</td></tr>
               """
    strTable = strTable+"</table></html>"

    with open('report.html', 'a') as file:
        file.write(strTable)

print(report.html)
