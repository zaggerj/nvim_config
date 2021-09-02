import vim as v
import arrow
import re

vbuffer, vwin = v.current.buffer, v.current.window

(cancel, doing, done, todo) = v.eval("g:todo_symbols").values()

class Item:
    """对每一个待办条目进行抽象"""

    def __init__(self):
        self.raw:str = v.current.line
        # 注意索引和实际行数不同
        self.line:int = vwin.cursor[0] - 1
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
        pointer = 0
        for ch in self.raw:
            if ch.isspace():
                self.indentLevel+= 1
                pointer += 1
            else:
                # 计算缩进等级
                self.indentLevel = int(self.indentLevel / 2)
                # 当前非空的字符视作状态字符
                self.state = ch
                # 剩下的全部作为主体
                self.body = self.raw[pointer+1:]
                break
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
    
    def toggleDone(self):
        """切换待办和完成间的状态"""
        if self.state in [cancel, done]:
            self.state = todo
        else:
            self.state = done
        vbuffer[self.line] = str(self)
        return self

    def toggleStart():
        pass

    def getProject(self):
        """获取所在的 Project

        向上查找，使用正则进行匹配
        """
        curr = self.line
        while curr >= 0:
            if vbuffer[curr].endswith(":"):
                break
            curr -= 1
        return curr

    def __str__(self):
        return f"{'  ' * self.indentLevel}{self.state}{self.body}"

