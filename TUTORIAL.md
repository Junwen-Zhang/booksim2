# BookSim2 SST-Elements 集成教程
# BookSim2 SST-Elements Integration Tutorial

本教程提供完整的步骤，帮助您将 BookSim2 注册为 SST-Elements 模块。
This tutorial provides complete steps to register BookSim2 as an SST-Elements module.

---

## 目录 / Table of Contents

1. [环境准备 / Environment Setup](#环境准备--environment-setup)
2. [获取源代码 / Getting Source Code](#获取源代码--getting-source-code)
3. [集成步骤 / Integration Steps](#集成步骤--integration-steps)
4. [构建和安装 / Build and Install](#构建和安装--build-and-install)
5. [验证安装 / Verification](#验证安装--verification)
6. [使用示例 / Usage Examples](#使用示例--usage-examples)
7. [故障排除 / Troubleshooting](#故障排除--troubleshooting)

---

## 环境准备 / Environment Setup

### 系统要求 / System Requirements

- 操作系统 / OS: Linux (Ubuntu 20.04+, CentOS 7+, or similar)
- 编译器 / Compiler: GCC 7.0+ or Clang 5.0+ (C++11 support)
- Python: 3.6+
- Autotools: autoconf, automake, libtool

### 安装依赖 / Install Dependencies

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    python3 \
    python3-dev \
    git \
    wget
```

#### CentOS/RHEL:
```bash
sudo yum groupinstall "Development Tools"
sudo yum install -y \
    autoconf \
    automake \
    libtool \
    python3 \
    python3-devel \
    git \
    wget
```

---

## 获取源代码 / Getting Source Code

### 1. 下载 SST-Core / Download SST-Core

```bash
# 创建工作目录 / Create working directory
mkdir -p ~/sst-workspace
cd ~/sst-workspace

# 下载 SST-Core 11.0.0 / Download SST-Core 11.0.0
wget https://github.com/sstsimulator/sst-core/releases/download/v11.0.0/sstcore-11.0.0.tar.gz
tar xzf sstcore-11.0.0.tar.gz
cd sstcore-11.0.0

# 配置和安装 / Configure and install
./configure --prefix=$HOME/local/sst
make -j$(nproc)
make install

cd ..
```

### 2. 下载 SST-Elements / Download SST-Elements

```bash
# 下载 SST-Elements 11.0.0 / Download SST-Elements 11.0.0
wget https://github.com/sstsimulator/sst-elements/releases/download/v11.0.0/sstelements-11.0.0.tar.gz
tar xzf sstelements-11.0.0.tar.gz
cd sstelements-11.0.0

# 不要立即编译 - 先集成 BookSim2
# Don't compile yet - integrate BookSim2 first
cd ..
```

### 3. 克隆 BookSim2 / Clone BookSim2

```bash
# 克隆 BookSim2 仓库的 sst-macro 分支
# Clone BookSim2 repository (sst-macro branch)
git clone -b sst-macro https://github.com/Junwen-Zhang/booksim2.git
cd booksim2

# 或者如果您已经有本地副本 / Or if you already have local copy
# cd /path/to/your/booksim2
```

---

## 集成步骤 / Integration Steps

### 方法 A：自动集成（推荐）/ Method A: Automatic Integration (Recommended)

```bash
# 在 BookSim2 目录中 / In BookSim2 directory
cd ~/sst-workspace/booksim2

# 运行集成脚本 / Run integration script
./integrate_sst.sh --sst-elements ~/sst-workspace/sstelements-11.0.0

# 脚本会自动完成以下操作 / Script automatically:
# 1. 复制 BookSim2 到 SST-Elements
# 2. 更新 configure.ac
# 3. 更新 Makefile.am
# 4. 创建配置文件备份
```

### 方法 B：手动集成 / Method B: Manual Integration

#### 步骤 1：复制文件 / Step 1: Copy Files

```bash
# 复制 BookSim2 到 SST-Elements
# Copy BookSim2 to SST-Elements
cp -r ~/sst-workspace/booksim2 \
      ~/sst-workspace/sstelements-11.0.0/src/sst/elements/booksim2
```

#### 步骤 2：修改 configure.ac / Step 2: Modify configure.ac

编辑 `~/sst-workspace/sstelements-11.0.0/configure.ac`:

```bash
# 查找类似的行 / Find lines like:
# SST_CHECK_ELEMENT([other_element], ...)

# 在合适的位置添加 / Add at appropriate location:
SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])

# 在 AC_CONFIG_FILES 部分添加 / Add to AC_CONFIG_FILES:
AC_CONFIG_FILES([
    ...
    src/sst/elements/booksim2/Makefile
    ...
])
```

#### 步骤 3：修改 Makefile.am / Step 3: Modify Makefile.am

编辑 `~/sst-workspace/sstelements-11.0.0/src/sst/elements/Makefile.am`:

```bash
# 在 SUBDIRS 中添加 / Add to SUBDIRS:
SUBDIRS = \
    ...
    booksim2 \
    ...
```

---

## 构建和安装 / Build and Install

### 1. 设置环境变量 / Set Environment Variables

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
# Add to ~/.bashrc or ~/.zshrc
export SST_HOME=$HOME/local/sst
export PATH=$SST_HOME/bin:$PATH
export LD_LIBRARY_PATH=$SST_HOME/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$SST_HOME/lib/pkgconfig:$PKG_CONFIG_PATH

# 立即生效 / Apply immediately
source ~/.bashrc  # or source ~/.zshrc
```

### 2. 构建 SST-Elements / Build SST-Elements

```bash
cd ~/sst-workspace/sstelements-11.0.0

# 生成配置脚本 / Generate configure script
./autogen.sh

# 配置 / Configure
./configure --prefix=$HOME/local/sst --with-sst-core=$HOME/local/sst

# 编译（使用所有 CPU 核心）/ Compile (using all CPU cores)
make -j$(nproc)

# 安装 / Install
make install
```

**注意 / Note:** 编译可能需要 15-30 分钟，具体取决于您的系统。
Compilation may take 15-30 minutes depending on your system.

---

## 验证安装 / Verification

### 1. 检查组件注册 / Check Component Registration

```bash
# 列出所有 BookSim2 组件 / List all BookSim2 components
sst-info booksim2

# 应该看到 / Should see:
# - booksim2.booksim2 (Component)
# - booksim2.booksimbridge (SubComponent)
# - booksim2.booksiminterface (SubComponent)
```

### 2. 查看详细信息 / View Detailed Information

```bash
# 查看主组件 / View main component
sst-info booksim2.booksim2

# 查看桥接组件 / View bridge component
sst-info booksim2.booksimbridge

# 查看接口组件 / View interface component
sst-info booksim2.booksiminterface
```

### 3. 测试基本配置 / Test Basic Configuration

创建测试文件 `test_booksim.py`:

```python
import sst

# 创建 BookSim2 网络组件 / Create BookSim2 network component
network = sst.Component("booksim_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "packet_size": 1,
    "num_vcs": 2,
    "num_motif_nodes": 0
})

print("BookSim2 component created successfully!")
```

运行测试 / Run test:
```bash
sst test_booksim.py
```

---

## 使用示例 / Usage Examples

### 示例 1：基本网络 / Example 1: Basic Network

```python
import sst

# 创建网络 / Create network
network = sst.Component("network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "num_vcs": 2,
    "packet_size": 1,
    "num_motif_nodes": 4
})
```

### 示例 2：带 Ember 和 Firefly / Example 2: With Ember and Firefly

参考项目中的 `booksim_example.py` 文件。
Refer to `booksim_example.py` in the project.

### 示例 3：不同拓扑 / Example 3: Different Topologies

#### 网格拓扑 / Mesh Topology
```python
network.addParams({
    "topology": "mesh",
    "k": 4,  # 4x4 mesh
    "n": 2   # 2 dimensions
})
```

#### 胖树拓扑 / Fat-Tree Topology
```python
network.addParams({
    "topology": "fattree",
    "k": 4  # 4-port switches
})
```

---

## 故障排除 / Troubleshooting

### 问题 1：找不到组件 / Issue 1: Component Not Found

**症状 / Symptom:**
```
Error: Component booksim2.booksim2 not found
```

**解决方案 / Solution:**
```bash
# 检查是否安装 / Check if installed
sst-info | grep booksim

# 检查库路径 / Check library path
echo $LD_LIBRARY_PATH

# 添加库路径 / Add library path
export LD_LIBRARY_PATH=$HOME/local/sst/lib:$LD_LIBRARY_PATH
```

### 问题 2：编译错误 / Issue 2: Compilation Errors

**症状 / Symptom:**
```
error: 'something' was not declared in this scope
```

**解决方案 / Solution:**
```bash
# 检查 SST-Core 安装 / Check SST-Core installation
sst-config --prefix
sst-config --CXXFLAGS

# 确保使用正确的编译器 / Ensure correct compiler
which g++
g++ --version  # Should be 7.0 or higher
```

### 问题 3：configure.ac 错误 / Issue 3: configure.ac Errors

**症状 / Symptom:**
```
configure.ac: error: ...
```

**解决方案 / Solution:**
```bash
# 检查 configure.m4 位置 / Check configure.m4 location
ls ~/sst-workspace/sstelements-11.0.0/src/sst/elements/booksim2/configure.m4

# 重新运行 autogen / Re-run autogen
cd ~/sst-workspace/sstelements-11.0.0
./autogen.sh

# 查看错误详情 / View error details
./autogen.sh 2>&1 | grep -i booksim
```

### 问题 4：运行时链接错误 / Issue 4: Runtime Linking Errors

**症状 / Symptom:**
```
error while loading shared libraries: libbooksim2.so
```

**解决方案 / Solution:**
```bash
# 查找库文件 / Find library file
find $HOME/local/sst -name "libbooksim2*"

# 更新 LD_LIBRARY_PATH / Update LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/local/sst/lib:$LD_LIBRARY_PATH

# 或使用 ldconfig (需要 root) / Or use ldconfig (requires root)
sudo ldconfig
```

---

## 进阶配置 / Advanced Configuration

### 自定义路由算法 / Custom Routing Algorithms

BookSim2 支持多种路由算法 / BookSim2 supports various routing algorithms:

```python
# 维度顺序路由 / Dimension-ordered routing
"routing_function": "dor"

# 最小自适应路由 / Minimal adaptive routing
"routing_function": "min_adapt"

# UGAL 路由 / UGAL routing
"routing_function": "ugal"

# Valiant 路由 / Valiant routing
"routing_function": "valiant"
```

### 虚拟通道配置 / Virtual Channel Configuration

```python
network.addParams({
    "num_vcs": 4,           # 4 个虚拟通道 / 4 virtual channels
    "vc_buf_size": 8,       # 每个 VC 的缓冲区大小 / Buffer size per VC
    "vn_remap": "0:0,1:1,2:2,3:3"  # VN 映射 / VN mapping
})
```

### 性能参数 / Performance Parameters

```python
network.addParams({
    "link_bandwidth": "16GB/s",  # 链路带宽 / Link bandwidth
    "flit_size": 64,             # Flit 大小（位）/ Flit size (bits)
    "credit_delay": 1,           # 信用延迟（周期）/ Credit delay (cycles)
    "routing_delay": 0           # 路由延迟（周期）/ Routing delay (cycles)
})
```

---

## 完整示例脚本 / Complete Example Script

参考以下文件获取完整示例 / Refer to these files for complete examples:

1. **booksim.py** - 基本配置 / Basic configuration
2. **booksim_example.py** - 完整示例 / Full example
3. **INTEGRATION.md** - 详细英文文档 / Detailed English documentation
4. **INTEGRATION_CN.md** - 详细中文文档 / Detailed Chinese documentation
5. **QUICKREF.md** - 快速参考 / Quick reference

---

## 资源和参考 / Resources and References

### 官方文档 / Official Documentation
- SST Core: http://sst-simulator.org/
- SST Elements: https://github.com/sstsimulator/sst-elements
- BookSim2: https://github.com/booksim/booksim2

### 社区支持 / Community Support
- SST Mailing List: sst-users@groups.google.com
- GitHub Issues: https://github.com/Junwen-Zhang/booksim2/issues

### 相关论文 / Related Papers
- BookSim2: "A Detailed and Flexible Cycle-Accurate Network-on-Chip Simulator"
- SST: "The Structural Simulation Toolkit"

---

## 总结 / Summary

完成本教程后，您应该能够：
After completing this tutorial, you should be able to:

✓ 安装 SST-Core 和 SST-Elements / Install SST-Core and SST-Elements
✓ 将 BookSim2 集成到 SST-Elements / Integrate BookSim2 into SST-Elements
✓ 验证 BookSim2 组件注册 / Verify BookSim2 component registration
✓ 创建基本的 SST 配置文件 / Create basic SST configuration files
✓ 使用 BookSim2 模拟网络流量 / Use BookSim2 to simulate network traffic
✓ 解决常见问题 / Troubleshoot common issues

祝您使用愉快！/ Happy simulating!
