class Employee:
    'All Employee'
    empcount = 0
    
    def __init__(self, name, salary):
        self.name = name
        self.salary = salary
        Employee.empcount += 1
    
    def displayCount(self):
        print("Total Employee %d"% Employee.empcount)
        
    def displayEmployee(self):
        print("Name: ", self.name, "Salary: ", self.salary)
    def __delattr__(self):  
        print("delete succed")
class a(Employee):
    '''Child Employee'''
    def __init__(self, name):
        print(self)
        
    def add(self, a, b):
        self.a = a
        self.b = b
        self.__jj()
        return a+b
    def __jj(self):
        
        print('abcdefg')
        
        
print("__doc__", Employee.__doc__)
print("__name__", Employee.__name__)
print("__module__", Employee.__module__)
print("__base__", Employee.__base__)
print("__dict__", Employee.__dict__)
print("*****%d",Employee.displayCount)
emp = Employee("zhangsan", 200)
b = a('wangwu')
c = b.add(1,2)


print(c)
del emp