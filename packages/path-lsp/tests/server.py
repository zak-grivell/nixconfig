"""Minimal stdio LSP server for path-lsp integration tests."""
import json
import os
import sys

while True:
    headers = {}
    while line := sys.stdin.buffer.readline():
        if line == b"\r\n":
            break
        key, value = line.decode().split(":", 1)
        headers[key.lower()] = value.strip()
    if not headers:
        break
    message = json.loads(sys.stdin.buffer.read(int(headers["content-length"])))
    if os.environ.get("PATH_LSP_LOG"):
        with open(os.environ["PATH_LSP_LOG"], "a") as log:
            log.write(json.dumps(message) + "\n")
    if message.get("method") == "exit":
        break
    if "id" not in message:
        continue
    result = None
    if message.get("method") == "initialize":
        result = {"capabilities": {
            "textDocumentSync": 1,
            "hoverProvider": True,
            "documentHighlightProvider": True,
            "signatureHelpProvider": {"triggerCharacters": ["(", ","]},
        }}
    elif message.get("method") == "textDocument/documentHighlight":
        result = []
    elif message.get("method") == "textDocument/signatureHelp":
        result = {"signatures": [{"label": "test(value)", "parameters": [{"label": "value"}]}]}
    response = json.dumps({"jsonrpc": "2.0", "id": message["id"], "result": result}).encode()
    sys.stdout.buffer.write(f"Content-Length: {len(response)}\r\n\r\n".encode() + response)
    sys.stdout.buffer.flush()
