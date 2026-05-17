---
title: "Windows + AMD ROCm + PyTorch：debuff拉满的6650xt A卡炼丹折腾经历"
source: "https://blog.deali.cn/p/rocm-windows-compile-pytorch#"
author:
  - "[[DealiAxy]]"
published: 2026-01-05
created: 2026-04-17
description: "用6650XT在Windows上跑PyTorch？AMD官方都不支持这卡，还得自己编译ROCm。折腾一晚上环境变量和编译错误，结果连个wheel都没生成出来。所以为什么非要在Windows上给A卡炼丹？"
tags:
  - "clippings"
---
## 前言

最近经常刷到 z-image 这个模型，感觉挺有意思的。

说来惭愧，我也有段时间没折腾 AI 画图了，工作室那几台服务器早就被大模型拉满了，再继续加任务多少有点不人道。

于是我把主意打到了自己的台式机上。

几年前买的 **RX 6650 XT** ，当时压根没考虑过拿来炼丹。但几年过去，AMD 的 **ROCm** 也算是一步步成熟起来了。

以前只能在 Linux 上折腾，而 **今年 ROCm v7 开始支持 Windows** ，这事一下就有点可行性了。

唯一的问题是：PyTorch 还是只有 Linux 官方支持，Windows 上只能自己编译。

行吧，那就来折腾一把。

本文记录的是我在 **Windows 11 + AMD 6650 XT + ROCm + PyTorch** 这条路上的完整踩坑过程。

**截至本文发布时，我还没折腾成功 😂**

但我会把这当成一个持续更新的系列，一直写到折腾成功（或者彻底认输）为止。

## 虚拟环境

这一步属于 Python 基础操作了，简单过一下。

### 创建虚拟环境

```bash
mkdir d:/code/2/_temp
cd d:/code/2/_temp
python -m venv venv
```

以上命令会在 `d:/code/2/_temp/venv` 创建虚拟环境，python 版本和系统安装的一样。

当然，也可以使用 `conda / mamba / uv` 之类的方案。

我一开始是用 **Stability Matrix** 安装 ComfyUI，它自动帮我创建了虚拟环境，所以干脆就直接用了。

### 进入虚拟环境

保持在 `d:/code/2/_temp` 目录里，使用以下命令

```bash
venv/scripts/activate
```

然后一定要验证一下

```bash
pip --version
```

确保输出路径指向的是虚拟环境里的 `pip` ，而不是系统全局的。

## 安装 ROCm

接下来是最关键的一步： **安装 ROCm** ，可以理解为 AMD 显卡的 CUDA。

我的显卡是 **AMD RX 6650 XT** ，对应的 code name 是 **gfx1032** 。

### 确认显卡架构

可以在 ROCm 官方文档里查到显卡与架构的对应关系：

