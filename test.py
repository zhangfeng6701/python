#!utf-8
import os
a = 1
"""
if a == 1:
    print('setp 1')
elif a == 3:
    print('setp 2')
else:
    print('end')
 

if a is not None:
    print('is not None')
   

for a in range(20):
    print(a)
  """
for x in range(5,20,3):
    print(x)
else:
    print('over')
    
while True:
    print(1)
    break
    
def fa():
    print('function')
    

def printime(str):
    '''printime''' 
    print(str)
    

abc ='abcd'
printime('abc')

def printinfo(arg1, *vartuple):
    print('XXX',arg1)
    for var in vartuple:
        print(var)
    return;

printinfo(70,60,100)


fl = lambda a, a1: a1+a

print(fl(1,2))

def bb(a):
    def bb1(b):
        return(a+b)
    return(bb1)
q = bb(20)
p = bb(10)
print(q)
print(p)
print(q(2))
print(p(4))



testList = [x for x in range(10)]
testList.append('a')
testList.extend(abc)



aa =(1,2,3)
testList.append(aa)
print(aa)
print(testList)

b=os.walk('.')
dir(b)

def fab(max):
    n,a,b = 0,0,1
    while n < max:
        print(b)
        a,b = b, a+b
        n = n + 1
        
fab(10)