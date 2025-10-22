# BookSim2 SST-Elements Integration - Validation Checklist

Use this checklist to verify that BookSim2 has been correctly integrated into SST-Elements.

## Pre-Integration Verification

### Repository Files
- [x] `configure.m4` exists and contains `SST_booksim2_CONFIG` macro
- [x] `Makefile.am` exists and defines `libbooksim2.la`
- [x] `integrate_sst.sh` exists and is executable (chmod +x)
- [x] Component headers exist: `booksim2.h`, `booksimBridge.h`, `booksimInterface.h`
- [x] Component sources exist: `booksim2.cc`, `booksimBridge.cc`, `booksimInterface.cc`
- [x] `src/` directory contains all BookSim2 source files
- [x] Documentation exists: `INTEGRATION.md`, `INTEGRATION_CN.md`, etc.
- [x] Examples exist: `booksim.py`, `booksim_example.py`

### Component Registration
Check component headers contain proper SST registration:

```bash
# Main component
grep "SST_ELI_REGISTER_COMPONENT" booksim2.h
# Should show: booksim2, "booksim2", "booksim2"

# Bridge subcomponent
grep "SST_ELI_REGISTER_SUBCOMPONENT_DERIVED" booksimBridge.h
# Should show: BookSimBridge, "booksim2", "booksimbridge"

# Interface subcomponent
grep "SST_ELI_REGISTER_SUBCOMPONENT_DERIVED" booksimInterface.h
# Should show: BookSimInterface, "booksim2", "booksiminterface"
```

## Integration Steps Verification

### Step 1: Copy Files
- [ ] BookSim2 copied to `sst-elements/src/sst/elements/booksim2/`
- [ ] All source files present in destination
- [ ] `configure.m4` present in destination
- [ ] `Makefile.am` present in destination

### Step 2: Update configure.ac
- [ ] `sst-elements/configure.ac` contains:
  ```autoconf
  SST_CHECK_ELEMENT([booksim2], [booksim2], [], [])
  ```
- [ ] `AC_CONFIG_FILES` section contains:
  ```autoconf
  src/sst/elements/booksim2/Makefile
  ```

### Step 3: Update Makefile.am
- [ ] `sst-elements/src/sst/elements/Makefile.am` contains:
  ```makefile
  SUBDIRS = \
      ...
      booksim2 \
      ...
  ```

### Step 4: Run autogen.sh
```bash
cd /path/to/sst-elements
./autogen.sh
```
- [ ] autogen.sh completes without errors
- [ ] No error messages mentioning booksim2
- [ ] `configure` script is generated
- [ ] `src/sst/elements/booksim2/Makefile.in` is created

### Step 5: Configure
```bash
./configure --prefix=/install/path --with-sst-core=/sst-core/path
```
- [ ] configure completes without errors
- [ ] Output shows "checking for booksim2... yes" or similar
- [ ] `src/sst/elements/booksim2/Makefile` is created

### Step 6: Build
```bash
make -j$(nproc)
```
- [ ] Build completes without errors related to booksim2
- [ ] `libbooksim2.la` is created
- [ ] `.libs/libbooksim2.so` is created

### Step 7: Install
```bash
make install
```
- [ ] Install completes without errors
- [ ] `libbooksim2.so` is in `$PREFIX/lib/`
- [ ] Component info files are installed

## Post-Installation Verification

### Environment Setup
```bash
export PATH=/install/path/bin:$PATH
export LD_LIBRARY_PATH=/install/path/lib:$LD_LIBRARY_PATH
```
- [ ] `sst` command is available
- [ ] `sst-info` command is available
- [ ] Library path is correct

### Component Registration Check

#### List all components
```bash
sst-info | grep -i booksim
```
Expected output:
- [ ] Shows `booksim2` in the list

#### Check main component
```bash
sst-info booksim2.booksim2
```
Expected output:
- [ ] Component Name: booksim2.booksim2
- [ ] Version: 1.0.0
- [ ] Shows parameters: booksim_clock, topology, routing_function, etc.
- [ ] Shows category: COMPONENT_CATEGORY_NETWORK

#### Check bridge subcomponent
```bash
sst-info booksim2.booksimbridge
```
Expected output:
- [ ] SubComponent Name: booksim2.booksimbridge
- [ ] Version: 1.0.0
- [ ] Shows parameters: port_name, job_id, logical_nid, etc.
- [ ] Shows ports: rtr_port
- [ ] Shows statistics: packet_latency, send_bit_count, etc.

#### Check interface subcomponent
```bash
sst-info booksim2.booksiminterface
```
Expected output:
- [ ] SubComponent Name: booksim2.booksiminterface
- [ ] Version: 1.0.0
- [ ] Shows parameters: num_motif_nodes
- [ ] Shows ports: motif_node%(num_motif_nodes)d

### Library Verification
```bash
ldd /install/path/lib/libbooksim2.so
```
- [ ] No "not found" errors
- [ ] Shows libsst-core.so
- [ ] Shows standard C/C++ libraries

### Python Configuration Test

Create `test_minimal.py`:
```python
import sst

network = sst.Component("test_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "dragonfly",
    "routing_function": "min_adapt",
    "num_vcs": 2,
    "packet_size": 1,
    "num_motif_nodes": 0
})
```

Run test:
```bash
sst test_minimal.py
```
- [ ] Script runs without errors
- [ ] No "component not found" errors
- [ ] No Python import errors

### Example Files Test

#### Test booksim.py
```bash
sst booksim.py
```
- [ ] Runs without errors
- [ ] Creates component successfully

