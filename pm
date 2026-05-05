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
    get_schemes = {}
    updated = "2026-05-04 20:58:01"
    default_headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Connection': 'keep-alive'
        }

    @classmethod
    def httpGet(cls, url, headers=None, content_type=ContentTypeEnum.TEXT):
        if headers is None:
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
            result.driver = "Runtime.httpGet"
            result.content_type = content_type
            result.status = status_code
            if content_type == ContentTypeEnum.BINARY:
                result.content = raw_data
            elif content_type == ContentTypeEnum.NONE:
                result.content = None
            else:
                try:
                    charset = info.get_content_charset() or 'utf-8'
                    text_content = raw_data.decode(charset)
                    if content_type == ContentTypeEnum.JSON:
                        result.content = json.loads(text_content)
                    else:
                        result.content = text_content
                except Exception:
                    result.content_type = ContentTypeEnum.BINARY
                    result.content = raw_data
                    return result
            return result
        except Exception as e:
            raise e

    @classmethod
    def get(cls, url, headers=None, content_type=ContentTypeEnum.TEXT):
        scheme,_,_ = url.partition(":")
        if scheme in cls.get_schemes:
            func = cls.get_schemes[scheme]
            return func(url,headers=headers,content_type=content_type)
        return cls.httpGet(url,headers=headers,content_type=content_type)

class GitHub:
    api_access = "unknown"
    
    @classmethod
    def getFileFromAPI(cls, path, headers=None,content_type=ContentTypeEnum.TEXT):
        path = path.split(":")
        response = Runtime.httpGet(f"https://api.github.com/repos/{path[1]}/{path[2]}/contents/{path[3]}?ref=main&cb={uuid.uuid4().hex}",headers=headers,content_type=ContentTypeEnum.JSON)
        result = SimpleNamespace()
        result.driver = "GitHub.getFileFromAPI"
        result.content_type = content_type
        result.status = response.status
        if result.status != 403:
            cls.api_access = "yes"
        else:
            cls.api_access = "no"
        result.content = None
        if content_type != ContentTypeEnum.NONE:
            raw_data = base64.b64decode(response.content.get('content', ''))
            if content_type == ContentTypeEnum.BINARY:
                result.content = raw_data
            else:
                text_content = raw_data.decode('utf-8')
                if content_type == ContentTypeEnum.JSON:
                    result.content = json.loads(text_content)
                else:
                    result.content = text_content
        return result

    @classmethod
    def getFileFromRAW(cls,path,headers=None,content_type=ContentTypeEnum.TEXT):
        path = path.split(":")
        response = Runtime.httpGet(f"https://raw.githubusercontent.com/{path[1]}/{path[2]}/refs/heads/main/{path[3]}?nocache={uuid.uuid4().hex}",headers=headers,content_type=content_type)
        response.driver = "GitHub.getFileFromRAW"
        return response

    @classmethod
    def get(cls,path,headers=None,content_type=ContentTypeEnum.TEXT):
        try:
            result = cls.getFileFromAPI(path,headers=headers,content_type=content_type)
            if result.status != 200:
                result = cls.getFileFromRAW(path,headers=headers,content_type=content_type)
            return result
        except Exception as e:
            result = cls.getFileFromRAW(path,headers=headers,content_type=content_type)
            return result
            
Runtime.get_schemes["github"] = GitHub.get

print("Working!")
print(Runtime.get("github:9cow:pm:pm.help"))
print(Runtime.get("http://checkip.dyndns.org"))
