此目录下为生成DLL文件的源代码，编译方法2种如下

1. 在命令提示符下输入nmake

2. 在命令提示符下依次输入
```
ml /c /coff cpu_identity.asm
link /subsystem:windows /Dll /Def:cpu_identity.def cpu_identity.obj 
```