#### Test booksim_example.py
```bash
sst booksim_example.py
```
- [ ] Runs without errors
- [ ] Shows configuration summary

## Functional Verification

### Basic Simulation Test
Create `test_functional.py`:
```python
import sst

NUM_NODES = 2

network = sst.Component("network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": "1GHz",
    "topology": "mesh",
    "k": 2,
    "n": 2,
    "routing_function": "dor",
    "num_vcs": 1,
    "packet_size": 1,
    "num_motif_nodes": NUM_NODES
})

# Note: Full test requires Ember/Firefly components
```

Run:
```bash
sst test_functional.py
```
- [ ] Simulation starts
- [ ] No segmentation faults
- [ ] No unhandled exceptions

## Documentation Verification

### Check all documentation files are present
- [ ] README.md (with SST section)
- [ ] INTEGRATION.md (English guide)
- [ ] INTEGRATION_CN.md (Chinese guide)
- [ ] QUICKREF.md (Quick reference)
- [ ] TUTORIAL.md (Tutorial)
- [ ] FILES.md (File summary)
- [ ] LICENSE.md

### Documentation Quality Check
- [ ] No broken links in documentation
- [ ] Code examples are syntactically correct
- [ ] Paths and commands are accurate
- [ ] Version numbers are correct (11.0.0)

## Troubleshooting Tests

### Test 1: Component Not Found
If `sst-info booksim2` fails:
```bash
# Check installation
ls -l /install/path/lib/libbooksim2.*

# Check library path
echo $LD_LIBRARY_PATH

# Add to path if needed
export LD_LIBRARY_PATH=/install/path/lib:$LD_LIBRARY_PATH
```

### Test 2: Build Errors
If compilation fails:
```bash
# Check SST-Core
sst-config --prefix
sst-config --CXXFLAGS

# Check for booksim2 in configure output
./configure --with-sst-core=/sst-core/path 2>&1 | grep -i booksim
```

### Test 3: Runtime Errors
If simulation crashes:
```bash
# Run with verbose output
sst --verbose test.py

# Check for missing symbols
nm -D /install/path/lib/libbooksim2.so | grep SST
```

## Performance Verification

### Sanity Checks
- [ ] Simulation starts within 5 seconds
- [ ] Memory usage is reasonable (< 1GB for small networks)
- [ ] No memory leaks (run with valgrind if available)

### Integration with Ember/Firefly
If Ember and Firefly are available:
- [ ] Can create Ember traffic generator
- [ ] Can create Firefly NIC
- [ ] Can connect BookSimBridge to Firefly
- [ ] Can connect BookSimBridge to BookSim network
- [ ] Traffic flows through network
- [ ] Statistics are collected

## Cleanup Verification

### Check for unwanted files
In SST-Elements after build:
- [ ] No `.o` files in src/sst/elements/booksim2/
- [ ] No `.lo` files committed
- [ ] No `.la` files committed (except after install)
- [ ] No backup files (*.bak, *.orig)

### .gitignore Check
Verify these are ignored:
- [ ] .deps/
- [ ] .libs/
- [ ] *.o
- [ ] *.lo
- [ ] *.la (before install)
- [ ] Makefile (generated)
- [ ] .dirstamp

## Final Checklist

### Required for Basic Functionality
- [ ] Component registers successfully
- [ ] sst-info shows component information
- [ ] Simple Python config runs without errors
- [ ] Library loads without missing dependencies

### Required for Full Functionality
- [ ] Can integrate with Ember/Firefly
- [ ] Can simulate network traffic
- [ ] Statistics are collected
- [ ] Multiple topologies work

### Required for Distribution
- [ ] All documentation is complete and accurate
- [ ] Examples work correctly
- [ ] Integration script works
- [ ] No hardcoded paths in files
- [ ] License information is included

## Sign-off

Date: _______________

Verified by: _______________

Notes:
_________________________________________________
_________________________________________________
_________________________________________________

## Quick Verification Script

Save as `verify_integration.sh`:

```bash
#!/bin/bash

echo "=== BookSim2 Integration Verification ==="
echo ""

# Check sst-info
echo "Checking component registration..."
if sst-info booksim2.booksim2 > /dev/null 2>&1; then
    echo "✓ booksim2.booksim2 registered"
else
    echo "✗ booksim2.booksim2 NOT registered"
fi

if sst-info booksim2.booksimbridge > /dev/null 2>&1; then
    echo "✓ booksim2.booksimbridge registered"
else
    echo "✗ booksim2.booksimbridge NOT registered"
fi

if sst-info booksim2.booksiminterface > /dev/null 2>&1; then
    echo "✓ booksim2.booksiminterface registered"
else
    echo "✗ booksim2.booksiminterface NOT registered"
fi

# Check library
echo ""
echo "Checking library..."
LIB=$(find ${SST_HOME:-/usr/local}/lib -name "libbooksim2.so" 2>/dev/null | head -1)
if [ -n "$LIB" ]; then
    echo "✓ Library found: $LIB"
else
    echo "✗ Library NOT found"
fi

# Check documentation
echo ""
echo "Checking documentation..."
DOCS="INTEGRATION.md INTEGRATION_CN.md QUICKREF.md TUTORIAL.md"
for doc in $DOCS; do
    if [ -f "$doc" ]; then
        echo "✓ $doc exists"
    else
        echo "✗ $doc missing"
    fi
done

echo ""
echo "=== Verification Complete ==="
```

Run: `chmod +x verify_integration.sh && ./verify_integration.sh`
