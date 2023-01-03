# Romulus N 1.3 Implementation in RTL VHDL using LWC API (Work in Progress)

## Simplified Diagram of Romulus N Datapath
![Image is Simplified Romulus N Diagram](/RomulusNSimplified.jpg)

## Background
This project was taken on as part of ECE 646 (Applied Cryptography) at George Mason University. At first, the project was divided into two parts where one implementation was done through the use of RTL VHDL (my part) and through the use of a High Level Synthesis Translation tool to generate RTL VHDL from a modified version of the reference implementation. Afterwards the plan was to compare the utilization and throughput of both of these implementations. However due to the time constraints of the semester, we limited the scope of the project to the RTL VHDL which I had gained significant progess in due to my large experience in writing RTL VHDL from undergraduate studies. This was not the case for HLS as we both did not have any experience at all with using both LegUp or the Vivado HLS tools for any kind of generation of RTL VHDL.

## Team Members
* Aadam Dirie (Developed RTL VHDL and Designs as seen in Repository)
* Hawa Dirie (Worked on Modification of Reference Implementation for attempted HLS)

## Current Progress/Working State

The current pdfs and other files (except for VHDL) outline results/assumptions/verifications that were not updated since the end of 2021. As of right now, the [CipherCore_Datapath_TB.vhd](6_verification/CipherCore_Datapath_TB.vhd) verifies for 2 even blocks of associated data the correct output which outlines that the [datapath.vhd](5_source_code/datapath.vhd) is mostly correct. However, more work needs to be done to ensure that it also is correct for blocks of message and of course ciphertext. The verification to this point has been aided by my newly modified version of the Romulus 1.3 authors python implementation [Skinny_128_384_plus.py](/SKINNY_128_384_plus.py). Modifications were done in order to clearly debug more in depth especially to see if round functions and resultant values of internal state were accurate to make it easier to determine any hardware implementation inaccuracies/errors.

## Next Steps
* Verify [CipherCore_Datapath_TB.vhd](6_verification/CipherCore_Datapath_TB.vhd)
* Finish design of ASM Chart for Main [Controller](/5_source_code/controller.vhd) and export to draw.io and subsequently in VHDL
* Verify [Controller](/5_source_code/controller.vhd) behavior
* Finish [CryptoCore](/5_source_code/CryptoCore.vhd) wrappper with [Datapath](/5_source_code/datapath.vhd) and [Controller](/5_source_code/controller.vhd)
* Connect [CryptoCore](/5_source_code/CryptoCore.vhd) with LWC API
* Once Fully Verified, work on making implementation resistant to side channel attacks

## File Tree Structure
```
.
├── 1_assumptions
│   └── assumptions.pdf
├── 2_blockdiagrams
│   ├── A_detailed
│   │   ├── RomulusN1_3_diagramsdetailed.drawio
│   │   └── RomulusN1_3_diagramsdetailed.pdf
│   └── B_simplified
│       ├── Romulus_N_simplified.drawio
│       └── Romulus_N_simplified.drawio.pdf
├── 3_interface
│   ├── Romulus_N1_3_interface.drawio
│   └── Romulus_N1_3_interface.drawio.pdf
├── 4_ASM_charts
│   ├── Prelim_ASM_Controller_chart.pdf
│   ├── RomulusN1_3_ASM.drawio
│   └── RomulusN1_3_ASM.drawio.pdf
├── 5_source_code
│   ├── AddConstants.vhd
│   ├── AddRoundTweakey.vhd
│   ├── controller.vhd
│   ├── CryptoCore.vhd
│   ├── datapath.vhd
│   ├── E_K_controller_tb.vhd
│   ├── E_K_controller.vhd
│   ├── EK_Skinnyromn.vhd
│   ├── E_K.vhd
│   ├── E_K_wrapper.vhd
│   ├── gs.vhd
│   ├── LFSRD.vhd
│   ├── MixColumns.vhd
│   ├── nrotk.vhd
│   ├── rho.vhd
│   ├── sbox_col.vhd
│   ├── sbox.vhd
│   ├── ShiftRows.vhd
│   ├── SubCellsRom.vhd
│   ├── SubCells.vhd
│   └── updateTK.vhd
├── 6_verification
│   ├── CipherCore_Datapath_TB.vhd
│   ├── E_K_controller_tb.vhd
│   ├── ROMULUS_N.py
│   ├── SKINNY_128_384_plus.py
│   └── verification.pdf
├── 7_timing_analysis
│   └── timing.pdf
├── 8_results
│   ├── cnstrnt.xdc
│   ├── datapath_utilization_placed.rpt
│   ├── datapath_utilization_synth.rpt
│   └── results.pdf
├── implementationreports
│   ├── datapath_bus_skew_routed.pb
│   ├── datapath_bus_skew_routed.rpt
│   ├── datapath_bus_skew_routed.rpx
│   ├── datapath_clock_utilization_routed.rpt
│   ├── datapath_control_sets_placed.rpt
│   ├── datapath_drc_opted.pb
│   ├── datapath_drc_opted.rpt
│   ├── datapath_drc_opted.rpx
│   ├── datapath_drc_routed.pb
│   ├── datapath_drc_routed.rpt
│   ├── datapath_drc_routed.rpx
│   ├── datapath_io_placed.rpt
│   ├── datapath_methodology_drc_routed.pb
│   ├── datapath_methodology_drc_routed.rpt
│   ├── datapath_methodology_drc_routed.rpx
│   ├── datapath_opt.dcp
│   ├── datapath_physopt.dcp
│   ├── datapath_placed.dcp
│   ├── datapath_power_routed.rpt
│   ├── datapath_power_routed.rpx
│   ├── datapath_power_summary_routed.pb
│   ├── datapath_routed.dcp
│   ├── datapath_route_status.pb
│   ├── datapath_route_status.rpt
│   ├── datapath.tcl
│   ├── datapath_timing_summary_routed.pb
│   ├── datapath_timing_summary_routed.rpt
│   ├── datapath_timing_summary_routed.rpx
│   ├── datapath_utilization_placed.pb
│   ├── datapath_utilization_placed.rpt
│   ├── datapath.vdi
│   ├── gen_run.xml
│   ├── htr.txt
│   ├── init_design.pb
│   ├── ISEWrap.js
│   ├── ISEWrap.sh
│   ├── opt_design.pb
│   ├── phys_opt_design.pb
│   ├── place_design.pb
│   ├── project.wdf
│   ├── route_design.pb
│   ├── rundef.js
│   ├── runme.bat
│   ├── runme.log
│   ├── runme.sh
│   ├── vivado.jou
│   └── vivado.pb
├── README.md
├── ROMULUS_N.py
├── SKINNY_128_384_plus.py
├── synthesisreports
│   ├── datapath.dcp
│   ├── datapath.tcl
│   ├── datapath_utilization_synth.pb
│   ├── datapath_utilization_synth.rpt
│   ├── datapath.vds
│   ├── gen_run.xml
│   ├── htr.txt
│   ├── ISEWrap.js
│   ├── ISEWrap.sh
│   ├── rundef.js
│   ├── runme.bat
│   ├── runme.log
│   ├── runme.sh
│   ├── __synthesis_is_complete__
│   ├── vivado.jou
│   └── vivado.pb
```