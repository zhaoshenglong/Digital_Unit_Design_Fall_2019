# Digital_Unit_Design_Fall_2019
上海交大软件学院2019年秋季学期数字部件课程作业 

## Intro
这门课程感觉比较简单，老师人很好，非常平易近人，有任何问题都可以随意问。老师上课比较照顾女孩子，经常会点名女孩子回答问题，不过回答问题的氛围很轻松，所以不用担心~
这门课程的作业主要是用 `Quartus 13.1 Web Edition` 写 `verilog`，基本上就是4个lab + 机考 + 期末考试

1. [秒表 —— stop_watch](#stop_watch)
2. [单周期CPU —— sc_computer](#sc_computer)
3. [流水线CPU —— pipelined_computer](#pipelined_computer)
4. [VGA拓展I/O](#xxx)
5. [机考](#xxxx)

### 先整体讲一下这门课程吧

上课内容基本上就是 电路系统综合 + ICS 第四章， 所以课程难度不大的，主要是几个作业不熟悉的话刚开始可能会比较难受。

* 一来 Quartus 使用稍微比较复杂，不花点时间可能会有各种坑；
* 其二 还有另一个 modelsim仿真软件使用也很复杂，这个也是坑很多
* 再者 verilog 设计和我们熟悉的编程可能不太一样，verilog 硬件描述语言描述硬件的动作，所以不会像我们写代码时运行栈帧、PC、返回值这些概念可能都不太一样。

## 下面简单讲一下每一个lab的做法和难点吧

### My First FPGA
这个其实不算作业，可以用来熟悉一下 Quartus软件。<br/>
老师会给我们一个 `my_first_fpga` pdf文件，里面十分十分详细的手把手教我们用 Quartus 写 my_first_fpga，小心翼翼地按照教程就可以做出第一个小玩意啦~<br/>
成果大致如下 

<img src="./imgs/my_first_fpga.gif" width="500px"/>


### Stop Watch
这是第一个lab，代码量不大，但是不一定容易做，刚开始可能需要熟悉很多部分，软件、代码等等<br/>

这个lab最重要的部分是按键消抖，按键消抖老师上课应该会说原理，方法不止一种，弄清楚抖动地波形，做出一定地假设，理解按键消抖不是很困难。

效果大致如下:
<img src="./imgs/stop_watch.gif" width="500px"/>


几点需要注意的地方：
1. HEX, KEY, SWITCH的PIN代码可以在 `DE1_Soc_User_Manual` PDF上查到
2. verilog 的 module 不需要像 c 一样声明之类的，你可以在任意一个文件中定义module，然后只要这个文件在项目中，就可以使用到该module。

### Single Clock Computer
这个lab给了几乎所有的代码，我们只需要填写sc_cu, sc_alu两个部分就能完成一个单周期cpu。<br/>
但是从这个lab开始我们需要做 I/O 地址统一，把 Switch, Key, Hex的地址映射到 data memory。不过幸好，IO部分的代码也在老师给的实验指导书上有了说明，但是我发现我做的时候，比较难理解的是这个单周期CPU最终的实验目标是什么。<br/>
其实老师给的mif就是memory initialization file用来初始化memory的。我们的目标是在写好CPU的代码后，在我们的CPU上运行一个程序（实验指导书上指出可以做个简单的加法器），为了能够直观的观察我们的程序运行在CPU上，我们的在加法器代码中，可以采用数据地址全部用 I/O 读取到的做法，这样做的好处就是我们可以动态更改加法器的两个加数。</br>
从这个lab开始，也需要做仿真测试，仿真测试使用 `Modelsim`，这也是一个坑比较多的软件，但是操作相比 `Quartus`简单的多。

<img src="./imgs/sc_computer.gif"  width="500px"/>


