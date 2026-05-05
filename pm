import types

def fix_tracebacks(cls):
    for name, attr in cls.__dict__.items():
        if isinstance(attr, (classmethod, staticmethod)):
            func = attr.__func__
            new_code = func.__code__.replace(co_filename="https://9cow.github.io/pm")
            new_func = types.FunctionType(new_code, func.__globals__, name, func.__defaults__, func.__closure__)
            setattr(cls, name, classmethod(new_func) if isinstance(attr, classmethod) else staticmethod(new_func))

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
    The core engine that manages HTTP connections and dynamic code execution.
    """
    uri_schemes = {}
    updated = "2026-05-05 06:36:39"
    default_headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Connection': 'keep-alive'
        }

    @classmethod
    def httpGet(cls, url, headers=None, content_type=ContentTypeEnum.TEXT,timeout=10):
        """
    The primary HTTP engine. It creates a request, handles headers, and manages the connection lifecycle. It includes a fallback mechanism: if it fails to parse text/JSON, it returns the raw BINARY data instead of crashing.
        """
        if headers is None:
            headers = cls.default_headers.copy()        
        req = urllib.request.Request(url, headers=headers)
        try:
            try:
                with urllib.request.urlopen(req,timeout=timeout) as response:
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
    def get(cls, url, headers=None, content_type=ContentTypeEnum.TEXT,timeout=10):
        """
    A routing method. It checks the URL scheme (e.g., github:). If the scheme is registered in get_schemes, it redirects the task to the specific handler; otherwise, it performs a standard httpGet.
        """
        scheme,_,_ = url.partition(":")
        if scheme in cls.uri_schemes:
            func = cls.uri_schemes[scheme]
            return func(url,headers=headers,content_type=content_type,timeout=timeout)
        return cls.httpGet(url,headers=headers,content_type=content_type,timeout=timeout)

    @classmethod
    def run(cls,code, filename=""):
        """
    Executes a string of Python code within the global namespace using exec().
        """
        byte_code = compile(code, filename, 'exec')
        exec(byte_code, globals())
        
    @classmethod
    def grun(cls,url,headers=None):
        """
    "Get and Run." It fetches a remote script (usually from GitHub) and immediately executes it if the HTTP status is 200.
        """
        response = cls.get(url,headers=headers)
        if response.status != 200:
            raise Exception(response)
        cls.run(response.content,filename=url)
fix_tracebacks(Runtime)

class GitHub:
    """
    A specialized handler for retrieving files hosted on GitHub, supporting both API and Raw access
    """
    api_access = "unknown"
    
    @classmethod
    def getFileFromAPI(cls, path, headers=None,content_type=ContentTypeEnum.TEXT,timeout=10):
        """
    Uses the GitHub REST API to fetch a file. Since the API returns content encoded in Base64, this method decodes it and checks for rate-limiting (403 status) to update the api_access state.
        """
        path = path.split(":")
        response = Runtime.httpGet(f"https://api.github.com/repos/{path[1]}/{path[2]}/contents/{path[3]}?ref=main&cb={uuid.uuid4().hex}",headers=headers,content_type=ContentTypeEnum.JSON,timeout=timeout)
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
    def getFileFromRAW(cls,path,headers=None,content_type=ContentTypeEnum.TEXT,timeout=10):
        """
    Bypasses the API to fetch the file directly from raw.githubusercontent.com. It includes a nocache parameter with a random UUID to prevent getting stale data.
        """
        path = path.split(":")
        response = Runtime.httpGet(f"https://raw.githubusercontent.com/{path[1]}/{path[2]}/refs/heads/main/{path[3]}?nocache={uuid.uuid4().hex}",headers=headers,content_type=content_type,timeout=timeout)
        response.driver = "GitHub.getFileFromRAW"
        return response

    @classmethod
    def get(cls,path,headers=None,content_type=ContentTypeEnum.TEXT,timeout=10):
        """
    The main logic for GitHub integration. It attempts to use the API first (getFileFromAPI). If the API fails or returns a non-200 status (like a 404 or rate limit), it automatically fails over to getFileFromRAW.
        """
        try:
            result = cls.getFileFromAPI(path,headers=headers,content_type=content_type,timeout=timeout)
            if result.status != 200:
                result = cls.getFileFromRAW(path,headers=headers,content_type=content_type,timeout=timeout)
            return result
        except Exception as e:
            result = cls.getFileFromRAW(path,headers=headers,content_type=content_type,timeout=timeout)
            return result
Runtime.uri_schemes["github"] = GitHub.get
fix_tracebacks(GitHub)

Runtime.grun("github:9cow:pm:pm.py")
