# BookSim2 集成到 SST-Elements 指南

本指南详细说明如何将 BookSim2 作为模块注册到 SST-Elements 中，以便它可以与 Ember 和 Firefly 组件一起使用。

## 前提条件

- SST-Core 11.0.0（或兼容版本）
- SST-Elements 11.0.0（或兼容版本）
- 支持 C++11 或更高版本的 C++ 编译器
- Autoconf 和 Automake 工具

## 集成步骤

### 方法一：使用自动化脚本（推荐）

1. 确保您已经安装了 SST-Core 和 SST-Elements 的源代码

2. 运行集成脚本：

```bash
cd /path/to/booksim2
./integrate_sst.sh --sst-elements /path/to/sst-elements
```

脚本会自动完成以下操作：
- 将 BookSim2 源代码复制到 SST-Elements 目录
- 更新 `configure.ac` 文件
- 更新 `Makefile.am` 文件
- 创建配置文件的备份

3. 重新编译 SST-Elements：

```bash
cd /path/to/sst-elements
./autogen.sh
./configure --prefix=/path/to/install
make -j$(nproc)
make install
```

4. 验证安装：

```bash
sst-info booksim2
```

### 方法二：手动集成

#### 步骤 1：复制 BookSim2 到 SST-Elements

将整个 BookSim2 目录复制到 SST-Elements 源代码树中：

```bash
cp -r /path/to/booksim2 /path/to/sst-elements/src/sst/elements/booksim2
```

#### 步骤 2：注册 BookSim2 到 SST-Elements 配置

编辑 `/path/to/sst-elements/configure.ac`，添加 BookSim2：

找到检查其他元素的部分（查找类似 `SST_CHECK_ELEMENT` 的行），添加：

```autoconf
SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])
```

同时找到 `AC_CONFIG_FILES` 部分，添加：

```autoconf
AC_CONFIG_FILES([
    ...
    src/sst/elements/booksim2/Makefile
    ...
])
```

#### 步骤 3：更新 SST-Elements Makefile

编辑 `/path/to/sst-elements/src/sst/elements/Makefile.am`，包含 BookSim2：

找到 `SUBDIRS` 变量，添加 `booksim2`：

```makefile
SUBDIRS = \
    ...
    booksim2 \
    ...
```

#### 步骤 4：重新编译 SST-Elements

```bash
cd /path/to/sst-elements
./autogen.sh
./configure --prefix=/path/to/install
make -j$(nproc)
make install
```

#### 步骤 5：验证安装

```bash
sst-info booksim2
```

这应该显示有关 BookSim2 组件的信息，包括：
- 组件：`booksim2.booksim2`
- 子组件：`booksim2.booksimbridge`
- 子组件：`booksim2.booksiminterface`

## 在 SST 中使用 BookSim2

### Python 配置示例

```python
import sst

# 创建 BookSim2 网络组件
network = sst.Component("booksim_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "packet_size": 1,
    "num_vcs": 2,
    "num_motif_nodes": 4
})

# 创建带有 BookSimBridge 的端点
endpoint = sst.Component("endpoint0", "firefly.nic")
bridge = endpoint.setSubComponent("networkIF", "booksim2.booksimbridge", 0)
bridge.addParams({
    "job_id": 0,
    "logical_nid": 0
})

# 连接到网络
link = sst.Link("link0")
link.connect((bridge, "rtr_port", "1ns"), (network, "motif_node0", "1ns"))
```

### 与 Ember 和 Firefly 集成

BookSim2 设计用于与 SST-Elements 中的 Ember（流量生成器）和 Firefly（NIC）组件一起工作。

1. **Ember 生成流量**：Ember 组件生成网络流量模式
2. **Firefly NIC 处理**：Firefly NIC 接收流量并通过 BookSimBridge 发送
3. **BookSim2 模拟**：BookSim2 模拟网络中的数据包传输
4. **返回路径**：数据包通过 BookSimBridge 返回到目标 Firefly NIC

完整的配置示例：

