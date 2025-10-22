# BookSim2 SST-Elements Integration - File Summary

This document provides an overview of all files created for integrating BookSim2 into SST-Elements.

## Core Integration Files

### configure.m4
**Purpose:** Autoconf macro for SST-Elements to detect and configure BookSim2  
**Location:** Repository root  
**Usage:** Automatically included by SST-Elements' configure system  
**Key Features:**
- Defines `SST_booksim2_CONFIG` macro
- Checks for BookSim2 headers
- Sets up CPPFLAGS and LDFLAGS
- Conditional compilation support

### Makefile.am
**Purpose:** Automake build configuration for BookSim2  
**Location:** Repository root  
**Usage:** Processed by automake to generate Makefile.in  
**Key Features:**
- Defines library name: `libbooksim2.la`
- Lists all source and header files
- Sets compilation flags (SINGLE_CYCLE, DGB_ON)
- Creates shared library module

## Source Code Files

### booksim2.h / booksim2.cc
**Purpose:** Main SST component for BookSim2 network simulator  
**Component Name:** `booksim2.booksim2`  
**Key Features:**
- Registers as SST Component
- Manages network topology and routing
- Handles clock and time management
- Interfaces with traffic manager

### booksimBridge.h / booksimBridge.cc
**Purpose:** Bridge interface between Firefly NIC and BookSim network  
**Component Name:** `booksim2.booksimbridge`  
**Key Features:**
- Implements SimpleNetwork interface
- Handles packet queuing and credits
- Manages virtual networks
- Collects statistics (latency, bandwidth, stalls)

### booksimInterface.h / booksimInterface.cc
**Purpose:** Internal interface between bridge and traffic manager  
**Component Name:** `booksim2.booksiminterface`  
**Key Features:**
- SubComponent of BookSim2 main component
- Routes events between bridges and simulator
- Manages multiple endpoint connections

## Documentation Files

### INTEGRATION.md (5.8 KB)
**Purpose:** Detailed English integration guide  
**Target Audience:** Developers integrating BookSim2 into SST-Elements  
**Contents:**
- Prerequisites and requirements
- Step-by-step integration instructions
- Component architecture explanation
- Usage examples
- Troubleshooting guide
- Parameter reference

### INTEGRATION_CN.md (7.8 KB)
**Purpose:** Detailed Chinese integration guide (中文集成指南)  
**Target Audience:** Chinese-speaking developers  
**Contents:**
- Same structure as INTEGRATION.md
- Fully translated to Chinese
- Cultural context for Chinese users
- Complete parameter documentation in Chinese

### QUICKREF.md (6.1 KB)
**Purpose:** Quick reference guide  
**Target Audience:** Users familiar with SST who need quick lookup  
**Contents:**
- 3-step quick start
- Component architecture diagram
- Common parameters table
- Topology and routing reference
- Troubleshooting commands
- Environment setup

### TUTORIAL.md (10.3 KB)
**Purpose:** Complete step-by-step tutorial (bilingual)  
**Target Audience:** New users, includes both English and Chinese  
**Contents:**
- Complete environment setup
- Detailed installation steps
- Both automatic and manual integration
- Build and verification procedures
- Multiple usage examples
- Advanced configuration
- Comprehensive troubleshooting

### README.md (Updated)
**Purpose:** Project overview with SST integration section  
**Contents:**
- Original BookSim2 description
- SST-Macro integration section
- Quick start instructions
- Component list
- Example usage snippet

## Tool Files

### integrate_sst.sh (6.2 KB)
**Purpose:** Automated integration script  
**Usage:** `./integrate_sst.sh --sst-elements /path/to/sst-elements`  
**Features:**
- Colored output for clarity
- Interactive prompts for safety
- Automatic backup creation
- Validates directory structure
- Updates configure.ac
- Updates Makefile.am
- Provides next steps

**What it does:**
1. Copies BookSim2 to SST-Elements
2. Updates configure.ac with SST_CHECK_ELEMENT
3. Adds Makefile to AC_CONFIG_FILES
4. Updates src/sst/elements/Makefile.am
5. Creates backups of modified files
6. Displays build instructions

## Example Files

### booksim.py (459 bytes)
**Purpose:** Minimal BookSim2 configuration example  
**Usage:** `sst booksim.py`  
**Features:**
- Shows basic component creation
- Demonstrates parameter setting
- Simple dragonfly topology example

### booksim_example.py (3.5 KB)
**Purpose:** Complete configuration example with documentation  
**Usage:** `sst booksim_example.py`  
**Features:**
- Configuration variables at top
- Shows network component setup
- Bridge configuration example (commented)
- Statistics configuration
- Detailed comments explaining each section
- Example with multiple topologies

## Configuration Files

### .gitignore (Updated)
**Purpose:** Exclude build artifacts and temporary files  
**Additions:**
- SST-specific generated files (.deps/, .libs/)
- Autotools artifacts (*.in, *.la, *.lo)
- Build artifacts (Makefile, config.*)
- Backup files (*.bak, *.orig)

## Directory Structure

