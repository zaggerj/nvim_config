"""显式、只读导入 Legendary SQLite 使用记录；不在编辑启动时执行 Python。"""
import argparse
from contextlib import closing
import json
from pathlib import Path
import sqlite3

CUSTOM = {
    ':Lazy 打开插件管理器': 'Lazy', ':Lazy sync 同步插件': 'Lazy sync',
    ':Lazy update 更新插件': 'Lazy update', ':NvimTreeFindFileToggle 切换文件树': 'NvimTreeFindFileToggle',
    ':Vista!! 切换代码大纲': 'Vista!!', ':Tutor zh 启动中文教程': 'Tutor zh',
    ':Tutor 启动英文教程': 'Tutor en',
}


def migrate(source, target, mapping):
    if target.exists():
        raise FileExistsError('目标已存在，禁止覆盖或重复累加：' + str(target))
    usage, unmapped = {}, {}
    with closing(sqlite3.connect(source.resolve().as_uri() + '?mode=ro', uri=True)) as db:
        for item_id, count in db.execute('SELECT item_id, count FROM item_count'):
            # Legendary 用 julianday('now') 写入 UTC 时间。
            timestamps = [int((row[0] - 2440587.5) * 86400)
                          for row in db.execute('SELECT timestamp FROM timestamps WHERE item_id=? ORDER BY timestamp', (item_id,))]
            entry = {'count': count, 'timestamps': timestamps[-10:]}
            if item_id in mapping:
                command = mapping[item_id]
                previous = usage.get(command, {'count': 0, 'timestamps': []})
                usage[command] = {'count': previous['count'] + count,
                                  'timestamps': sorted(previous['timestamps'] + timestamps)[-10:]}
            else:
                unmapped[item_id] = entry
    target.parent.mkdir(parents=True, exist_ok=True)
    # 完整保留非命令/未知项，不猜测包含空格的命令与描述边界。
    archive = target.with_name('legacy-unmapped.json')
    if archive.exists():
        raise FileExistsError('归档目标已存在：' + str(archive))
    archive.write_text(json.dumps(unmapped, ensure_ascii=False, indent=2), encoding='utf-8')
    target.write_text(json.dumps(usage, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'已导入 {len(usage)} 项命令，归档 {len(unmapped)} 项；原 SQLite 保留：{source}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--target', required=True, type=Path, help='stdpath(data)/command-palette/usage.json')
    parser.add_argument('--mapping', type=Path, help='额外 item_id 到命令字符串的 JSON 映射')
    args = parser.parse_args()
    mapping = dict(CUSTOM)
    if args.mapping:
        mapping.update(json.loads(args.mapping.read_text(encoding='utf-8')))
    migrate(args.source, args.target, mapping)


if __name__ == '__main__':
    main()
