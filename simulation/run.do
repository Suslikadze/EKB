quietly set ACTELLIBNAME ProASIC3L
quietly set PROJECT_DIR "G:/ACTELL/EKB/EKB/Libero"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap proasic3l "C:/Microsemi/Libero_SoC_v11.8/Designer/lib/questa/precompiled/vlog/proasic3l"

vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/my_component_pkg.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/VIDEO_CONSTANTS.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/reset_control.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/smartgen/PLL_0/PLL_0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/smartgen/PLL_1/PLL_1.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/count_n_modul.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/gen_pix_str_frame.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/sync_gen_pix_str_frame.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/parall_to_serial.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/IS_SIM_serial_DDR.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/smartgen/PLL_SIM_IS/PLL_SIM_IS.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/smartgen/PLL_SIM_IS_1/PLL_SIM_IS_1.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/noise_gen.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/PATHERN_GENERATOR.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/TRS_gen.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/IS_SIM_Paralell.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/IMAGE_SENSOR_SIM.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/top.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/stimulus/tb_EKB_top.vhd"

vsim -novopt -L proasic3l -L presynth  -t 1ps presynth.tb_EKB_top
do "${PROJECT_DIR}/wave.do"
run 1000ns