```
booksim2/
├── configure.m4                 # SST-Elements configuration macro
├── Makefile.am                  # Build configuration
├── integrate_sst.sh             # Integration automation script
├── .gitignore                   # Git ignore rules
│
├── Documentation
│   ├── README.md                # Project overview
│   ├── INTEGRATION.md           # Detailed English guide
│   ├── INTEGRATION_CN.md        # Detailed Chinese guide
│   ├── QUICKREF.md              # Quick reference
│   ├── TUTORIAL.md              # Step-by-step tutorial
│   └── LICENSE.md               # License information
│
├── Examples
│   ├── booksim.py               # Minimal example
│   └── booksim_example.py       # Complete example
│
├── Source Code
│   ├── booksim2.h               # Main component header
│   ├── booksim2.cc              # Main component implementation
│   ├── booksimBridge.h          # Bridge header
│   ├── booksimBridge.cc         # Bridge implementation
│   ├── booksimInterface.h       # Interface header
│   ├── booksimInterface.cc      # Interface implementation
│   └── src/                     # BookSim2 core source
│
└── Configuration Files
    ├── runfiles/                # BookSim configuration examples
    └── doc/                     # Additional documentation
```

## File Relationships

```
Integration Flow:
configure.m4 → SST-Elements configure.ac → SST-Elements Makefile
                                          ↓
                                    Makefile.am → Build libbooksim2.la
                                          ↓
                                    SST Component Registry
                                          ↓
                            [booksim2.booksim2 component available]
                                          ↓
                                    Python Config Files
                                    (booksim.py, etc.)
```

## Usage Flow for Users

```
User's Journey:

1. Read README.md (Overview)
   ↓
2. Choose integration method:
   
   A. Quick Path:
      - Read QUICKREF.md
      - Run integrate_sst.sh
      - Follow on-screen instructions
   
   B. Detailed Path:
      - Read TUTORIAL.md
      - Follow step-by-step
      - Manual or automatic integration
   
   C. Reference Path:
      - Read INTEGRATION.md (English)
      - Or INTEGRATION_CN.md (Chinese)
      - Complete reference information
   ↓
3. Build SST-Elements with BookSim2
   ↓
4. Use examples:
   - Start with booksim.py
   - Advance to booksim_example.py
   - Customize for your needs
   ↓
5. Troubleshoot (if needed):
   - Check QUICKREF.md troubleshooting
   - Check TUTORIAL.md advanced section
   - Refer to INTEGRATION.md details
```

## File Size Summary

| File | Size | Type |
|------|------|------|
| configure.m4 | 1.7 KB | Config |
| Makefile.am | 3.4 KB | Config |
| integrate_sst.sh | 6.2 KB | Tool |
| booksim2.h | 6.0 KB | Source |
| booksim2.cc | 51 KB | Source |
| booksimBridge.h | 7.5 KB | Source |
| booksimBridge.cc | 13 KB | Source |
| booksimInterface.h | 1.7 KB | Source |
| booksimInterface.cc | 5.0 KB | Source |
| INTEGRATION.md | 5.8 KB | Docs |
| INTEGRATION_CN.md | 7.8 KB | Docs |
| QUICKREF.md | 6.1 KB | Docs |
| TUTORIAL.md | 10.3 KB | Docs |
| README.md | 2.8 KB | Docs |
| booksim.py | 459 B | Example |
| booksim_example.py | 3.5 KB | Example |

**Total Documentation:** ~38 KB  
**Total Configuration/Tools:** ~11 KB  
**Total Examples:** ~4 KB

## Key Concepts

### Component Hierarchy
```
SST Component
    └── booksim2.booksim2
         └── BookSimInterface (SubComponent)
              └── booksim2.booksiminterface

SST SimpleNetwork Interface
    └── booksim2.booksimbridge (SubComponent)
```

### Integration Points

1. **SST-Elements Build System**
   - configure.m4 provides detection
   - Makefile.am provides build rules

2. **SST Component Registry**
   - SST_ELI_REGISTER_COMPONENT macro
   - SST_ELI_REGISTER_SUBCOMPONENT macros

3. **Python Configuration**
   - sst.Component() API
   - setSubComponent() API
   - addParams() API

## Verification Checklist

After integration, verify these files exist in SST-Elements:

- [ ] src/sst/elements/booksim2/configure.m4
- [ ] src/sst/elements/booksim2/Makefile.am
- [ ] src/sst/elements/booksim2/booksim2.h
- [ ] src/sst/elements/booksim2/booksim2.cc
- [ ] src/sst/elements/booksim2/booksimBridge.h
- [ ] src/sst/elements/booksim2/booksimBridge.cc
- [ ] src/sst/elements/booksim2/booksimInterface.h
- [ ] src/sst/elements/booksim2/booksimInterface.cc
- [ ] src/sst/elements/booksim2/src/ (all BookSim2 source)
- [ ] configure.ac contains SST_CHECK_ELEMENT([booksim2], ...)
- [ ] configure.ac contains src/sst/elements/booksim2/Makefile
- [ ] src/sst/elements/Makefile.am contains booksim2 in SUBDIRS

## Success Criteria

Integration is successful when:

1. `sst-info booksim2` shows all three components
2. Example Python scripts load without errors
3. SST can instantiate booksim2.booksim2 component
4. Bridge and interface subcomponents are available
5. Network simulation runs without crashes

## Support and Maintenance

For issues or questions:
- Check troubleshooting sections in documentation
- Review example files for correct usage
- Open issues on GitHub repository
- Contact SST community for SST-specific questions
- Contact BookSim2 community for BookSim-specific questions

---

Last Updated: 2025-10-22  
Version: 1.0  
Compatible with: SST-Core 11.0.0, SST-Elements 11.0.0
