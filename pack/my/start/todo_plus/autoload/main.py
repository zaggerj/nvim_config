#import vim as v
#import arrow

class Item():
    def __init__(self, raw:str):
        self.raw = raw 
        self.indentLevel = 2
        self.state = ""
        self.duration = {
                "start": "",
                "end": "",
                "use":""
                }
        
    def parse(self):
        for ch in self.raw:
            if ch.isspace():
                self.indentLevel+= 1
            else:
                self.indentLevel = int(self.indentLevel / 2)
                break
        return self

    def __str__(self):
        return f"{' ' * self.indentLevel}"

desc = "  □ 项目一 @High"
print(Item(desc).parse())
