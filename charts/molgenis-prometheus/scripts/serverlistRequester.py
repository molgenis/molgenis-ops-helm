from sys import argv
import json
import requests

urlAddress = 'serverlist.gcc.rug.nl'
urlUser = argv[1]
urlPwd = argv[2]
node_exporter_port = 9100
node_exporter_targets = []
blackbox_exporter_urls = []

def initiateConnection():
    url = f'https://{urlAddress}/api/v1/login'
    header = {'Content-Type': 'application/json'}
    json = {"username": f"{urlUser}", "password": f"{urlPwd}"}
    response = requests.post(url, headers=header, json=json)
    global token
    token = response.json()['token']

def retrieveServerlist():
    url = f'https://{urlAddress}/api/v2/molgenis_serverlist?q=monitoring==true&num=1000\
            &attrs=~id,description,comments,DTAP,DNS,DNS_alias'
    header = {'x-molgenis-token': '%s' % token}
    response = requests.get(url, headers=header)
    global serverlist
    serverlist = response.text

def iterateServerlist():
    serverlist_object = json.loads(serverlist)
    for record in serverlist_object['items']:
        try:
            if 'description' in record:
                tempProject = f"{record['description']}".replace("'", "").replace("\n", " ")
            else:
                tempProject = f"{record['comments']}".replace("'", "").replace("\n", " ")

            url = f"{record['DNS']}"
            if "molgenis.org" in url:
                url = "wiki.gcc.rug.nl"
            if url.startswith('https://'):
                url = url[8:]
            if url.startswith('http://'):
                url = url[7:]
            if url.find('/') > 0:
                url = url.split('/')[0]
            if url.find(':') > 0:
                url = url.split(':')[0]

            if 'backend' not in record['id']:
                node_exporter_targets.append(f"  - targets: ['{url}:{node_exporter_port}']")
                node_exporter_targets.append("    labels:")
                node_exporter_targets.append(f"      project: \'{tempProject}\'")
                node_exporter_targets.append(f"      type: '{record['DTAP']['type']}'")

            tempUrlStore = []
            tempUrlStore.append(f"{record['DNS']}")
            for item in record['DNS_alias']:
                tempUrlStore.append(f"{item['label']}")

            blackbox_exporter_urls.append(f"  - targets: {tempUrlStore}")
            blackbox_exporter_urls.append("    labels:")
            blackbox_exporter_urls.append(f"      project: \'{tempProject}\'")
            blackbox_exporter_urls.append(f"      type: '{record['DTAP']['type']}'")
            print('%s - added' % str(record['id']))
        except KeyError as e:
            print('%s - KeyError Exception: %s empty' % (str(record['id']), str(e)))
            continue

def writeToFile():
    with open('node-targets.yml', 'w') as outputFile:
        outputFile.write("\n".join(str(item) for item in node_exporter_targets))
    with open('blackbox-targets.yml', 'w') as outputFile:
        outputFile.write("\n".join(str(item) for item in blackbox_exporter_urls))

def closeConnection():
    url = f'https://{urlAddress}/api/v1/logout'
    header = {'x-molgenis-token': '%s' % token}
    response = requests.post(url, headers=header)
    print(response.status_code)


initiateConnection()
retrieveServerlist()
iterateServerlist()
writeToFile()
closeConnection()
