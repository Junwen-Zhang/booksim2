BookSim Interconnection Network Simulator
=========================================

BookSim is a cycle-accurate interconnection network simulator.
Originally developed for and introduced with the [Principles and Practices of Interconnection Networks](http://cva.stanford.edu/books/ppin/) book, its functionality has since been continuously extended.
The current major release, BookSim 2.0, supports a wide range of topologies such as mesh, torus and flattened butterfly networks, provides diverse routing algorithms and includes numerous options for customizing the network's router microarchitecture.

---

If you use BookSim in your research, we would appreciate the following citation in any publications to which it has contributed:

Nan Jiang, Daniel U. Becker, George Michelogiannakis, James Balfour, Brian Towles, John Kim and William J. Dally. A Detailed and Flexible Cycle-Accurate Network-on-Chip Simulator. In *Proceedings of the 2013 IEEE International Symposium on Performance Analysis of Systems and Software*, 2013.


---

## SST-Macro Integration (sst-macro branch)

This branch provides integration with the SST (Structural Simulation Toolkit) simulator version 11.0.0. BookSim2 can be registered as a module in SST-Elements to work with Ember and Firefly components.

### Quick Start

To integrate BookSim2 into SST-Elements:

1. **Automated Integration** (Recommended):
   ```bash
   ./integrate_sst.sh --sst-elements /path/to/sst-elements
   ```

2. **Manual Integration**:
   - Copy this directory to `sst-elements/src/sst/elements/booksim2`
   - Update `configure.ac` to add `SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])`
   - Update `src/sst/elements/Makefile.am` to include `booksim2` in SUBDIRS
   - Run `./autogen.sh && ./configure && make && make install`

3. **Verify Installation**:
   ```bash
   sst-info booksim2
   ```

For detailed instructions, see [INTEGRATION.md](INTEGRATION.md).

### SST Components

- **booksim2.booksim2**: Main network simulator component
- **booksim2.booksimbridge**: Interface between Firefly NIC and BookSim
- **booksim2.booksiminterface**: Internal interface to traffic manager

### Example Usage

```python
import sst

network = sst.Component("booksim_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "num_vcs": 2
})
```

---

## Booksim_Hans
Hans Kasan - CSNL KAIST

These files are modified:
1. flatfly_onchip.cpp
    - Fixed find_ran_intm: Add conditions when the source and destination routers are located at the same row and column.
    - Removed unnecessary assertions: (_xcount == _ycount) and (_xrouter = _yrouter)
2. iq_router.cpp
    - Added SINGLE_CYCLE macro to use single-cycle router.
3. traffic.cpp
    - Added bad_flatfly - worst case traffic for 1D flattened butterfly.
