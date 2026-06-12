# Project Concept: 3-Floor Elevator Controller (MVP)
### A VHDL Finite State Machine on the Digilent Nexys A7-100T, with a Custom PCB Transition Path

**Course:** Hardware Engineering Lab (SS 2026)
**Professor:** Prof. Dr.-Ing. Ali Hayek
**Submission Date:** 11.06.2026

---

## Team Members
- Akter, Suchi
- Boiddo, Sumon
- Nnachi-Egwu, Nnaemeka
- Oyemade, Oluwasholape Daniel

---

## Introduction

Elevator controllers are a classic application of digital control: a small set of asynchronous user inputs must be arbitrated into a safe, deterministic sequence of actions. The decision core of every elevator is a Finite State Machine (FSM), which makes the problem an ideal candidate for an FPGA-based hardware design exercise.

This project implements a **3-floor elevator controller** in VHDL as a **Minimum Viable Product (MVP)**: one call button per floor, timer-modeled motion, and status indication via a 7-segment display and LEDs. The focus lies on clean synchronous design, explicit request arbitration, and correct handling of asynchronous, bouncy inputs.

Development follows a two-phase pipeline:

1. **Phase 1 — FPGA prototype:** simulation, synthesis, and live demonstration entirely on a **Digilent Nexys A7-100T** board. All required inputs and outputs (push buttons, LEDs, 7-segment display, 100 MHz clock) are available on-board — **no external hardware is used in this phase**.
2. **Phase 2 — Custom PCB:** a dedicated standalone board specification that carries the verified design from the multi-purpose development board to application-specific hardware.

The three floors follow German signage convention:

| Floor label | German | English | Internal index |
|:---:|---|---|:---:|
| **1** | 1. Obergeschoss | First floor | `10` |
| **E** | Erdgeschoss | Ground floor | `01` |
| **U** | Untergeschoss | Basement | `00` |

---

## Concept Description

### Target Application

The controller coordinates a single elevator cabin across three floors. Each floor has **one call button**; a press latches a request for that floor. A synchronous FSM arbitrates the pending requests with a starvation-free scheduling policy and drives the status outputs: the current floor character on a 7-segment display, two travel-direction LEDs, and a door-status LED.

### Block Diagram

```mermaid
flowchart TD
    subgraph INPUT["Input Layer — Nexys A7 on-board"]
        direction LR
        CB["Call buttons<br/>BTNU / BTNC / BTND<br/>floors 1 / E / U"]
        RST["Master reset<br/>CPU_RESET button"]
        CLK["100 MHz<br/>oscillator"]
    end

    subgraph CORE["Control Core — VHDL on Artix-7 FPGA"]
        direction LR
        SYNC["Input conditioning<br/>2-FF synchronizer<br/>+ debounce"]
        REQ["Request register<br/>latch on press,<br/>clear on service"]
        FSM["Elevator FSM<br/>+ scheduler"]
        TMR["Travel & door timers<br/>(clock dividers)"]
        DEC["7-segment decoder<br/>U / E / 1"]
    end

    subgraph OUTPUT["Output Layer — Nexys A7 on-board"]
        direction LR
        SEG["7-segment display<br/>digit AN0"]
        UP["LED1<br/>moving up"]
        DN["LED0<br/>moving down"]
        DOOR["LED2<br/>door open"]
    end

    CB --> SYNC
    SYNC --> REQ
    REQ --> FSM
    RST --> FSM
    CLK --> TMR
    TMR --> FSM
    FSM --> TMR
    FSM --> DEC
    DEC --> SEG
    FSM --> UP
    FSM --> DN
    FSM --> DOOR
```

### Board Resource Mapping (Nexys A7-100T)

The table below fixes the pin-level mapping used in the constraints file (`.xdc`):

| Function | On-board resource | Notes |
|---|---|---|
| Call button — floor **1** | Push button `BTNU` | Vertical button layout mirrors floor order |
| Call button — floor **E** | Push button `BTNC` | |
| Call button — floor **U** | Push button `BTND` | |
| Master reset | `CPU_RESET` button | Async assert, sync release (see FSM section) |
| Floor display | 7-segment digit `AN0` | Characters `U` / `E` / `1` |
| Direction up | `LED1` | |
| Direction down | `LED0` | |
| Door open | `LED2` | On only during `DOOR_OPEN` |
| System clock | 100 MHz oscillator `E3` | All logic synchronous to this clock |

