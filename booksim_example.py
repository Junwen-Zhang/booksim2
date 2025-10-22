#!/usr/bin/env python3
"""
Example SST configuration using BookSim2 network simulator

This example demonstrates how to configure BookSim2 as a network component
in SST and connect it with Ember/Firefly endpoints.

To run this example:
    sst booksim_example.py

Prerequisites:
    - SST-Core 11.0.0+
    - SST-Elements with BookSim2 module installed
    - Firefly component (part of SST-Elements)
"""

import sst

# ============================================================================
# Simulation Configuration
# ============================================================================

NUM_NODES = 4
NETWORK_TOPOLOGY = "dragonfly"
ROUTING_FUNCTION = "min_adapt"
NUM_VCS = 2
PACKET_SIZE = 1  # in flits
CLOCK_FREQ = "1GHz"

# ============================================================================
# Create BookSim2 Network Component
# ============================================================================

network = sst.Component("booksim_network", "booksim2.booksim2")
network.addParams({
    "booksim_clock": CLOCK_FREQ,
    "topology": NETWORK_TOPOLOGY,
    "routing_function": ROUTING_FUNCTION,
    "packet_size": PACKET_SIZE,
    "num_vcs": NUM_VCS,
    "num_motif_nodes": NUM_NODES
})

# ============================================================================
# Create Endpoints with BookSimBridge
# ============================================================================

# Note: This example shows the structure but requires Firefly/Ember components
# which may need additional configuration

endpoints = []
bridges = []

for node_id in range(NUM_NODES):
    # Create a simple endpoint (in real scenarios, use Firefly NIC)
    # endpoint = sst.Component(f"endpoint_{node_id}", "firefly.nic")
    
    # For this example, we'll just show the BookSimBridge configuration
    # In practice, you would attach this to a real endpoint component
    
    # Create the bridge as a subcomponent (when using with Firefly)
    # bridge = endpoint.setSubComponent("networkIF", "booksim2.booksimbridge", 0)
    # bridge.addParams({
    #     "job_id": 0,
    #     "Job_size": NUM_NODES,
    #     "logical_nid": node_id,
    #     "use_nid_remap": "false"
    # })
    
    # Connect bridge to network
    # link = sst.Link(f"link_{node_id}")
    # link.connect(
    #     (bridge, "rtr_port", "1ns"),
    #     (network, f"motif_node{node_id}", "1ns")
    # )
    
    pass

# ============================================================================
# Statistics and Output Configuration
# ============================================================================

# Enable statistics collection
sst.setStatisticLoadLevel(5)

# Set output options
sst.setStatisticOutput("sst.statOutputConsole")

# ============================================================================
# Example with Direct Port Connection (Simplified)
# ============================================================================

# This is a simplified example that shows the basic structure
# In a real scenario, you would use this with Ember/Firefly components

print("=" * 70)
print("BookSim2 SST Configuration Example")
print("=" * 70)
print(f"Network Topology: {NETWORK_TOPOLOGY}")
print(f"Routing Function: {ROUTING_FUNCTION}")
print(f"Number of Nodes:  {NUM_NODES}")
print(f"Virtual Channels: {NUM_VCS}")
print(f"Clock Frequency:  {CLOCK_FREQ}")
print("=" * 70)
print("\nNote: This is a basic configuration example.")
print("For full functionality, integrate with Ember/Firefly components.")
print("=" * 70)
