import re
src = open(r'C:\Users\Administrator\Desktop\Vibe\cdrx4-typesetting\src\LanyaTagPack.bas', encoding='utf-8').read()
lines = src.splitlines()

def count(pat):
    return sum(1 for l in lines if re.search(pat, l))

subs = count(r'\b(Public |Private )?Sub\s+\w+')
endsub = count(r'\bEnd Sub\b')
funcs = count(r'\b(Public |Private )?Function\s+\w+')
endfunc = count(r'\bEnd Function\b')
ifs = count(r'\bIf\b')
endif = count(r'\bEnd If\b')
fors = count(r'\bFor\b')
nexts = count(r'\bNext\b')
print('Sub:', subs, 'EndSub:', endsub)
print('Function:', funcs, 'EndFunction:', endfunc)
print('If:', ifs, 'EndIf:', endif)
print('For:', fors, 'Next:', nexts)

# 括号配对（去字符串）
no_str = re.sub(r'"[^"]*"', '""', src)
no_str = re.sub(r"'.*$", '', no_str, flags=re.M)
print('括号差 ( - ) :', no_str.count('(') - no_str.count(')'))

# VBA7 语法扫描
print('PtrSafe:', src.count('PtrSafe'), 'LongPtr:', src.count('LongPtr'))

# 公开宏列表
for l in lines:
    m = re.match(r'Public Sub (\w+)', l)
    if m:
        print('PUBLIC MACRO:', m.group(1))
