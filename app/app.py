import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def response_for(path):
    if path == "/":
        return 200, {
            "application": "project-everest",
            "version": "1.0.0",
            "status": "running",
        }

    if path == "/healthz":
        return 200, {
            "status": "healthy",
        }

    return 404, {
        "error": "not found",
    }


class EverestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        status_code, payload = response_for(self.path)
        body = json.dumps(payload).encode("utf-8")

        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format_string, *args):
        print(f"[HTTP] {self.address_string()} - {format_string % args}")


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 8080), EverestHandler)
    print("Project Everest application listening on port 8080")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down Project Everest application")
    finally:
        server.server_close()
