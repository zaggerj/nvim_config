import vim as v
#import arrow
import re

(cancel, doing, done, todo) = v.eval("g:todo_symbols").values()

"""
current.buffer 不能全局保存，否则会导致无法切换到真正的 current buffer
"""

def getSpaces(raw):
    """获取每个项目前面的空格数量"""
    spaces = 0
    for ch in raw:
        if ch.isspace():
            spaces += 1
        else:
            return spaces


class Item:
    """对每一个待办条目进行抽象"""

    def __init__(self):
        # 注意索引和实际行数不同
        self.line:int = v.current.window.cursor[0] - 1
        self.raw:str = v.current.line
        self.indentLevel:int = 0
        self.state:str = ""
        self.body:str = ""
        self.time = {}
        self.parse()

    def parse(self):
        """进行基本的条目解析

        Args: 
            none
        """
        pointer = getSpaces(self.raw)
        self.indentLevel = int(pointer / 2)
        # 当前非空的字符视作状态字符
        self.state = self.raw[pointer]
        # 剩下的全部作为主体
        self.body = self.raw[pointer+1:]
        # 时间单独解析
        try:
            dur = self.time
            dur.setdefault("start", re.findall("@start\((.*?)\)", desc)[0])
            dur.setdefault("end", re.findall("@end\((.*?)\)", desc)[0])
            dur.setdefault("due", re.findall("@due\((.*?)\)", desc)[0])
            dur.setdefault("use", re.findall("@use\((.*?)\)", desc)[0])
        except Exception as e:
            pass
        return self
    
    def renew(self):
        buffer = v.current.buffer
        buffer[self.line] = str(self)

    def toggleDone(self):
        """切换待办和完成间的状态"""
        self.state = todo if self.state in [cancel, done] else done
        self.renew()
        return self

    def toggleCancel(self):
        self.state = cancel if self.state in [todo, done, doing] else todo
        self.renew()
        return self

    def toggleStart(self):
        self.state = doing if self.state == todo else todo
        self.renew()
        return self

    def renewProject(self):
        """获取所在的 Project

        向上查找，使用正则进行匹配
        """
        buffer = v.current.buffer
        # 向上查找，包括当前的
        curr = self.line
        pstates = {"todo": 0, "total": 0}
        while curr >= 0:
            if buffer[curr].endswith(":"):
                break
            if todo in buffer[curr]:
                pstates['todo'] += 1
            pstates['total'] += 1
            curr -= 1
        
        # 向下查找，跳过当前的
        proj = buffer[curr]
        curr = self.line + 1
        while curr < len(buffer):
            # 有可能是空行，也有可能是子项目
            if buffer[curr] == "" or buffer[curr].endswith(":"):
                break
            if todo in buffer[curr]:
                pstates['todo'] += 1
            pstates['total'] += 1
            curr += 1
        return proj, pstates

    def __str__(self):
        return f"{'  ' * self.indentLevel}{self.state}{self.body}"

