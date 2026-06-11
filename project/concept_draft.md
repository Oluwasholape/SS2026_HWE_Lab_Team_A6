# Project Concept Draft: 3-Floor Elevator Controller (MVP)

**Course:** Hardware Engineering Lab (SS 2026)  
**Professor:** Prof. Dr.-Ing. Ali Hayek  
**Submission Date:** 11.06.2026  

---

## 1. Project Overview
This project introduces the high-level design, specifications, and design choices for a digital **3-Floor Elevator Controller** implemented in VHDL. The project follows the structured transition pipeline from an initial FPGA-based hardware simulation to a custom, specific Printed Circuit Board (PCB) evaluation setup, stripping away non-essential elements from commercial prototype architectures to establish a lean development model.

To satisfy baseline constraints and ensure focus on the core engineering architecture, this design is intentionally constrained as a **Minimum Viable Product (MVP)**. The controller targets automated coordination across three separate floors designated as **K** (Keller / Basement), **E** (Erdgeschoss / Ground Floor), and **1** (1. Obergeschoss / First Floor). [cite_start]It tracks internal elevator cabin commands alongside external floor requests, manages logical transition state prioritization using a Finite State Machine (FSM), and routes operational updates out to standard user-facing status indicators.

---

## 2. System Architecture Requirements

### 2.1 Hardware User Inputs
 **Inner Cabin Interface (3x Tactile Switches):** Dedicated manual input switches corresponding directly to destination Floor **K**, Floor **E**, and Floor **1** to let current passengers input their target destination.
 **Outer Hallway Interface (3x Tactile Switches):** External hallway call buttons situated at each floor environment to allow waiting users to summon the lift cabin to their active floor location (**K**, **E**, or **1**).
 **Global System Reset (1x Button):** Hardware override that forces an asynchronous hardware reset condition, safely routing the elevator cabin back down to Floor **K** into a stationary, idle configuration mode.

### 2.2 Hardware User Outputs
**7-Segment Display Panel:** A hardware-driven alphanumeric segment readout to display characters (**"K"**, **"E"**, or **"1"**) representing the precise active floor location of the cabin assembly.
**Direction Indicators (2x LEDs):** Visual indicator diodes showing active vertical travel vectors (one LED dedicated to mapping the *MOVING_UP* vector, and another mapping the *MOVING_DOWN* vector).
**Door Safety Indicator (1x LED):** High-visibility status LED mapping structural door operations. This light activates exclusively during passenger entry and exit states (when the doors are open) and turns completely off during live travel phases.

---

## 3. High-Level Block Diagram
[ Central Control Logic ]                 [ Hardware User Outputs ]
========================                  =========================                 =========================
Cabin Buttons (K, E, 1) ---+
Hall Call Buttons       ---+---> [ Antiglitch / Debounce ] ---> [ VHDL FSM Core ] ---> Direction LEDs (Up / Down)
Master Reset Switch     ---+                                                      ---> Door Safety Indicator LED
System Clock Reference  ---------------------------------------------------------> ---> Alphanumeric 7-Segment Display

---

## 4. VHDL Control Logic & State Architecture
The control core is structured as a Synchronous Finite State Machine (FSM). The structural block process tracks four distinct primary machine states:
* **IDLE:** The cabin remains static at a specific floor track (**K**, **E**, or **1**) awaiting a registered call request from the internal or external network.
* **MOVING_UP:** Triggered when pending request indexes are greater than the current floor index; drives direction states and counts timer constraints between floors.
* **MOVING_DOWN:** Triggered when pending request indexes are below the current floor index; commands mechanical descend simulation.
* **DOOR_OPEN:** Pauses the system execution stack at a target floor station for a defined sequence window to simulate door operations before clearing active floor registers and evaluating next queue indexes.

---

## 5. Implementation & PCB Synthesis Blueprint

### 5.1 Phase 1: Prototype Simulation
The control parameters are described in behavioral VHDL models compiled in Xilinx Vivado. Verification steps use localized testbenches mimicking standard trip patterns (such as initializing a Floor **1** call command while resting inside a Floor **K** state position) to capture logic validation data over behavioral analysis waveforms prior to hardware target programming.

### 5.2 Phase 2: Custom Application PCB Specification
To transition the model from the multi-purpose prototype board to custom hardware, a dedicated standalone PCB blueprint is organized according to engineering recommendations:
1. **Power Rail Infrastructure:** Voltage step-down regulators convert incoming input current into stable 3.3V power rails for I/O banks, alongside required discrete power rails for the standalone FPGA processor core logic.
2. **Decoupling & Noise Isolation:** Dedicated arrays of decoupling capacitors are positioned directly adjacent to physical FPGA power pins to absorb switching noise and preserve signal stability.
3. **Signal Conditioning Layout:** Hardware inputs require physical pull-up or pull-down resistor layouts to establish solid logic states, combined with basic resistor-capacitor filters to debounce tactile interface switches effectively.
