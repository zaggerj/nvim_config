"""
Author: LinHQ1999
License: MIT
Description: todoplus.vim 核心工具
"""

import vim as v
import arrow
import re

(cancel, doing, done, todo) = v.eval("g:todo_symbols").values()

"""
current.buffer 不能全局保存，
否则会导致无法切换到真正的 current buffer，
应当总是在函数调用时请求 current buffer
"""

def getSpaces(raw):
    """获取每个项目前面的空格数量"""
    spaces = 0
    for ch in raw:
        if ch.isspace():
            spaces += 1
        else:
            return spaces

def parseProject(raw:str):
    """解析 project 字符串"""
    spaces = getSpaces(raw)
    if "(" in raw:
        return (spaces, raw[spaces:raw.index("(")])
    else:
        return (spaces, raw[spaces:raw.index(":")])


class Item:
    """对每一个待办条目进行抽象"""

    timeformat = v.eval("g:todo_timeformat")

    def __init__(self):
        # 注意索引和实际行数不同
        self.line:int = v.current.window.cursor[0] - 1
        self.raw:str = v.current.line
        self.indentLevel:int = 0
        self.state:str = ""
        self.body:str = ""
        self.time = {}
        self.tags = []
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
        # 剩下的至时间标记全部作为主体，时间标记总是在最后
        if '@start(' in self.raw:
            self.body = self.raw[pointer+1:self.raw.index(" @start(")]
        else:
            self.body = self.raw[pointer+1:]

        # 去除尾部多余的空白字符，否则后面附加的时间标签可能会间隔很远
        self.body = self.body.rstrip()
        # 时间单独解析
        try:
            dur = self.time
            dur.setdefault("start", re.findall("@start\((.*?)\)", self.raw)[0])
            dur.setdefault("end", re.findall("@end\((.*?)\)", self.raw)[0])
            dur.setdefault("use", re.findall("@use\((.*?)\)", self.raw)[0])
        except Exception as e:
            pass
        # 标签单独解析
        self.tags = re.findall(r"@.+?\b", self.raw)
        return self
    
    def renew(self):
        buffer = v.current.buffer
        buffer[self.line] = str(self)
        self.renewProject()

    def toTodo(self):
        if self.state not in (cancel, doing, done, todo):
            self.body = f" {self.state}{self.body}"
            self.state = todo

        self.renew()
        return self

    def toggleDone(self):
        """切换待办和完成间的状态"""
        if self.state in [cancel, done]:
            self.state = todo 
            self.time = {}
        else:
            self.state = done
            # 没有 start 的话就不必计算了
            if "start" in self.time.keys():
                self.time['end'] = arrow.now().format(self.timeformat)
                use = arrow.get(self.time['end'], self.timeformat) - arrow.get(self.time['start'], self.timeformat)
                hour = use.seconds//3600
                minutes = use.seconds % 3600 // 60
                seconds = use.seconds % 60
                self.time['use'] = f"{hour}h {minutes}m {seconds}s"
        self.renew()
        return self

    def toggleCancel(self):
        self.state = cancel if self.state in [todo, done, doing] else todo
        self.time = {}
        self.renew()
        return self

    def toggleStart(self):
        if self.state in [todo, doing]:
            self.state = doing
            self.time['start'] = arrow.now().format(self.timeformat)
        else:
            self.state = todo
            self.time = {}
        self.renew()
        return self

    def renewProject(self):
        """获取所在的 Project

        向上查找，使用正则进行匹配
        """
        buffer = v.current.buffer
        # 向上查找，包括当前的
        curr = self.line
        pstates = {"done": 0, "total": 0}
        # 第 0 行总是 Project 
        while curr > 0:
            if buffer[curr].endswith(":"):
                break
            if done in buffer[curr]:
                pstates['done'] += 1
            elif cancel in buffer[curr]:
                # 取消部分不计入总数
                pstates['total'] -= 1

            pstates['total'] += 1
            curr -= 1
        
        proj = curr
        # 向下查找，跳过当前的
        curr = self.line + 1
        while curr < len(buffer):
            # 有可能是空行，也有可能是子项目，碰到就跳出
            if buffer[curr] == "" or buffer[curr].endswith(":"):
                break
            if done in buffer[curr]:
                pstates['done'] += 1
            elif cancel in buffer[curr]:
                # 取消部分不计入总数
                pstates['total'] -= 1

            pstates['total'] += 1
            curr += 1

        (spaces, body) = parseProject(buffer[proj])
        buffer[proj] = f"{' '*spaces}{body}({pstates['done']}/{pstates['total']}):"


    def __str__(self):
        # 更新时总是重新渲染时间使用情况，self.time 为空则清除
        timeinfo = " "
        for k, v in self.time.items():
            timeinfo += f"@{k}({v}) "

        return f"{'  ' * self.indentLevel}{self.state}{self.body}{timeinfo}"

