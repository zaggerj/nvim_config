"""Migrate actual upstream SQLite schema without mutating or overwriting user data."""
import hashlib
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile


def main():
 with tempfile.TemporaryDirectory(prefix='nvim-legacy-') as directory:
  root=Path(directory); source=root/'legacy.sqlite3'; target=root/'palette'/'usage.json'
  with sqlite3.connect(source) as db:
   db.executescript('CREATE TABLE item_count(id INTEGER PRIMARY KEY,item_id TEXT,count INTEGER); CREATE TABLE timestamps(id INTEGER PRIMARY KEY,item_id TEXT,timestamp REAL);')
   db.execute('INSERT INTO item_count VALUES(1,?,9)',(':Lazy 打开插件管理器',))
   db.execute('INSERT INTO timestamps VALUES(1,?,2440587.5+1000.0/86400)',(':Lazy 打开插件管理器',))
   db.execute('INSERT INTO item_count VALUES(2,?,3)',('unmapped original id',))
  db.close()
  digest=hashlib.sha256(source.read_bytes()).hexdigest()
  command=[sys.executable,str(Path(__file__).resolve().parents[1]/'scripts/import_palette_history.py'),'--source',str(source),'--target',str(target)]
  result=subprocess.run(command,capture_output=True,text=True,encoding='utf-8',timeout=10)
  assert result.returncode==0,result.stderr
  usage=json.loads(target.read_text(encoding='utf-8'))
  assert usage['Lazy']['count']==9 and abs(usage['Lazy']['timestamps'][0]-1000)<=1
  assert 'unmapped original id' in json.loads(target.with_name('legacy-unmapped.json').read_text(encoding='utf-8'))
  assert hashlib.sha256(source.read_bytes()).hexdigest()==digest
  result=subprocess.run(command,capture_output=True,text=True,encoding='utf-8',timeout=10)
  assert result.returncode!=0 and json.loads(target.read_text(encoding='utf-8'))==usage
  print('PASS legacy usage import, unknown-record preservation and overwrite refusal')

if __name__=='__main__':main()
