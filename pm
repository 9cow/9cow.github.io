import urllib.request
import json
import base64
import uuid

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
  def force_ipv4(cls):
    old_getaddrinfo = socket.getaddrinfo
    def new_getaddrinfo(*args, **kwargs):
        res = old_getaddrinfo(*args, **kwargs)
        return [r for r in res if r[0] == socket.AF_INET]
    socket.getaddrinfo = new_getaddrinfo

  @classmethod
  def getFileFromAPI(cls,path):
    path = path.split("|")
    url = f"https://api.github.com/repos/{path[0]}/{path[1]}/contents/{path[2]}?ref=main&cb=uuid.uuid4().hex"
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Python-Urllib-db0bc')
    try:
        with urllib.request.urlopen(req, timeout=1) as response:
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
    cls.force_ipv4()
    if cls.api_access == "Restricted":
      return cls.getFileFromRAW(path)
    else:
      try:
        return cls.getFileFromAPI(path)
      except Exception as e:
        return cls.getFileFromRAW(path)

print("ver 0.98d")
Runtime.run(GitHub.getFile("db0bc|pm|pm.py"))
