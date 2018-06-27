class Parent:
    'Parent Class ...'
    parentAttr = 100
    
    def __init__(self):
        print("Parent")
        
    def parentMethod(self):
        print("ParentMethod")
        
    def setAttr(self, attr):
        Parent.parentAttr = attr
        
    def getAttr(self):
        print("Parent", Parent.parentAttr)
        
class Child(Parent):
    'Child Class ...'
    def __init__(self):
        print("Child ")
        
    def childMethod(self):
        print("Child Method")
        
    


for a in range(0,20,3):
    print(a)
else:
    print("over")
    
print(eval('3,3'))