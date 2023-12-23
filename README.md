# 8259A Programmable Interrupt Controller (PIC) in Verilog

## Overview

This Verilog implementation represents the 8259A Programmable Interrupt Controller (PIC) commonly used in microprocessor-based systems. The design is organized into several main modules, each encapsulating specific functionality, along with their respective internal modules and testbenches.


## Supported Features of the 8259A Programmable Interrupt Controller (PIC)

1. **Eight Priority Levels:**
   - The 8259A supports up to eight levels of interrupt priority, allowing for efficient handling of different interrupt sources.

2. **Cascadable:**
   - Multiple 8259A controllers can be cascaded to expand the number of interrupt levels, allowing for more interrupt sources in the system.

3. **Programmable Interrupt Modes:**
   - The PIC supports different interrupt modes, including edge-triggered and level-triggered modes, providing flexibility in interrupt handling.

4. **Auto EOI (End of Interrupt):**
   - The 8259A supports automatic End of Interrupt operation, simplifying the handling of interrupts by automatically sending the EOI signal to the interrupt controller.

5. **Special Fully Nested Mode:**
   - Special Fully Nested Mode (SFNM) is supported, ensuring that lower priority interrupts are not serviced until higher priority interrupts have been acknowledged.

6. **Buffered Mode:**
   - The PIC can operate in buffered mode, allowing it to temporarily store interrupt requests and release them in a prioritized manner.

7. **Interrupt Request Register (IRR) and In-Service Register (ISR):**
   - The 8259A maintains an Interrupt Request Register (IRR) to keep track of pending interrupt requests and an In-Service Register (ISR) to track interrupts that are currently being serviced.

8. **Priority Resolver:**
   - The PIC includes a priority resolver to determine the highest priority interrupt pending in the system.

9. **Interrupt Masking:**
   - Each interrupt level can be individually masked, allowing the system to disable specific interrupt sources when needed.

10. **Cascade Operation:**
    - The 8259A supports cascading, enabling the connection of multiple PICs to handle a larger number of interrupt sources in complex systems.

11. **Readable Control Registers:**
    - The control registers of the 8259A, including the Interrupt Request Register (IRR) and In-Service Register (ISR), can be read to obtain information about the status of interrupts.

12. **Initialization Commands:**
    - The 8259A can be initialized through a sequence of Initialization Command Words (ICWs) to configure its operating mode, interrupt modes, and other settings.

13. **Fully Static Operation:**
    - The 8259A operates in a fully static mode, meaning it can be stopped and started without losing its configuration or interrupt state.

14. **Interrupt Acknowledge Signals:**
    - The PIC generates interrupt acknowledge signals (INTA) for the CPU to identify the source of the interrupt being serviced.

15. **Daisy-Chaining:**
    - The cascading feature allows multiple 8259A controllers to be connected in a daisy-chain configuration, simplifying the organization of interrupt priorities in large systems.

These features make the 8259A a versatile and widely used component in interrupt handling within computer systems.

## Structure

### **Top Module**
   - The top module integrates the following five main modules:
     -**Control Logic**
     -**Data Bus Control/Buffer**
     -**In Service Register**
     -**Interrupt Request Register**
     -**Priority Resolver**


### **Control Logic**

   - **Acknowledge Module**
   - **Cascade Signals**
   - **Initialization Command Word 4**
   - **Initialization Command Word 1**
   - **Interrupt Control Signals**
   - **Operation Control Word 1**
   - **Operation Control Word 2**
   - **Operation Control Word 3**
     
### **Data Bus Control/Buffer**

   - **Data Bus Buffer**
   - **Data Bus Control**
     
### **In Service Register**

### **Interrupt Request Register**

### **Priority Resolver**

   - **Priority Mask Module**

### **Internal Functions File**
   
  - `Rotate Right`: Performs a right rotation on the input source by the specified number of positions.
  - `Rotate Left`: Performs a left rotation on the input source by the specified number of positions.
  - `Resolve Priority`: Resolves the priority of the input request by converting it to an 8-bit priority value.
  - `num2bit`: Converts a 3-bit number to an 8-bit binary representation.
  - `bit2num`: Converts an 8-bit binary representation to a 3-bit number.

## Testbenches

- Each module includes a testbench to verify its functionality and integration within the system. The testbenches ensure that the implemented modules operate correctly in different scenarios and configurations.
