
# VGA on Xilinx Artix-7 FPGA

## <u>Project Objectives</u>:

The objective of this project is to design and implement a hardware-level VGA controller at a baseline resolution of 640x480, interface external sensors and utilize FPGA resources to display interactive animations and dynamic graphics on a monitor.

## <u>Project Phases</u>:
### Phase 0: Project Specifications
* Create the initial project documentation (README), plan the project steps, and review the technical datasheets for the VGA timig.

### Phase 1: VGA Controller Design & Simulation (640x480)
* Write Verilog code for VGA timing signals (`HSYNC`, `VSYNC`) and validate waveforms using Vivado Simulator.
  
### Phase 2: Hardware Validation & Static Pattern Generation
* Configure the constraints file (`.xdc`) for the Basys 3 VGA pins and output static test patterns (color bars) to a monitor.
  
### Phase 3: Object Animation ("DVD Screensaver")
* Implement hardware logic to animate a geometric shape (square/circle) that moves and bounces off the screen boundaries.
  
### Phase 4: Display Scaling (Full HD - 1920x1080)
* Recalculate VGA timing parameters and scale the Pixel Clock to support Full HD resolution.
  
### Phase 5: Sensor Integration

* Interface ultrasonic sensor.


