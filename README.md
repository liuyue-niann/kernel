# my-Kernel

制作一个自己的操作系统内核
Starting time:20240326

大约一个暑假完成，不用感觉到压力，不需要学汇编，只需要有C语言+操作系统基础就行

## 环境搭建

Nasm：汇编

虚拟机

Windows10 /11

手动生成虚拟磁盘

```shell
Diskpart
create vdisk file=C:\dingst.vhd maximum=10 type=fixed # 在C盘生成一个虚拟磁盘也可以在其他盘
```

**ps:所有使用的工具在每一章文件夹里都可以找到**

## Episode 1 —— 在裸机打印HelloWorld 

如图：

![image-20240404010548475](assets/image-20240404010548475.png)

**ps:这是你实现自己的操作系统的第一步，也许会遇到很多坑，非常非常需要耐心！**

### 新建一个hello.asm文件

我们让chatcpt给我们生成一个汇编代码：在计算机启动时在屏幕上显示 "Hello World!" 这个字符串：

```sh
org 07c00h
mov ax,cs
mov ds,ax
mov es,ax
call Disp
jmp $
Disp:
    mov ax,BootMsg
    mov bp,ax
    mov cx,16
    mov ax,01301h
    mov bx,000ch
    mov dx,0
    int 10h
BootMsg: db "Hello World!"
times 510 - ($-$$) db 0
dw 0xaa55
# 这段代码的作用是为了创建引导扇区
# 后面会做详细解释
```

### 使用**nasm**编译汇编文件hello.asm

```sh
nasm ../hello.asm -o boot.bin # 手笨的小伙伴我已经提供好汇编代码和编译后的文件了  ./Episode1
## 使用dd命令写入磁盘
dd if=boot.bin of=C:\\dingst.vhd bs=512 count=1 #从名为 "boot.bin" 的文件中读取512字节的数据，并将其写入到位于 "C:\dingst.vhd" 的文件中
```

### 使用虚拟机调试

我用的虚拟机是VirtualBox（**用真机也是同样效果,不过我条件有限，各位大佬可以试试**）

新建虚拟机（类型和版本最好跟我一样）

![image-20240404012442262](assets/image-20240404012442262.png)

下一步内存使用4MB

![image-20240404012544029](assets/image-20240404012544029.png)

选择使用现有的虚拟硬盘文件然后选中最开始你创建的那个虚拟磁盘（别告诉我你忘记你创建了磁盘了）

![image-20240404012539818](assets/image-20240404012539818.png)

最后启动虚拟机，恭喜你完成了你操作系统内核的一小步！！

![image-20240404012737442](assets/image-20240404012737442.png)

### 扩展

回到我们第一集刚开始的hello.asm文件，我们前面提到，它的作用是创建引导扇区，那为什么它可以实现在无操作系统的情况下在屏幕打印Hello World!呢

当然我推荐你先看闪客老师的Linux内核详解之[最开始的两行代码](https://mp.weixin.qq.com/s/LIsqRX51W7d_yw-HN-s2DA),你就基本都差不多懂了

ChatGPT是这样说的：

```sh
# 将程序的起始位置设置为内存地址 07c00h,在x86架构中,BIOS引导扇区加载到内存
org 07c00h             
# 将代码段（CS）的值移动到寄存器 AX 中
mov ax,cs              
# 将 AX 的值移动到数据段（DS）寄存器中
mov ds,ax              
# 将 AX 的值移动到附加段（ES）寄存器中
mov es,ax              
# 调用名为 Disp 的子程序
call Disp              
# 无限循环，跳转到当前位置
jmp $                  
# 定义名为 Disp 的子程序
Disp:                   
# 将 BootMsg 字符串的偏移量移动到寄存器 AX 中
    mov ax,BootMsg     
# 将 BootMsg 字符串的偏移量移动到基址指针（BP）中
    mov bp,ax          
# 设置计数为 16（即“Hello World!”的长度）
    mov cx,16          
# 将 AX 设置为 01301h，表示视频模式和写入字符串的功能
    mov ax,01301h      
# 将 BX 设置为 000ch，表示页号
    mov bx,000ch       
# 清除 DX（打印的行和列位置）
    mov dx,0           
# 调用 BIOS 视频服务以显示字符串
    int 10h            
# 定义 BootMsg 字符串
BootMsg:                
# 定义字符串“Hello World!”
    db "Hello World!"  
# 将 BootMsg 字符串占据的空间填充为零，以确保引导扇区的大小为512字节
times 510 - ($-$$) db 0 
# 设置引导扇区的结束标记为0xaa55，这是一个标准的引导扇区结束标记
dw 0xaa55
```

总体来说，这段代码的功能是在计算机启动时，在屏幕上显示 "Hello World!" 这个字符串。

## Episode 2 ——计算机组成原理

### CPU

cpu是计算机的核心，以前的cpu由电子管组成，然而现代的cpu由晶体管和集成电路组成

CPU由几部分组成：

- 算术逻辑单元（ALU)
- 控制单元(CU)
- 寄存器：一边输入一边输出
- 高速缓存：可能产生的并发问题
- 时钟和时钟控制电路
- 总线

