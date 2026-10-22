"""Exercise the configured rest.nvim against a local HTTP server.

Run: python tests/rest_smoke.py [--nvim /path/to/nvim]
Uses only Python's standard library and the installed Neovim configuration.
"""
import argparse
import http.server
import json
import os
from pathlib import Path
import subprocess
import tempfile
import threading


class Echo(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.reply("")

    def do_POST(self):
        self.reply(self.rfile.read(int(self.headers.get("Content-Length", 0))).decode())

    def reply(self, body):
        payload = json.dumps({"method": self.command, "path": self.path, "body": body}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, *args):
        pass


LUA = r'''
local root = vim.env.NVIM_REST_TEST
local ok, err = pcall(function()
  vim.cmd.cd(root)
  vim.cmd.edit('requests.http')
  local source = vim.api.nvim_get_current_buf()
  assert(vim.fn.exists(':Rest') == 2, 'Rest command missing')
  for name, dep in pairs(vim.g.rest_nvim_deps) do
    assert(dep.found, 'Missing dependency: ' .. name)
  end
  local response
  vim.api.nvim_create_autocmd('User', {pattern='RestResponse', callback=function()
    response = vim.deepcopy(_G.rest_response)
  end})
  local cases = {
    {line=1, method='GET', path='/get?value=portable', body=''},
    {line=4, method='POST', path='/json', body='{"hello":"world"}'},
    {line=10, method='POST', path='/xml', body='<hello>world</hello>'},
    {line=16, method='POST', path='/file', body='external body'},
  }
  for _, case in ipairs(cases) do
    vim.api.nvim_set_current_buf(source)
    vim.b._rest_nvim_env_file = root .. '/.env'
    vim.api.nvim_win_set_cursor(0, {case.line, 0})
    response = nil
    vim.cmd('Rest run')
    assert(vim.wait(15000, function() return response ~= nil end, 25), 'Response timed out: ' .. case.path)
    assert(response.status.code == 200, vim.inspect(response.status))
    local data = vim.json.decode(response.body)
    assert(data.method == case.method, vim.inspect(data))
    assert(data.path == case.path, vim.inspect(data))
    assert(data.body:gsub('%s+$', '') == case.body, vim.inspect(data))
    print('PASS ' .. case.method .. ' ' .. case.path)
    vim.wait(100)
  end
end)
if not ok then
  io.stderr:write(tostring(err) .. '\n')
  vim.cmd('cquit 1')
else
  vim.cmd('qa!')
end
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--nvim", default="nvim")
    args = parser.parse_args()
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Echo)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        with tempfile.TemporaryDirectory(prefix="nvim-rest-smoke-") as directory:
            root = Path(directory)
            port = server.server_address[1]
            (root / ".env").write_text("VALUE=portable\n", encoding="utf-8")
            (root / "body.txt").write_text("external body", encoding="utf-8")
            (root / "requests.http").write_text(
                f"GET http://127.0.0.1:{port}/get?value={{{{VALUE}}}}\n\n###\n"
                f"POST http://127.0.0.1:{port}/json\nContent-Type: application/json\n\n"
                '{"hello":"world"}\n\n###\n'
                f"POST http://127.0.0.1:{port}/xml\nContent-Type: application/xml\n\n"
                "<hello>world</hello>\n\n###\n"
                f"POST http://127.0.0.1:{port}/file\nContent-Type: text/plain\n\n< ./body.txt\n",
                encoding="utf-8")
            (root / "verify.lua").write_text(LUA, encoding="utf-8")
            env = os.environ.copy()
            env.update(NVIM_REST_TEST=root.as_posix(), NO_PROXY="127.0.0.1,localhost")
            subprocess.run([args.nvim, "--headless", "-n", "--cmd", "let g:coc_start_at_startup=0",
                            "+lua dofile(vim.env.NVIM_REST_TEST .. '/verify.lua')"],
                           env=env, check=True, timeout=90)
    finally:
        server.shutdown()


if __name__ == "__main__":
    main()
