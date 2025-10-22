# Integrating BookSim2 into SST-Elements

This guide explains how to register BookSim2 as a module in SST-Elements so that it can be used with Ember and Firefly components.

## Prerequisites

- SST-Core 11.0.0 (or compatible version)
- SST-Elements 11.0.0 (or compatible version)
- C++ compiler with C++11 support or later
- Autoconf and Automake tools

## Integration Steps

### 1. Copy BookSim2 to SST-Elements

Copy the entire BookSim2 directory into the SST-Elements source tree:

```bash
# Assuming you have SST-Elements source at /path/to/sst-elements
cp -r /path/to/booksim2 /path/to/sst-elements/src/sst/elements/booksim2
```

### 2. Register BookSim2 in SST-Elements Configuration

Edit `/path/to/sst-elements/configure.ac` to add BookSim2:

Find the section where other elements are checked (look for lines like `SST_CHECK_ELEMENT`) and add:

```autoconf
SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])
```

Also find the `AC_CONFIG_FILES` section and add:

```autoconf
AC_CONFIG_FILES([
    ...
    src/sst/elements/booksim2/Makefile
    ...
])
```

### 3. Update SST-Elements Makefile

Edit `/path/to/sst-elements/src/sst/elements/Makefile.am` to include BookSim2:

Find the `SUBDIRS` variable and add `booksim2`:

```makefile
SUBDIRS = \
    ...
    booksim2 \
    ...
```

### 4. Rebuild SST-Elements

```bash
cd /path/to/sst-elements
./autogen.sh
./configure --prefix=/path/to/install
make -j$(nproc)
make install
```

### 5. Verify Installation

Check that BookSim2 is registered:

```bash
sst-info booksim2
```

This should display information about the BookSim2 component, including:
- Component: `booksim2.booksim2`
- Subcomponent: `booksim2.booksimbridge`
- Subcomponent: `booksim2.booksiminterface`

## Using BookSim2 with SST

### Python Configuration Example

```python
import sst

# Create BookSim2 network component
network = sst.Component("booksim_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "packet_size": 1,
    "num_vcs": 2,
    "num_motif_nodes": 4
})

# Create endpoint with BookSimBridge
endpoint = sst.Component("endpoint0", "firefly.nic")
bridge = endpoint.setSubComponent("networkIF", "booksim2.booksimbridge", 0)
bridge.addParams({
    "job_id": 0,
    "logical_nid": 0
})

# Connect to network
link = sst.Link("link0")
link.connect((bridge, "rtr_port", "1ns"), (network, "motif_node0", "1ns"))
```

## Component Details

### Main Component: booksim2.booksim2

The main network simulator component.

**Parameters:**
- `booksim_clock` (string): Clock frequency (default: "1GHz")
- `topology` (string): Network topology (e.g., "dragonfly", "fattree", "mesh")
- `routing_function` (string): Routing algorithm (e.g., "min_adapt", "dor")
- `packet_size` (int): Packet size in flits (default: 1)
- `num_vcs` (int): Number of virtual channels (default: 1)
- `num_motif_nodes` (int): Number of endpoint nodes (default: 0)

### SubComponent: booksim2.booksimbridge

Interface between Firefly NIC and BookSim network.

**Parameters:**
- `port_name` (string): Port name to connect to
- `job_id` (int): Job ID for this endpoint
- `Job_size` (int): Number of nodes in the job
- `logical_nid` (int): Logical node ID
- `use_nid_remap` (bool): Enable NID remapping (default: false)
- `nid_map_name` (string): Shared region name for NID map
- `vn_remap` (string): Virtual network remapping configuration

**Ports:**
- `rtr_port`: Connection to router

**Statistics:**
- `packet_latency`: Histogram of received packet latencies
- `send_bit_count`: Number of bits sent
- `output_port_stalls`: Time output port is stalled
- `idle_time`: Time port was idle

### SubComponent: booksim2.booksiminterface

Internal interface between BookSimBridge and BookSim traffic manager.

**Parameters:**
- `num_motif_nodes` (int): Number of motif nodes

## Topology Configuration

BookSim2 supports various network topologies. Each topology can be configured with additional parameters in a configuration file or through Python parameters.

### Supported Topologies
- `mesh`: 2D/3D mesh networks
- `torus`: 2D/3D torus networks
- `dragonfly`: Dragonfly topology
- `fattree`: Fat-tree topology
- `flatfly_onchip`: Flattened butterfly

### Using Configuration Files

You can also use BookSim configuration files:

```python
network.addParams({
    "config_file": "/path/to/booksim_config.txt"
})
```

## Troubleshooting

### Build Issues

1. **Missing headers**: Ensure SST-Core is properly installed and `sst-config` is in your PATH.

2. **Autoconf errors**: Run `autogen.sh` in the SST-Elements directory to regenerate configuration files.

3. **Compilation errors**: Check that you're using a C++11-compatible compiler.

### Runtime Issues

1. **Component not found**: Verify installation with `sst-info booksim2`.

2. **Library loading errors**: Ensure SST library path includes the installation directory:
   ```bash
   export LD_LIBRARY_PATH=/path/to/install/lib:$LD_LIBRARY_PATH
   ```

3. **Configuration errors**: Use `sst-info` to check parameter names and types.

## Advanced Configuration

### Custom Routing Algorithms

BookSim2 supports various routing algorithms:
- `dor`: Dimension-ordered routing
- `min_adapt`: Minimal adaptive routing
- `ugal`: Universal Globally-Adaptive Load-balanced routing
- `valiant`: Valiant routing

### Multiple Virtual Networks

Configure multiple virtual networks for different traffic classes:

```python
network.addParams({
    "num_vcs": 4,
    "vn_remap": "0:0,1:1,2:2,3:3"
})
```

## References

- [SST Simulator Documentation](http://sst-simulator.org/)
- [BookSim2 Documentation](https://github.com/booksim/booksim2)
- [SST-Elements GitHub](https://github.com/sstsimulator/sst-elements)

## Support

For issues specific to BookSim2 integration, please open an issue on the BookSim2 repository.
For general SST questions, refer to the SST documentation or mailing lists.