```python
import sst

NUM_NODES = 4

# 创建 BookSim2 网络
network = sst.Component("booksim_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "num_vcs": 2,
    "num_motif_nodes": NUM_NODES
})

# 为每个节点创建 Ember 和 Firefly
for i in range(NUM_NODES):
    # 创建 Ember 流量生成器
    ember = sst.Component(f"ember_{i}", "ember.EmberEngine")
    ember.addParams({
        "verbose": 0
    })
    
    # 创建 Firefly NIC
    nic = sst.Component(f"nic_{i}", "firefly.nic")
    nic.addParams({
        "verbose": 0
    })
    
    # 创建 BookSimBridge
    bridge = nic.setSubComponent("networkIF", "booksim2.booksimbridge", 0)
    bridge.addParams({
        "job_id": 0,
        "logical_nid": i
    })
    
    # 连接 Ember 到 NIC
    ember_link = sst.Link(f"ember_link_{i}")
    ember_link.connect(
        (ember, "nic", "1ns"),
        (nic, "core", "1ns")
    )
    
    # 连接 NIC 到网络
    network_link = sst.Link(f"network_link_{i}")
    network_link.connect(
        (bridge, "rtr_port", "1ns"),
        (network, f"motif_node{i}", "1ns")
    )
```

## 组件详细信息

### 主组件：booksim2.booksim2

主网络模拟器组件。

**参数：**
- `booksim_clock` (string)：时钟频率（默认："1GHz"）
- `topology` (string)：网络拓扑（例如："dragonfly"、"fattree"、"mesh"）
- `routing_function` (string)：路由算法（例如："min_adapt"、"dor"）
- `packet_size` (int)：数据包大小（单位：flit）（默认：1）
- `num_vcs` (int)：虚拟通道数量（默认：1）
- `num_motif_nodes` (int)：端点节点数量（默认：0）

### 子组件：booksim2.booksimbridge

Firefly NIC 和 BookSim 网络之间的接口。

**参数：**
- `port_name` (string)：连接的端口名称
- `job_id` (int)：此端点的作业 ID
- `Job_size` (int)：作业中的节点数量
- `logical_nid` (int)：逻辑节点 ID
- `use_nid_remap` (bool)：启用 NID 重映射（默认：false）
- `nid_map_name` (string)：NID 映射的共享区域名称
- `vn_remap` (string)：虚拟网络重映射配置

**端口：**
- `rtr_port`：连接到路由器

**统计信息：**
- `packet_latency`：接收数据包延迟的直方图
- `send_bit_count`：发送的比特数
- `output_port_stalls`：输出端口停顿时间
- `idle_time`：端口空闲时间

## 支持的网络拓扑

BookSim2 支持多种网络拓扑：

- `mesh`：2D/3D 网格网络
- `torus`：2D/3D 环形网络
- `dragonfly`：蜻蜓拓扑
- `fattree`：胖树拓扑
- `flatfly_onchip`：扁平蝴蝶拓扑

## 路由算法

BookSim2 支持多种路由算法：

- `dor`：维度顺序路由
- `min_adapt`：最小自适应路由
- `ugal`：通用全局自适应负载平衡路由
- `valiant`：Valiant 路由

## 常见问题解决

### 编译问题

1. **缺少头文件**：确保 SST-Core 正确安装且 `sst-config` 在您的 PATH 中。

2. **Autoconf 错误**：在 SST-Elements 目录中运行 `./autogen.sh` 重新生成配置文件。

3. **编译错误**：检查您使用的是兼容 C++11 的编译器。

### 运行时问题

1. **找不到组件**：使用 `sst-info booksim2` 验证安装。

2. **库加载错误**：确保 SST 库路径包含安装目录：
   ```bash
   export LD_LIBRARY_PATH=/path/to/install/lib:$LD_LIBRARY_PATH
   ```

3. **配置错误**：使用 `sst-info` 检查参数名称和类型。

## 示例文件

项目包含以下示例文件：

- `booksim.py`：基本 BookSim2 配置
- `booksim_example.py`：完整的示例配置
- `INTEGRATION.md`：详细的英文集成指南

## 文件说明

重要的集成文件：

- **configure.m4**：SST-Elements 的 autoconf 宏文件
- **Makefile.am**：Automake 构建文件
- **integrate_sst.sh**：自动化集成脚本
- **booksim2.h**：主组件头文件
- **booksimBridge.h**：桥接组件头文件
- **booksimInterface.h**：接口子组件头文件

## 参考资料

- [SST 模拟器文档](http://sst-simulator.org/)
- [BookSim2 文档](https://github.com/booksim/booksim2)
- [SST-Elements GitHub](https://github.com/sstsimulator/sst-elements)

## 技术支持

对于 BookSim2 集成的特定问题，请在 BookSim2 仓库中开启 issue。
对于一般的 SST 问题，请参考 SST 文档或邮件列表。

## 贡献

欢迎贡献！如果您发现问题或有改进建议，请提交 issue 或 pull request。
