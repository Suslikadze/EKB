
_add_menu main controls right SystemButtonFace black RUN_1uS   {run 1000000}
_add_menu main controls right SystemButtonFace blue RUN_10uS   {run 10000000}
_add_menu main controls right SystemButtonFace red  RUN_100uS  {run 100000000}
_add_menu main controls right SystemButtonFace green RUN_1mS   {run 1000000000}
_add_menu main controls right SystemButtonFace magenta  RUN_10mS   {run 10000000000}
_add_menu main controls right SystemButtonFace yellow  RUN_100mS   {run 100000000000}

onerror {resume}
quietly WaveActivateNextPane {} 0

onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider SYNC_GEN

add wave -position end sim:/tb_ekb_top/EKB_top_0/sync_gen_pix_str_frame_q/qout_clk_IS
add wave -position end sim:/tb_ekb_top/EKB_top_0/sync_gen_pix_str_frame_q/qout_v_IS
add wave -position end sim:/tb_ekb_top/EKB_top_0/sync_gen_pix_str_frame_q/qout_frame_IS
add wave -position end  sim:/tb_ekb_top/EKB_top_0/sync_gen_pix_str_frame_q/stroka_IS
add wave -position end sim:/tb_ekb_top/EKB_top_0/sync_gen_pix_str_frame_q/kadr_IS

add wave -noupdate -divider Image_SEnsor
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/XVS_Imx_Sim
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/XHS_Imx_Sim
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/DATA_IS_pix
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/VALID_DATA
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/gen_pix_str_frame_Inteface/qout_clk
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/gen_pix_str_frame_Inteface/qout_v
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/qout_clk_IS_ch
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/DATA_IS_pix_ch_1
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/DATA_IS_pix_ch_2
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/DATA_IS_pix_ch_3
add wave -position end  sim:/tb_ekb_top/EKB_top_0/IMAGE_SENSOR_SIM_q/IS_SIM_Paralell_q/DATA_IS_pix_ch_4
add wave -noupdate -divider SMPTE_SERDES



add wave -noupdate -divider HSI
