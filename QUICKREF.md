# BookSim2 SST-Elements Integration - Quick Reference

## Quick Start (3 Steps)

### 1. Run Integration Script
```bash
./integrate_sst.sh --sst-elements /path/to/sst-elements
```

### 2. Rebuild SST-Elements
```bash
cd /path/to/sst-elements
./autogen.sh
./configure --prefix=$HOME/local/sst
make -j$(nproc)
make install
```

### 3. Verify
```bash
export PATH=$HOME/local/sst/bin:$PATH
export LD_LIBRARY_PATH=$HOME/local/sst/lib:$LD_LIBRARY_PATH
sst-info booksim2
```

## Key Files

### Integration Files
- `configure.m4` - Autoconf macro for SST-Elements detection
- `Makefile.am` - Automake build configuration
- `integrate_sst.sh` - Automated integration script

### Component Files
- `booksim2.h` / `booksim2.cc` - Main component
- `booksimBridge.h` / `booksimBridge.cc` - NIC-to-network bridge
- `booksimInterface.h` / `booksimInterface.cc` - Internal interface

### Documentation
- `INTEGRATION.md` - Detailed English guide
- `INTEGRATION_CN.md` - Detailed Chinese guide (中文指南)
- `README.md` - Project overview
- `booksim_example.py` - Usage example

## Component Architecture

```
┌─────────────────┐
│  Ember/Firefly  │  (Traffic Generator / NIC)
└────────┬────────┘
         │
         │ SimpleNetwork Interface
         │
┌────────▼────────────────┐
│  booksim2.booksimbridge │  (SST SubComponent)
└────────┬────────────────┘
         │
         │ BookSimEvent
         │
┌────────▼─────────────────────┐
│  booksim2.booksiminterface   │  (SST SubComponent)
└────────┬─────────────────────┘
         │
         │
┌────────▼────────────┐
│  booksim2.booksim2  │  (Main Component)
│  Traffic Manager    │
└─────────────────────┘
```

## SST Components

### booksim2.booksim2 (Main Component)
- **Type**: Component
- **Purpose**: Main network simulator
- **Key Parameters**: topology, routing_function, num_vcs, packet_size

### booksim2.booksimbridge (SubComponent)
- **Type**: SubComponent (SimpleNetwork interface)
- **Purpose**: Bridge between NIC and BookSim
- **Ports**: rtr_port
- **Key Parameters**: logical_nid, job_id

### booksim2.booksiminterface (SubComponent)
- **Type**: SubComponent
- **Purpose**: Internal interface to traffic manager
- **Key Parameters**: num_motif_nodes

## Common Parameters

### Network Configuration
```python
network.addParams({
    "topology": "dragonfly",      # mesh, torus, dragonfly, fattree
    "routing_function": "min_adapt", # dor, min_adapt, ugal, valiant
    "num_vcs": 2,                 # Virtual channels
    "packet_size": 1,             # Size in flits
    "booksim_clock": "1GHz"       # Clock frequency
})
```

### Bridge Configuration
```python
bridge.addParams({
    "logical_nid": node_id,       # Node ID
    "job_id": 0,                  # Job identifier
    "Job_size": NUM_NODES,        # Total nodes
    "use_nid_remap": "false"      # NID remapping
})
```

## Supported Topologies

| Topology | Description | Key Parameters |
|----------|-------------|----------------|
| mesh | 2D/3D mesh | k (nodes per dimension), n (dimensions) |
| torus | 2D/3D torus | k, n |
| dragonfly | Dragonfly | p (nodes/router), a (routers/group), h (groups), g (global channels) |
| fattree | Fat-tree | k (port count) |
| flatfly_onchip | Flattened butterfly | n (dimensions), k (nodes per dim) |

## Routing Algorithms

| Algorithm | Type | Description |
|-----------|------|-------------|
| dor | Deterministic | Dimension-ordered routing |
| min_adapt | Adaptive | Minimal adaptive routing |
| ugal | Adaptive | Universal globally-adaptive load-balanced |
| valiant | Adaptive | Valiant routing (indirect) |

## Troubleshooting

### Build Errors
```bash
# Check SST-Core installation
sst-config --prefix
sst-config --CXXFLAGS

# Verify configure.m4 is in place
ls /path/to/sst-elements/src/sst/elements/booksim2/configure.m4

# Check autogen output
cd /path/to/sst-elements && ./autogen.sh 2>&1 | grep booksim2
```

### Runtime Errors
```bash
# Check component registration
sst-info | grep -i booksim

# View component details
sst-info booksim2.booksim2

# Check library path
echo $LD_LIBRARY_PATH
ldd $(sst-config --prefix)/lib/libbooksim2.so
```

### Configuration Errors
```bash
# Validate Python syntax
python3 -m py_compile your_config.py

# Run with verbose output
sst --verbose your_config.py
```

## Example Configurations

### Minimal Example
```python
import sst

net = sst.Component("network", "booksim2.booksim2")
net.addParams({
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "num_vcs": 2
})
```

### With Ember/Firefly
See `booksim_example.py` for complete example.

## Environment Setup

```bash
# Add to ~/.bashrc or ~/.zshrc
export SST_HOME=$HOME/local/sst
export PATH=$SST_HOME/bin:$PATH
export LD_LIBRARY_PATH=$SST_HOME/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$SST_HOME/lib/pkgconfig:$PKG_CONFIG_PATH
```

## Resources

- Integration Guide (English): `INTEGRATION.md`
- Integration Guide (Chinese): `INTEGRATION_CN.md`
- Example Configuration: `booksim_example.py`
- Integration Script: `integrate_sst.sh`
- SST Documentation: http://sst-simulator.org/
- BookSim2 Project: https://github.com/booksim/booksim2

## Manual Integration Checklist

If `integrate_sst.sh` cannot be used:

- [ ] Copy booksim2 to `sst-elements/src/sst/elements/booksim2`
- [ ] Add `SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])` to `configure.ac`
- [ ] Add `src/sst/elements/booksim2/Makefile` to `AC_CONFIG_FILES`
- [ ] Add `booksim2` to `SUBDIRS` in `src/sst/elements/Makefile.am`
- [ ] Run `./autogen.sh` in sst-elements directory
- [ ] Run `./configure --prefix=/install/path`
- [ ] Run `make -j$(nproc) && make install`
- [ ] Verify with `sst-info booksim2`

## Version Compatibility

- **SST-Core**: 11.0.0 (tested)
- **SST-Elements**: 11.0.0 (tested)
- **BookSim2**: sst-macro branch
- **Compiler**: GCC 7.0+ or Clang 5.0+ with C++11 support

## Getting Help

1. Check the integration guides: `INTEGRATION.md` or `INTEGRATION_CN.md`
2. Review example: `booksim_example.py`
3. Use `sst-info` for component information
4. Check SST documentation: http://sst-simulator.org/
5. Open an issue on the GitHub repository
