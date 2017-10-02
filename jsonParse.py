
# coding: utf-8

import requests

url = "https://reddit.com/r/earthPorn/.json"

r = requests.get(url=url)
datas = r.json()
print(datas)

for data in datas['data']['children']:
    title = data['data']['title']
    images = data['data']['preview']['images']
    print("-----------------------")
    print(title)
    for image in images:
        print(image['source']['url'])
    print("-----------------------")