---

## Control Logic and State Architecture

### Request Register

Button presses are momentary, but a request must persist until it is served. A 3-bit **request register** (one bit per floor) latches each conditioned button press. A floor's bit is cleared exactly once — when the cabin arrives at that floor and enters `DOOR_OPEN` — so a held or repeated press cannot re-trigger the same trip.

### State Diagram

```mermaid
stateDiagram-v2
    direction LR

    classDef idleStyle fill:#dbe9ff,stroke:#3b6ea5,stroke-width:2px,color:#1a3a5c
    classDef movingStyle fill:#ffe9c7,stroke:#c98a2b,stroke-width:2px,color:#5c3d0e
    classDef doorStyle fill:#d8f3e0,stroke:#2f8f5b,stroke-width:2px,color:#14502f

    state "IDLE" as IDLE
    state "MOVING_UP" as UP
    state "MOVING_DOWN" as DOWN
    state "DOOR_OPEN" as DOOR

    IDLE : LEDs off
    UP : LED1 on
    DOWN : LED0 on
    DOOR : LED2 on

    [*] --> IDLE : reset

    IDLE --> DOOR : call at floor
    IDLE --> UP : call above
    IDLE --> DOWN : call below

    UP --> DOOR : arrived
    DOWN --> DOOR : arrived

    DOOR --> IDLE : no calls left
    DOOR --> UP : call above
    DOOR --> DOWN : call below

    class IDLE idleStyle
    class UP movingStyle
    class DOWN movingStyle
    class DOOR doorStyle
```

The FSM intentionally has **no final state**: an elevator controller runs indefinitely, returning to `IDLE` whenever the request register is empty. The `[*]` marker denotes only the entry point after reset.

| State | Behavior |
|---|---|
| `IDLE` | Cabin stationary at a floor (U, E, or 1), doors closed, awaiting a latched request. All status LEDs off. |
| `MOVING_UP` | Entered when a pending request index is above the current floor index. The travel timer models per-floor transit time; the floor register increments on timer expiry. `LED1` asserted. |
| `MOVING_DOWN` | Mirror of `MOVING_UP` for descent. `LED0` asserted. |
| `DOOR_OPEN` | Cabin holds at the target floor for the door-timer window. `LED2` asserted, the served floor's request bit cleared. On expiry, the scheduler evaluates remaining requests. |

### Scheduling Policy (Direction Priority)

1. **Continue in the current travel direction** while any request remains in that direction (a request at *E* is served on the way during a *U → 1* trip).
2. Only when no requests remain ahead does the controller reverse direction or return to `IDLE`.
3. From `IDLE`, simultaneous requests above and below are resolved nearest-floor-first; an exact tie is broken toward **up**.

Every latched request is therefore served in bounded time.

### Reset Behavior

The master reset is **asynchronously asserted and synchronously released** to avoid recovery metastability. On reset the FSM enters `IDLE`, all request bits are cleared, and the floor register initializes to **U** — demonstrations begin with the (virtual) cabin in the basement.

---

## Technologies

### Hardware Platform

- **Digilent Nexys A7-100T:** Xilinx **Artix-7 XC7A100T** FPGA, 100 MHz oscillator, push buttons, LEDs, and an 8-digit 7-segment display — covering every MVP input and output with zero external components.
- **7-segment display:** common-anode, shared cathode bus. Only one character is shown, so a single digit (`AN0`) is held active — no multiplexing logic required in the MVP.

### Design and Verification Tools

- **VHDL (IEEE 1076):** RTL description of all modules; synchronous FSM design style.
- **Xilinx Vivado:** simulation (XSim), synthesis, implementation, bitstream generation, and on-target debugging (ILA if needed).
- **Self-checking testbenches:** stimulus replay of representative trip patterns with assertion-based result checking, complemented by waveform inspection.

### Timing Design

All timing derives from the 100 MHz board clock via enable-based counters (no derived or gated clocks):