[https://rocm.docs.amd.com/en/latest/reference/gpu-arch-specs.html](https://rocm.docs.amd.com/en/latest/reference/gpu-arch-specs.html)

![](https://blog.deali.cn/media/blog/48157669cd09b097/7b6d8ebc1c008808.jpg)

还有另一种方法：使用 GPU-Z 工具查看显卡的架构，比如我这张卡的架构是 **Navi 23** 。

![](https://blog.deali.cn/media/blog/48157669cd09b097/65dc9293edb05ca4.png)

然后再去 Mesa 的源码里查对应的 code name: [https://gitlab.freedesktop.org/mesa/mesa/-/blob/main/src/amd/common/amd\_family.c](https://gitlab.freedesktop.org/mesa/mesa/-/blob/main/src/amd/common/amd_family.c) 查看源码里对应的 code name

![](https://blog.deali.cn/media/blog/48157669cd09b097/8d13bf43e1dac7b3.jpg)

### 关于显卡支持情况

需要注意的是：AMD 官方的 ROCm v7 没有支持 6x00/6x50 系列显卡。

也就是说，像 6650 XT 这种卡，要么用第三方预构建版本，要么自己编译。

如果你的显卡不在官方支持列表里，可以访问这个页面查看对应的预构建包: [https://d2awnip2yjpvqn.cloudfront.net/v2/](https://d2awnip2yjpvqn.cloudfront.net/v2/)

![](https://blog.deali.cn/media/blog/48157669cd09b097/9adaceeb6189658b.jpg)

如果你刚好是官方支持的型号（比如 7000 系列），那事情就简单多了。直接用 AMD 官方的包，比如以下是 7x00 系列显卡的安装：

```bash
pip install --index-url https://rocm.nightlies.amd.com/v2/gfx110X-all/ "rocm[libraries,devel]"
```

而 **6650 XT** 对应的安装命令是：

```bash
python -m pip install --upgrade --index-url https://d2awnip2yjpvqn.cloudfront.net/v2/gfx103X-dgpu/ rocm rocm-sdk-core rocm-sdk-devel rocm-sdk-libraries-gfx103x-dgpu
```

装好后测试一下

```bash
rocm-sdk test
```

没问题的话会输出一大堆测试结果，最后面是：

```bash
$ rocm-sdk test
...
Ran 22 tests in 258.284s
OK
```

## 构建 PyTorch

ROCm 装好之后，接下来就只剩下一个问题了： **PyTorch 没有 Windows + ROCm 的官方发行版，只能自己编译。**

官方文档: [https://github.com/ROCm/TheRock/tree/main/external-builds/pytorch#build-instructions](https://github.com/ROCm/TheRock/tree/main/external-builds/pytorch#build-instructions)

### 获取代码

首先 clone `ROCm/TheRock` 仓库，然后进入目录：

```bash
cd external-builds/pytorch
```

通过官方提供的脚本拉取 PyTorch 相关仓库：

⚠️ 官方特别提醒：Windows 下尽量使用较短路径，避免命令长度限制

```
python pytorch_torch_repo.py checkout --checkout-dir d:/code/2/pytorch
python pytorch_audio_repo.py checkout --checkout-dir d:/code/2/pytorch-audio
python pytorch_vision_repo.py checkout --checkout-dir d:/code/2/pytorch-vision
```

拉完之后我才意识到，这几个代码库这么大。建议加上 `--depth=1` 参数，不要把全量的 git 历史拉下来。

![](https://blog.deali.cn/media/blog/48157669cd09b097/f56c48ba73a7514e.png)

### 环境准备

这是官方提供的 build 命令，里面有安装 ROCm 的选项，我之前已经安装好 ROCm 了，所以就没按照这个命令来。

```bash
python build_prod_wheels.py build ^
  --install-rocm --index-url https://rocm.nightlies.amd.com/v2/gfx110X-all/ ^
  --pytorch-dir C:/b/pytorch ^
  --pytorch-audio-dir C:/b/audio ^
  --pytorch-vision-dir C:/b/vision ^
  --output-dir %HOME%/tmp/pyout
```

已有 ROCm 的情况下，只需要执行这个命令，不过先别急，准备工作还没完呢。

```bash
python build_prod_wheels.py build ^
  --pytorch-dir d:/code/2/pytorch ^
  --pytorch-audio-dir d:/code/2/pytorch-audio ^
  --pytorch-vision-dir d:/code/2/pytorch-vision ^
  --output-dir d:/code/2/_temp/pyout
```

#### 安装并配置 clang / MSVC 编译环境

还得安装 visual studio 2022 的 C++ 开发工具。

下载地址: [https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&channel=Release&version=VS2022&source=VSLandingPage&cid=2030&passive=false](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&channel=Release&version=VS2022&source=VSLandingPage&cid=2030&passive=false)

安装需要占用 6G 多的空间。

装完后直接开始编译的话，大概率还是不行的，提示找不到 VCToolsRedist 什么的，原因是没有把路径添加到环境变量里。

#### 添加环境变量

我一开始尝试手动设置环境变量，例如：

```powershell
# 1. 设置基础安装路径 (注意 VS 2022 默认通常在 'C:\Program Files', 确认你的在 x86)
$env:VCINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC"

# 2. 引用上面的变量来设置 Redist 路径 (使用双引号确保变量被解析)
$env:VCToolsRedistDir = "$($env:VCINSTALLDIR)\Redist\MSVC\14.44.35112\"

# 3. 验证是否设置成功
echo $env:VCToolsRedistDir
```

虽然手动设置可以解决一部分报错，但 PyTorch 的编译依赖数十个复杂的环境变量（如 `INCLUDE`, `LIB`, `PATH` 等）。手动设置 `$env:VCToolsRedistDir` 只能解决当前这一个报错，后面可能还会遇到 `cl.exe` 找不到等问题。

实际上我也遇到了😂

另一个方案，在 PowerShell 中运行以下命令，自动加载 Visual Studio 的完整开发环境（这比手动设置变量可靠得多）：

```powershell
# 导入 VS 编译环境到当前 PowerShell
Import-Module "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell -VsInstallPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" -SkipAutomaticLocation -Arch amd64
```

最稳妥的方案：在“开始”菜单中搜索并打开 **"x64 Native Tools Command Prompt for VS 2022"** （x64 本机工具命令提示符）。

### 开始编译

准备工作完成后，终于可以开始编译了：

```bash
python .\build_prod_wheels.py build --pytorch-dir d:/code/2/pytorch --pytorch-audio-dir d:/code/2/pytorch-audio --pytorch-vision-dir d:/code/2/pytorch-vision --output-dir d:/code/2/_temp
```

第一次编译开始后我就去睡觉了，设置了编译完成自动关机，第二天起床一看啥也没有。

开始第二次编译，这次报错了，让 Gemini 大模型爷爷帮忙分析一下，跟我说是 clang-cl 编译器开启了严格模式，将警告视为错误了。

我尝试用环境变量把这个选项关闭：

powershell 命令

```powershell
# 允许缺少原型警告
$env:CFLAGS = "-Wno-error=missing-prototypes -Wno-missing-prototypes -Wno-error"
$env:CXXFLAGS = "-Wno-error=missing-prototypes -Wno-missing-prototypes -Wno-error"
```

cmd 命令（注意：等号两边不能有空格）

```
set CFLAGS="-Wno-error=missing-prototypes -Wno-missing-prototypes -Wno-error"
set CXXFLAGS="-Wno-error=missing-prototypes -Wno-missing-prototypes -Wno-error"

# 验证一下
echo %CFLAGS%, %CXXFLAGS%
```

不过我修改之后还是报错，又尝试清理构建缓存，因为报错信息里的 `RegisterMeta_0.cpp` 是生成的中间文件，有时残留的缓存会导致构建逻辑混乱。

删除了 `d:/code/2/pytorch/build` 文件夹，重新开始构建，这次暂时还没报错，CPU已经拉满 100% 了。

![](https://blog.deali.cn/media/blog/48157669cd09b097/6e1db028c1fac854.jpg)

## 报错分析

结果还是报错了

### 报错信息

报错太长了

我这里贴出主要的错误：

```
error: use of undeclared identifier 'Wno'
error: use of undeclared identifier 'error'
error: use of undeclared identifier 'missing'
error: use of undeclared identifier 'prototypes'
```

对应的上下文：

```arduino
static const std::map<string, string> kMap = CAFFE2_BUILD_STRINGS;
```

而 `CAFFE2_BUILD_STRINGS` 在 **自动生成的头文件** 里被展开成了这样：

```
{"CXX_FLAGS", ""-Wno-error=missing-prototypes -Wno-missing-prototypes" /DWIN32 /D_WINDOWS ..."}
```

注意这个双引号结构：

```julia
""-Wno-error=missing-prototypes -Wno-missing-prototypes"
```

这是非法 C/C++ 字符串拼接，直接导致宏展开后的代码不是 C++ 语法。

所以应该是之前设置的 CFLAGS 和 CXXFLAGS 环境变量不对？

### 降级尝试

这次 Gemini 大模型爷爷不管用啊，还是得 GPT 爷爷，告诉我可能是 pytorch 的源码版本太新（我这里用的是 2.11）

我决定试试降级到 2.10 试试。用 [Building ROCm 7.1 and PyTorch on Windows for Unsupported GPUs: My Hands-On Guide](https://medium.com/@guinmoon/building-rocm-7-1-and-pytorch-on-windows-for-unsupported-gpus-my-hands-on-guide-0758d2d2b334) 这篇文章里分享的方法可以指定版本：

```bash
python pytorch_torch_repo.py checkout --repo-hashtag release/2.10 --gitrepo-origin https://github.com/ROCm/pytorch.git --depth=1 --checkout-dir d:/code/2/pytorch
python pytorch_audio_repo.py checkout --require-related-commit --depth=1 --checkout-dir d:/code/2/pytorch-audio --torch-dir d:/code/2/pytorch
python pytorch_vision_repo.py checkout --require-related-commit --depth=1 --checkout-dir d:/code/2/pytorch-vision --torch-dir d:/code/2/pytorch
```

我去，结果还是不行，这回 GPT 给我嘴硬，非要说 Windows 没法编译 pytorch……

行吧，这事先记一笔。