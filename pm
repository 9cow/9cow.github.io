import urllib.request
import json
import base64
import uuid
import urllib.request
import urllib.error
from types import SimpleNamespace
from enum import Enum, auto

class ContentTypeEnum(Enum):
    NONE = auto()
    TEXT = auto()
    JSON = auto()
    BINARY = auto()
    FAILED = auto()

class Runtime:
  """
  Manages common methods
  """
  get_extensions = {}
  updated = "2026-05-04 20:58:01"
  default_headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Connection': 'keep-alive'
    }

  @classmethod
  def httpGet(cls, url, headers=None,content_type=ContentTypeEnum.TEXT):
      """
      Gets content from a http/https url
      """
      if headers == None:
        headers = cls.default_headers.copy()
      req = urllib.request.Request(url, headers=headers)
      try:
          try:
              with urllib.request.urlopen(req) as response:
                  status_code = response.status
                  info = response.info()
                  raw_data = response.read()
          except urllib.error.HTTPError as e:
              status_code = e.code
              info = e.info()
              raw_data = e.read()
          result = SimpleNamespace()
          result.content_type = content_type
          result.status = status_code
          result.type = content_type
          if content_type == ContentTypeEnum.BINARY:
              result.content = raw_data
          elif content_type == ContentTypeEnum.NONE:
              result.content = None
          else:
              charset = info.get_content_charset() or 'utf-8'
              text_content = raw_data.decode(charset)
              if content_type == ContentTypeEnum.JSON:
                  result.content = json.loads(text_content)
              else:
                  result.content = text_content
          return result
      except Exception as e:
          raise e

class GitHub:
  """
  Manages GitHub file access
  """
  api_access = "Unknown"

  @classmethod
  def getFileFromAPI(cls, path, content_type=ContentTypeEnum.TEXT):
      """
      Retrives a file from github using GitHub API
      path must be "$user|$repo|$path"
      """
      path = path.split(":")
      request = Runtime.httpGet(f"https://api.github.com/repos/{path[1]}/{path[2]}/contents/{path[3]}?ref=main&cb={uuid.uuid4().hex}",content_type=ContentTypeEnum.JSON)
      if request.status == 200:  
          pass
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
    """
    Retrives a file from github using GitHub Raw Access
    path must be "$user|$repo|$path"
    """
    path = path.split("|")
    return Runtime.get(f"https://raw.githubusercontent.com/{path[0]}/{path[1]}/refs/heads/main/{path[2]}?nocache=uuid.uuid4().hex")
    
  @classmethod
  def getFile(cls,path):
    """
    Tries to retrieve a file from GitHub using GitHub API
    If it cannot use the API, it will use GitHub RAW access
    path must be "$user|$repo|$path"
    """
    try:
      result = cls.getFileFromAPI(path)
      if result.status != 403:
        return result
      new_result = cls.getFileFromRAW(path)
      new_result.previousStatus = result.status
      return new_result
    except Exception as e:
      return cls.getFileFromRAW(path)

x = Runtime.httpGet("http://checkip.dyndns.org")
print(x)
#Runtime.cowrun("github:9cow:pm:pm.py")