| Timer | Default value | Purpose |
|---|---|---|
| Debounce window | 10 ms | Filters mechanical bounce after the 2-FF synchronizer |
| Travel timer | 2 s per floor | Models transit time between adjacent floors |
| Door timer | 3 s | Models passenger entry/exit window |

All three are VHDL **generics**, shortened by orders of magnitude in simulation so testbenches run in microseconds.

---

## Implementation

### Module Structure

```mermaid
classDiagram
    class elevator_top {
        +clk : 100 MHz
        +btn_call[2:0]
        +cpu_resetn
        +seg[6:0], an[7:0]
        +led_up, led_down, led_door
    }

    class input_conditioner {
        +generic DEBOUNCE_CYCLES
        +sync_2ff()
        +debounce()
        +edge_detect()
    }

    class request_register {
        +req[2:0]
        +latch(floor)
        +clear(floor)
    }

    class elevator_fsm {
        +state : IDLE / UP / DOWN / DOOR
        +current_floor[1:0]
        +schedule() direction
        +next_state_logic()
        +output_logic()
    }

    class timer_unit {
        +generic TRAVEL_CYCLES
        +generic DOOR_CYCLES
        +start(mode)
        +done : std_logic
    }

    class sevenseg_decoder {
        +floor_to_segments(U/E/1)
        +drive_an0()
    }

    elevator_top --> input_conditioner
    elevator_top --> elevator_fsm
    input_conditioner --> request_register
    request_register --> elevator_fsm
    elevator_fsm --> timer_unit
    timer_unit --> elevator_fsm
    elevator_fsm --> sevenseg_decoder
```

### Phase 1: Simulation and FPGA Verification

Minimum test scenarios validated in simulation before programming the board:

| # | Scenario | Expected behavior |
|:---:|---|---|
| 1 | Reset, then call from floor **1** while cabin at **U** | `IDLE → MOVING_UP` (passing E without stopping) `→ DOOR_OPEN` at 1 |
| 2 | Call button for the current floor | Direct `IDLE → DOOR_OPEN`, no movement |
| 3 | Requests at **U** and **1** while cabin at **E** | Nearest-first arbitration; both served, neither starved |
| 4 | New same-direction request arrives mid-travel | Served on the way (direction priority) |
| 5 | Button held down continuously | Exactly one latched request; no re-trigger |
| 6 | Reset asserted during `MOVING_UP` | Immediate return to `IDLE` at U, request register cleared |
| 7 | Bouncy stimulus on all inputs | Debounce yields one clean request per press |

### Phase 2: Custom Application PCB

After FPGA verification, the design migrates to a dedicated standalone PCB:

1. **Power rail infrastructure** — step-down regulators provide a stable **3.3 V** rail for the I/O banks plus the discrete core and auxiliary rails required by the FPGA, with power-up sequencing per the device datasheet.
2. **Decoupling and noise isolation** — decoupling capacitor arrays placed directly at the FPGA power pins (smallest values closest) to absorb switching noise and preserve supply integrity.
3. **Signal conditioning** — defined pull-up/pull-down resistors on every push-button input plus first-order RC filters as analog pre-debouncing, ahead of the digital debounce logic.
4. **Display and LED drive** — 7-segment display and indicator LEDs driven through current-limiting resistors sized within the FPGA I/O drive limits.

---

## Out of Scope (MVP Boundaries)

Separate cabin/hall call interfaces, door obstruction sensors, overload detection, emergency stop and alarm, motor/actuator control (movement is timer-modeled), homing/reference runs, multi-cabin coordination, and destination dispatch optimization.

---

## Results

*To be completed after implementation. Will include simulation waveforms of the test scenarios, resource utilization and timing reports from Vivado, and photos/video of the live demonstration on the Nexys A7-100T.*

---

## Sources / References

- Digilent Nexys A7 Reference Manual — https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual
- Xilinx 7 Series FPGAs Data Sheet (Artix-7) — AMD/Xilinx DS180 / DS181
- Xilinx Vivado Design Suite User Guide
- IEEE Std 1076 — VHDL Language Reference Manual
- Digilent Nexys A7 Master XDC Constraints File — https://github.com/Digilent/digilent-xdc
