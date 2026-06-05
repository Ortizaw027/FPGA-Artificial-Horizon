module gw_gao(
    \u_Attitude/o_Pitch_Angle[15] ,
    \u_Attitude/o_Pitch_Angle[14] ,
    \u_Attitude/o_Pitch_Angle[13] ,
    \u_Attitude/o_Pitch_Angle[12] ,
    \u_Attitude/o_Pitch_Angle[11] ,
    \u_Attitude/o_Pitch_Angle[10] ,
    \u_Attitude/o_Pitch_Angle[9] ,
    \u_Attitude/o_Pitch_Angle[8] ,
    \u_Attitude/o_Pitch_Angle[7] ,
    \u_Attitude/o_Pitch_Angle[6] ,
    \u_Attitude/o_Pitch_Angle[5] ,
    \u_Attitude/o_Pitch_Angle[4] ,
    \u_Attitude/o_Pitch_Angle[3] ,
    \u_Attitude/o_Pitch_Angle[2] ,
    \u_Attitude/o_Pitch_Angle[1] ,
    \u_Attitude/o_Pitch_Angle[0] ,
    \u_Attitude/o_Roll_Angle[15] ,
    \u_Attitude/o_Roll_Angle[14] ,
    \u_Attitude/o_Roll_Angle[13] ,
    \u_Attitude/o_Roll_Angle[12] ,
    \u_Attitude/o_Roll_Angle[11] ,
    \u_Attitude/o_Roll_Angle[10] ,
    \u_Attitude/o_Roll_Angle[9] ,
    \u_Attitude/o_Roll_Angle[8] ,
    \u_Attitude/o_Roll_Angle[7] ,
    \u_Attitude/o_Roll_Angle[6] ,
    \u_Attitude/o_Roll_Angle[5] ,
    \u_Attitude/o_Roll_Angle[4] ,
    \u_Attitude/o_Roll_Angle[3] ,
    \u_Attitude/o_Roll_Angle[2] ,
    \u_Attitude/o_Roll_Angle[1] ,
    \u_Attitude/o_Roll_Angle[0] ,
    \u_Attitude/o_Cal_Done ,
    \u_Attitude/r_Ax_F[15] ,
    \u_Attitude/r_Ax_F[14] ,
    \u_Attitude/r_Ax_F[13] ,
    \u_Attitude/r_Ax_F[12] ,
    \u_Attitude/r_Ax_F[11] ,
    \u_Attitude/r_Ax_F[10] ,
    \u_Attitude/r_Ax_F[9] ,
    \u_Attitude/r_Ax_F[8] ,
    \u_Attitude/r_Ax_F[7] ,
    \u_Attitude/r_Ax_F[6] ,
    \u_Attitude/r_Ax_F[5] ,
    \u_Attitude/r_Ax_F[4] ,
    \u_Attitude/r_Ax_F[3] ,
    \u_Attitude/r_Ax_F[2] ,
    \u_Attitude/r_Ax_F[1] ,
    \u_Attitude/r_Ax_F[0] ,
    \u_Attitude/r_Ay_F[15] ,
    \u_Attitude/r_Ay_F[14] ,
    \u_Attitude/r_Ay_F[13] ,
    \u_Attitude/r_Ay_F[12] ,
    \u_Attitude/r_Ay_F[11] ,
    \u_Attitude/r_Ay_F[10] ,
    \u_Attitude/r_Ay_F[9] ,
    \u_Attitude/r_Ay_F[8] ,
    \u_Attitude/r_Ay_F[7] ,
    \u_Attitude/r_Ay_F[6] ,
    \u_Attitude/r_Ay_F[5] ,
    \u_Attitude/r_Ay_F[4] ,
    \u_Attitude/r_Ay_F[3] ,
    \u_Attitude/r_Ay_F[2] ,
    \u_Attitude/r_Ay_F[1] ,
    \u_Attitude/r_Ay_F[0] ,
    \u_Attitude/i_Raw_Ax[15] ,
    \u_Attitude/i_Raw_Ax[14] ,
    \u_Attitude/i_Raw_Ax[13] ,
    \u_Attitude/i_Raw_Ax[12] ,
    \u_Attitude/i_Raw_Ax[11] ,
    \u_Attitude/i_Raw_Ax[10] ,
    \u_Attitude/i_Raw_Ax[9] ,
    \u_Attitude/i_Raw_Ax[8] ,
    \u_Attitude/i_Raw_Ax[7] ,
    \u_Attitude/i_Raw_Ax[6] ,
    \u_Attitude/i_Raw_Ax[5] ,
    \u_Attitude/i_Raw_Ax[4] ,
    \u_Attitude/i_Raw_Ax[3] ,
    \u_Attitude/i_Raw_Ax[2] ,
    \u_Attitude/i_Raw_Ax[1] ,
    \u_Attitude/i_Raw_Ax[0] ,
    \u_Attitude/i_Raw_Ay[15] ,
    \u_Attitude/i_Raw_Ay[14] ,
    \u_Attitude/i_Raw_Ay[13] ,
    \u_Attitude/i_Raw_Ay[12] ,
    \u_Attitude/i_Raw_Ay[11] ,
    \u_Attitude/i_Raw_Ay[10] ,
    \u_Attitude/i_Raw_Ay[9] ,
    \u_Attitude/i_Raw_Ay[8] ,
    \u_Attitude/i_Raw_Ay[7] ,
    \u_Attitude/i_Raw_Ay[6] ,
    \u_Attitude/i_Raw_Ay[5] ,
    \u_Attitude/i_Raw_Ay[4] ,
    \u_Attitude/i_Raw_Ay[3] ,
    \u_Attitude/i_Raw_Ay[2] ,
    \u_Attitude/i_Raw_Ay[1] ,
    \u_Attitude/i_Raw_Ay[0] ,
    \u_Attitude/i_Raw_Az[15] ,
    \u_Attitude/i_Raw_Az[14] ,
    \u_Attitude/i_Raw_Az[13] ,
    \u_Attitude/i_Raw_Az[12] ,
    \u_Attitude/i_Raw_Az[11] ,
    \u_Attitude/i_Raw_Az[10] ,
    \u_Attitude/i_Raw_Az[9] ,
    \u_Attitude/i_Raw_Az[8] ,
    \u_Attitude/i_Raw_Az[7] ,
    \u_Attitude/i_Raw_Az[6] ,
    \u_Attitude/i_Raw_Az[5] ,
    \u_Attitude/i_Raw_Az[4] ,
    \u_Attitude/i_Raw_Az[3] ,
    \u_Attitude/i_Raw_Az[2] ,
    \u_Attitude/i_Raw_Az[1] ,
    \u_Attitude/i_Raw_Az[0] ,
    \u_Attitude/i_Raw_Gx[15] ,
    \u_Attitude/i_Raw_Gx[14] ,
    \u_Attitude/i_Raw_Gx[13] ,
    \u_Attitude/i_Raw_Gx[12] ,
    \u_Attitude/i_Raw_Gx[11] ,
    \u_Attitude/i_Raw_Gx[10] ,
    \u_Attitude/i_Raw_Gx[9] ,
    \u_Attitude/i_Raw_Gx[8] ,
    \u_Attitude/i_Raw_Gx[7] ,
    \u_Attitude/i_Raw_Gx[6] ,
    \u_Attitude/i_Raw_Gx[5] ,
    \u_Attitude/i_Raw_Gx[4] ,
    \u_Attitude/i_Raw_Gx[3] ,
    \u_Attitude/i_Raw_Gx[2] ,
    \u_Attitude/i_Raw_Gx[1] ,
    \u_Attitude/i_Raw_Gx[0] ,
    \u_Attitude/i_Raw_Gy[15] ,
    \u_Attitude/i_Raw_Gy[14] ,
    \u_Attitude/i_Raw_Gy[13] ,
    \u_Attitude/i_Raw_Gy[12] ,
    \u_Attitude/i_Raw_Gy[11] ,
    \u_Attitude/i_Raw_Gy[10] ,
    \u_Attitude/i_Raw_Gy[9] ,
    \u_Attitude/i_Raw_Gy[8] ,
    \u_Attitude/i_Raw_Gy[7] ,
    \u_Attitude/i_Raw_Gy[6] ,
    \u_Attitude/i_Raw_Gy[5] ,
    \u_Attitude/i_Raw_Gy[4] ,
    \u_Attitude/i_Raw_Gy[3] ,
    \u_Attitude/i_Raw_Gy[2] ,
    \u_Attitude/i_Raw_Gy[1] ,
    \u_Attitude/i_Raw_Gy[0] ,
    \u_Attitude/i_Raw_Gz[15] ,
    \u_Attitude/i_Raw_Gz[14] ,
    \u_Attitude/i_Raw_Gz[13] ,
    \u_Attitude/i_Raw_Gz[12] ,
    \u_Attitude/i_Raw_Gz[11] ,
    \u_Attitude/i_Raw_Gz[10] ,
    \u_Attitude/i_Raw_Gz[9] ,
    \u_Attitude/i_Raw_Gz[8] ,
    \u_Attitude/i_Raw_Gz[7] ,
    \u_Attitude/i_Raw_Gz[6] ,
    \u_Attitude/i_Raw_Gz[5] ,
    \u_Attitude/i_Raw_Gz[4] ,
    \u_Attitude/i_Raw_Gz[3] ,
    \u_Attitude/i_Raw_Gz[2] ,
    \u_Attitude/i_Raw_Gz[1] ,
    \u_Attitude/i_Raw_Gz[0] ,
    w_IMU_Data_Ready,
    w_Clk_74,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \u_Attitude/o_Pitch_Angle[15] ;
input \u_Attitude/o_Pitch_Angle[14] ;
input \u_Attitude/o_Pitch_Angle[13] ;
input \u_Attitude/o_Pitch_Angle[12] ;
input \u_Attitude/o_Pitch_Angle[11] ;
input \u_Attitude/o_Pitch_Angle[10] ;
input \u_Attitude/o_Pitch_Angle[9] ;
input \u_Attitude/o_Pitch_Angle[8] ;
input \u_Attitude/o_Pitch_Angle[7] ;
input \u_Attitude/o_Pitch_Angle[6] ;
input \u_Attitude/o_Pitch_Angle[5] ;
input \u_Attitude/o_Pitch_Angle[4] ;
input \u_Attitude/o_Pitch_Angle[3] ;
input \u_Attitude/o_Pitch_Angle[2] ;
input \u_Attitude/o_Pitch_Angle[1] ;
input \u_Attitude/o_Pitch_Angle[0] ;
input \u_Attitude/o_Roll_Angle[15] ;
input \u_Attitude/o_Roll_Angle[14] ;
input \u_Attitude/o_Roll_Angle[13] ;
input \u_Attitude/o_Roll_Angle[12] ;
input \u_Attitude/o_Roll_Angle[11] ;
input \u_Attitude/o_Roll_Angle[10] ;
input \u_Attitude/o_Roll_Angle[9] ;
input \u_Attitude/o_Roll_Angle[8] ;
input \u_Attitude/o_Roll_Angle[7] ;
input \u_Attitude/o_Roll_Angle[6] ;
input \u_Attitude/o_Roll_Angle[5] ;
input \u_Attitude/o_Roll_Angle[4] ;
input \u_Attitude/o_Roll_Angle[3] ;
input \u_Attitude/o_Roll_Angle[2] ;
input \u_Attitude/o_Roll_Angle[1] ;
input \u_Attitude/o_Roll_Angle[0] ;
input \u_Attitude/o_Cal_Done ;
input \u_Attitude/r_Ax_F[15] ;
input \u_Attitude/r_Ax_F[14] ;
input \u_Attitude/r_Ax_F[13] ;
input \u_Attitude/r_Ax_F[12] ;
input \u_Attitude/r_Ax_F[11] ;
input \u_Attitude/r_Ax_F[10] ;
input \u_Attitude/r_Ax_F[9] ;
input \u_Attitude/r_Ax_F[8] ;
input \u_Attitude/r_Ax_F[7] ;
input \u_Attitude/r_Ax_F[6] ;
input \u_Attitude/r_Ax_F[5] ;
input \u_Attitude/r_Ax_F[4] ;
input \u_Attitude/r_Ax_F[3] ;
input \u_Attitude/r_Ax_F[2] ;
input \u_Attitude/r_Ax_F[1] ;
input \u_Attitude/r_Ax_F[0] ;
input \u_Attitude/r_Ay_F[15] ;
input \u_Attitude/r_Ay_F[14] ;
input \u_Attitude/r_Ay_F[13] ;
input \u_Attitude/r_Ay_F[12] ;
input \u_Attitude/r_Ay_F[11] ;
input \u_Attitude/r_Ay_F[10] ;
input \u_Attitude/r_Ay_F[9] ;
input \u_Attitude/r_Ay_F[8] ;
input \u_Attitude/r_Ay_F[7] ;
input \u_Attitude/r_Ay_F[6] ;
input \u_Attitude/r_Ay_F[5] ;
input \u_Attitude/r_Ay_F[4] ;
input \u_Attitude/r_Ay_F[3] ;
input \u_Attitude/r_Ay_F[2] ;
input \u_Attitude/r_Ay_F[1] ;
input \u_Attitude/r_Ay_F[0] ;
input \u_Attitude/i_Raw_Ax[15] ;
input \u_Attitude/i_Raw_Ax[14] ;
input \u_Attitude/i_Raw_Ax[13] ;
input \u_Attitude/i_Raw_Ax[12] ;
input \u_Attitude/i_Raw_Ax[11] ;
input \u_Attitude/i_Raw_Ax[10] ;
input \u_Attitude/i_Raw_Ax[9] ;
input \u_Attitude/i_Raw_Ax[8] ;
input \u_Attitude/i_Raw_Ax[7] ;
input \u_Attitude/i_Raw_Ax[6] ;
input \u_Attitude/i_Raw_Ax[5] ;
input \u_Attitude/i_Raw_Ax[4] ;
input \u_Attitude/i_Raw_Ax[3] ;
input \u_Attitude/i_Raw_Ax[2] ;
input \u_Attitude/i_Raw_Ax[1] ;
input \u_Attitude/i_Raw_Ax[0] ;
input \u_Attitude/i_Raw_Ay[15] ;
input \u_Attitude/i_Raw_Ay[14] ;
input \u_Attitude/i_Raw_Ay[13] ;
input \u_Attitude/i_Raw_Ay[12] ;
input \u_Attitude/i_Raw_Ay[11] ;
input \u_Attitude/i_Raw_Ay[10] ;
input \u_Attitude/i_Raw_Ay[9] ;
input \u_Attitude/i_Raw_Ay[8] ;
input \u_Attitude/i_Raw_Ay[7] ;
input \u_Attitude/i_Raw_Ay[6] ;
input \u_Attitude/i_Raw_Ay[5] ;
input \u_Attitude/i_Raw_Ay[4] ;
input \u_Attitude/i_Raw_Ay[3] ;
input \u_Attitude/i_Raw_Ay[2] ;
input \u_Attitude/i_Raw_Ay[1] ;
input \u_Attitude/i_Raw_Ay[0] ;
input \u_Attitude/i_Raw_Az[15] ;
input \u_Attitude/i_Raw_Az[14] ;
input \u_Attitude/i_Raw_Az[13] ;
input \u_Attitude/i_Raw_Az[12] ;
input \u_Attitude/i_Raw_Az[11] ;
input \u_Attitude/i_Raw_Az[10] ;
input \u_Attitude/i_Raw_Az[9] ;
input \u_Attitude/i_Raw_Az[8] ;
input \u_Attitude/i_Raw_Az[7] ;
input \u_Attitude/i_Raw_Az[6] ;
input \u_Attitude/i_Raw_Az[5] ;
input \u_Attitude/i_Raw_Az[4] ;
input \u_Attitude/i_Raw_Az[3] ;
input \u_Attitude/i_Raw_Az[2] ;
input \u_Attitude/i_Raw_Az[1] ;
input \u_Attitude/i_Raw_Az[0] ;
input \u_Attitude/i_Raw_Gx[15] ;
input \u_Attitude/i_Raw_Gx[14] ;
input \u_Attitude/i_Raw_Gx[13] ;
input \u_Attitude/i_Raw_Gx[12] ;
input \u_Attitude/i_Raw_Gx[11] ;
input \u_Attitude/i_Raw_Gx[10] ;
input \u_Attitude/i_Raw_Gx[9] ;
input \u_Attitude/i_Raw_Gx[8] ;
input \u_Attitude/i_Raw_Gx[7] ;
input \u_Attitude/i_Raw_Gx[6] ;
input \u_Attitude/i_Raw_Gx[5] ;
input \u_Attitude/i_Raw_Gx[4] ;
input \u_Attitude/i_Raw_Gx[3] ;
input \u_Attitude/i_Raw_Gx[2] ;
input \u_Attitude/i_Raw_Gx[1] ;
input \u_Attitude/i_Raw_Gx[0] ;
input \u_Attitude/i_Raw_Gy[15] ;
input \u_Attitude/i_Raw_Gy[14] ;
input \u_Attitude/i_Raw_Gy[13] ;
input \u_Attitude/i_Raw_Gy[12] ;
input \u_Attitude/i_Raw_Gy[11] ;
input \u_Attitude/i_Raw_Gy[10] ;
input \u_Attitude/i_Raw_Gy[9] ;
input \u_Attitude/i_Raw_Gy[8] ;
input \u_Attitude/i_Raw_Gy[7] ;
input \u_Attitude/i_Raw_Gy[6] ;
input \u_Attitude/i_Raw_Gy[5] ;
input \u_Attitude/i_Raw_Gy[4] ;
input \u_Attitude/i_Raw_Gy[3] ;
input \u_Attitude/i_Raw_Gy[2] ;
input \u_Attitude/i_Raw_Gy[1] ;
input \u_Attitude/i_Raw_Gy[0] ;
input \u_Attitude/i_Raw_Gz[15] ;
input \u_Attitude/i_Raw_Gz[14] ;
input \u_Attitude/i_Raw_Gz[13] ;
input \u_Attitude/i_Raw_Gz[12] ;
input \u_Attitude/i_Raw_Gz[11] ;
input \u_Attitude/i_Raw_Gz[10] ;
input \u_Attitude/i_Raw_Gz[9] ;
input \u_Attitude/i_Raw_Gz[8] ;
input \u_Attitude/i_Raw_Gz[7] ;
input \u_Attitude/i_Raw_Gz[6] ;
input \u_Attitude/i_Raw_Gz[5] ;
input \u_Attitude/i_Raw_Gz[4] ;
input \u_Attitude/i_Raw_Gz[3] ;
input \u_Attitude/i_Raw_Gz[2] ;
input \u_Attitude/i_Raw_Gz[1] ;
input \u_Attitude/i_Raw_Gz[0] ;
input w_IMU_Data_Ready;
input w_Clk_74;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \u_Attitude/o_Pitch_Angle[15] ;
wire \u_Attitude/o_Pitch_Angle[14] ;
wire \u_Attitude/o_Pitch_Angle[13] ;
wire \u_Attitude/o_Pitch_Angle[12] ;
wire \u_Attitude/o_Pitch_Angle[11] ;
wire \u_Attitude/o_Pitch_Angle[10] ;
wire \u_Attitude/o_Pitch_Angle[9] ;
wire \u_Attitude/o_Pitch_Angle[8] ;
wire \u_Attitude/o_Pitch_Angle[7] ;
wire \u_Attitude/o_Pitch_Angle[6] ;
wire \u_Attitude/o_Pitch_Angle[5] ;
wire \u_Attitude/o_Pitch_Angle[4] ;
wire \u_Attitude/o_Pitch_Angle[3] ;
wire \u_Attitude/o_Pitch_Angle[2] ;
wire \u_Attitude/o_Pitch_Angle[1] ;
wire \u_Attitude/o_Pitch_Angle[0] ;
wire \u_Attitude/o_Roll_Angle[15] ;
wire \u_Attitude/o_Roll_Angle[14] ;
wire \u_Attitude/o_Roll_Angle[13] ;
wire \u_Attitude/o_Roll_Angle[12] ;
wire \u_Attitude/o_Roll_Angle[11] ;
wire \u_Attitude/o_Roll_Angle[10] ;
wire \u_Attitude/o_Roll_Angle[9] ;
wire \u_Attitude/o_Roll_Angle[8] ;
wire \u_Attitude/o_Roll_Angle[7] ;
wire \u_Attitude/o_Roll_Angle[6] ;
wire \u_Attitude/o_Roll_Angle[5] ;
wire \u_Attitude/o_Roll_Angle[4] ;
wire \u_Attitude/o_Roll_Angle[3] ;
wire \u_Attitude/o_Roll_Angle[2] ;
wire \u_Attitude/o_Roll_Angle[1] ;
wire \u_Attitude/o_Roll_Angle[0] ;
wire \u_Attitude/o_Cal_Done ;
wire \u_Attitude/r_Ax_F[15] ;
wire \u_Attitude/r_Ax_F[14] ;
wire \u_Attitude/r_Ax_F[13] ;
wire \u_Attitude/r_Ax_F[12] ;
wire \u_Attitude/r_Ax_F[11] ;
wire \u_Attitude/r_Ax_F[10] ;
wire \u_Attitude/r_Ax_F[9] ;
wire \u_Attitude/r_Ax_F[8] ;
wire \u_Attitude/r_Ax_F[7] ;
wire \u_Attitude/r_Ax_F[6] ;
wire \u_Attitude/r_Ax_F[5] ;
wire \u_Attitude/r_Ax_F[4] ;
wire \u_Attitude/r_Ax_F[3] ;
wire \u_Attitude/r_Ax_F[2] ;
wire \u_Attitude/r_Ax_F[1] ;
wire \u_Attitude/r_Ax_F[0] ;
wire \u_Attitude/r_Ay_F[15] ;
wire \u_Attitude/r_Ay_F[14] ;
wire \u_Attitude/r_Ay_F[13] ;
wire \u_Attitude/r_Ay_F[12] ;
wire \u_Attitude/r_Ay_F[11] ;
wire \u_Attitude/r_Ay_F[10] ;
wire \u_Attitude/r_Ay_F[9] ;
wire \u_Attitude/r_Ay_F[8] ;
wire \u_Attitude/r_Ay_F[7] ;
wire \u_Attitude/r_Ay_F[6] ;
wire \u_Attitude/r_Ay_F[5] ;
wire \u_Attitude/r_Ay_F[4] ;
wire \u_Attitude/r_Ay_F[3] ;
wire \u_Attitude/r_Ay_F[2] ;
wire \u_Attitude/r_Ay_F[1] ;
wire \u_Attitude/r_Ay_F[0] ;
wire \u_Attitude/i_Raw_Ax[15] ;
wire \u_Attitude/i_Raw_Ax[14] ;
wire \u_Attitude/i_Raw_Ax[13] ;
wire \u_Attitude/i_Raw_Ax[12] ;
wire \u_Attitude/i_Raw_Ax[11] ;
wire \u_Attitude/i_Raw_Ax[10] ;
wire \u_Attitude/i_Raw_Ax[9] ;
wire \u_Attitude/i_Raw_Ax[8] ;
wire \u_Attitude/i_Raw_Ax[7] ;
wire \u_Attitude/i_Raw_Ax[6] ;
wire \u_Attitude/i_Raw_Ax[5] ;
wire \u_Attitude/i_Raw_Ax[4] ;
wire \u_Attitude/i_Raw_Ax[3] ;
wire \u_Attitude/i_Raw_Ax[2] ;
wire \u_Attitude/i_Raw_Ax[1] ;
wire \u_Attitude/i_Raw_Ax[0] ;
wire \u_Attitude/i_Raw_Ay[15] ;
wire \u_Attitude/i_Raw_Ay[14] ;
wire \u_Attitude/i_Raw_Ay[13] ;
wire \u_Attitude/i_Raw_Ay[12] ;
wire \u_Attitude/i_Raw_Ay[11] ;
wire \u_Attitude/i_Raw_Ay[10] ;
wire \u_Attitude/i_Raw_Ay[9] ;
wire \u_Attitude/i_Raw_Ay[8] ;
wire \u_Attitude/i_Raw_Ay[7] ;
wire \u_Attitude/i_Raw_Ay[6] ;
wire \u_Attitude/i_Raw_Ay[5] ;
wire \u_Attitude/i_Raw_Ay[4] ;
wire \u_Attitude/i_Raw_Ay[3] ;
wire \u_Attitude/i_Raw_Ay[2] ;
wire \u_Attitude/i_Raw_Ay[1] ;
wire \u_Attitude/i_Raw_Ay[0] ;
wire \u_Attitude/i_Raw_Az[15] ;
wire \u_Attitude/i_Raw_Az[14] ;
wire \u_Attitude/i_Raw_Az[13] ;
wire \u_Attitude/i_Raw_Az[12] ;
wire \u_Attitude/i_Raw_Az[11] ;
wire \u_Attitude/i_Raw_Az[10] ;
wire \u_Attitude/i_Raw_Az[9] ;
wire \u_Attitude/i_Raw_Az[8] ;
wire \u_Attitude/i_Raw_Az[7] ;
wire \u_Attitude/i_Raw_Az[6] ;
wire \u_Attitude/i_Raw_Az[5] ;
wire \u_Attitude/i_Raw_Az[4] ;
wire \u_Attitude/i_Raw_Az[3] ;
wire \u_Attitude/i_Raw_Az[2] ;
wire \u_Attitude/i_Raw_Az[1] ;
wire \u_Attitude/i_Raw_Az[0] ;
wire \u_Attitude/i_Raw_Gx[15] ;
wire \u_Attitude/i_Raw_Gx[14] ;
wire \u_Attitude/i_Raw_Gx[13] ;
wire \u_Attitude/i_Raw_Gx[12] ;
wire \u_Attitude/i_Raw_Gx[11] ;
wire \u_Attitude/i_Raw_Gx[10] ;
wire \u_Attitude/i_Raw_Gx[9] ;
wire \u_Attitude/i_Raw_Gx[8] ;
wire \u_Attitude/i_Raw_Gx[7] ;
wire \u_Attitude/i_Raw_Gx[6] ;
wire \u_Attitude/i_Raw_Gx[5] ;
wire \u_Attitude/i_Raw_Gx[4] ;
wire \u_Attitude/i_Raw_Gx[3] ;
wire \u_Attitude/i_Raw_Gx[2] ;
wire \u_Attitude/i_Raw_Gx[1] ;
wire \u_Attitude/i_Raw_Gx[0] ;
wire \u_Attitude/i_Raw_Gy[15] ;
wire \u_Attitude/i_Raw_Gy[14] ;
wire \u_Attitude/i_Raw_Gy[13] ;
wire \u_Attitude/i_Raw_Gy[12] ;
wire \u_Attitude/i_Raw_Gy[11] ;
wire \u_Attitude/i_Raw_Gy[10] ;
wire \u_Attitude/i_Raw_Gy[9] ;
wire \u_Attitude/i_Raw_Gy[8] ;
wire \u_Attitude/i_Raw_Gy[7] ;
wire \u_Attitude/i_Raw_Gy[6] ;
wire \u_Attitude/i_Raw_Gy[5] ;
wire \u_Attitude/i_Raw_Gy[4] ;
wire \u_Attitude/i_Raw_Gy[3] ;
wire \u_Attitude/i_Raw_Gy[2] ;
wire \u_Attitude/i_Raw_Gy[1] ;
wire \u_Attitude/i_Raw_Gy[0] ;
wire \u_Attitude/i_Raw_Gz[15] ;
wire \u_Attitude/i_Raw_Gz[14] ;
wire \u_Attitude/i_Raw_Gz[13] ;
wire \u_Attitude/i_Raw_Gz[12] ;
wire \u_Attitude/i_Raw_Gz[11] ;
wire \u_Attitude/i_Raw_Gz[10] ;
wire \u_Attitude/i_Raw_Gz[9] ;
wire \u_Attitude/i_Raw_Gz[8] ;
wire \u_Attitude/i_Raw_Gz[7] ;
wire \u_Attitude/i_Raw_Gz[6] ;
wire \u_Attitude/i_Raw_Gz[5] ;
wire \u_Attitude/i_Raw_Gz[4] ;
wire \u_Attitude/i_Raw_Gz[3] ;
wire \u_Attitude/i_Raw_Gz[2] ;
wire \u_Attitude/i_Raw_Gz[1] ;
wire \u_Attitude/i_Raw_Gz[0] ;
wire w_IMU_Data_Ready;
wire w_Clk_74;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(w_IMU_Data_Ready),
    .data_i({\u_Attitude/o_Pitch_Angle[15] ,\u_Attitude/o_Pitch_Angle[14] ,\u_Attitude/o_Pitch_Angle[13] ,\u_Attitude/o_Pitch_Angle[12] ,\u_Attitude/o_Pitch_Angle[11] ,\u_Attitude/o_Pitch_Angle[10] ,\u_Attitude/o_Pitch_Angle[9] ,\u_Attitude/o_Pitch_Angle[8] ,\u_Attitude/o_Pitch_Angle[7] ,\u_Attitude/o_Pitch_Angle[6] ,\u_Attitude/o_Pitch_Angle[5] ,\u_Attitude/o_Pitch_Angle[4] ,\u_Attitude/o_Pitch_Angle[3] ,\u_Attitude/o_Pitch_Angle[2] ,\u_Attitude/o_Pitch_Angle[1] ,\u_Attitude/o_Pitch_Angle[0] ,\u_Attitude/o_Roll_Angle[15] ,\u_Attitude/o_Roll_Angle[14] ,\u_Attitude/o_Roll_Angle[13] ,\u_Attitude/o_Roll_Angle[12] ,\u_Attitude/o_Roll_Angle[11] ,\u_Attitude/o_Roll_Angle[10] ,\u_Attitude/o_Roll_Angle[9] ,\u_Attitude/o_Roll_Angle[8] ,\u_Attitude/o_Roll_Angle[7] ,\u_Attitude/o_Roll_Angle[6] ,\u_Attitude/o_Roll_Angle[5] ,\u_Attitude/o_Roll_Angle[4] ,\u_Attitude/o_Roll_Angle[3] ,\u_Attitude/o_Roll_Angle[2] ,\u_Attitude/o_Roll_Angle[1] ,\u_Attitude/o_Roll_Angle[0] ,\u_Attitude/o_Cal_Done ,\u_Attitude/r_Ax_F[15] ,\u_Attitude/r_Ax_F[14] ,\u_Attitude/r_Ax_F[13] ,\u_Attitude/r_Ax_F[12] ,\u_Attitude/r_Ax_F[11] ,\u_Attitude/r_Ax_F[10] ,\u_Attitude/r_Ax_F[9] ,\u_Attitude/r_Ax_F[8] ,\u_Attitude/r_Ax_F[7] ,\u_Attitude/r_Ax_F[6] ,\u_Attitude/r_Ax_F[5] ,\u_Attitude/r_Ax_F[4] ,\u_Attitude/r_Ax_F[3] ,\u_Attitude/r_Ax_F[2] ,\u_Attitude/r_Ax_F[1] ,\u_Attitude/r_Ax_F[0] ,\u_Attitude/r_Ay_F[15] ,\u_Attitude/r_Ay_F[14] ,\u_Attitude/r_Ay_F[13] ,\u_Attitude/r_Ay_F[12] ,\u_Attitude/r_Ay_F[11] ,\u_Attitude/r_Ay_F[10] ,\u_Attitude/r_Ay_F[9] ,\u_Attitude/r_Ay_F[8] ,\u_Attitude/r_Ay_F[7] ,\u_Attitude/r_Ay_F[6] ,\u_Attitude/r_Ay_F[5] ,\u_Attitude/r_Ay_F[4] ,\u_Attitude/r_Ay_F[3] ,\u_Attitude/r_Ay_F[2] ,\u_Attitude/r_Ay_F[1] ,\u_Attitude/r_Ay_F[0] ,\u_Attitude/i_Raw_Ax[15] ,\u_Attitude/i_Raw_Ax[14] ,\u_Attitude/i_Raw_Ax[13] ,\u_Attitude/i_Raw_Ax[12] ,\u_Attitude/i_Raw_Ax[11] ,\u_Attitude/i_Raw_Ax[10] ,\u_Attitude/i_Raw_Ax[9] ,\u_Attitude/i_Raw_Ax[8] ,\u_Attitude/i_Raw_Ax[7] ,\u_Attitude/i_Raw_Ax[6] ,\u_Attitude/i_Raw_Ax[5] ,\u_Attitude/i_Raw_Ax[4] ,\u_Attitude/i_Raw_Ax[3] ,\u_Attitude/i_Raw_Ax[2] ,\u_Attitude/i_Raw_Ax[1] ,\u_Attitude/i_Raw_Ax[0] ,\u_Attitude/i_Raw_Ay[15] ,\u_Attitude/i_Raw_Ay[14] ,\u_Attitude/i_Raw_Ay[13] ,\u_Attitude/i_Raw_Ay[12] ,\u_Attitude/i_Raw_Ay[11] ,\u_Attitude/i_Raw_Ay[10] ,\u_Attitude/i_Raw_Ay[9] ,\u_Attitude/i_Raw_Ay[8] ,\u_Attitude/i_Raw_Ay[7] ,\u_Attitude/i_Raw_Ay[6] ,\u_Attitude/i_Raw_Ay[5] ,\u_Attitude/i_Raw_Ay[4] ,\u_Attitude/i_Raw_Ay[3] ,\u_Attitude/i_Raw_Ay[2] ,\u_Attitude/i_Raw_Ay[1] ,\u_Attitude/i_Raw_Ay[0] ,\u_Attitude/i_Raw_Az[15] ,\u_Attitude/i_Raw_Az[14] ,\u_Attitude/i_Raw_Az[13] ,\u_Attitude/i_Raw_Az[12] ,\u_Attitude/i_Raw_Az[11] ,\u_Attitude/i_Raw_Az[10] ,\u_Attitude/i_Raw_Az[9] ,\u_Attitude/i_Raw_Az[8] ,\u_Attitude/i_Raw_Az[7] ,\u_Attitude/i_Raw_Az[6] ,\u_Attitude/i_Raw_Az[5] ,\u_Attitude/i_Raw_Az[4] ,\u_Attitude/i_Raw_Az[3] ,\u_Attitude/i_Raw_Az[2] ,\u_Attitude/i_Raw_Az[1] ,\u_Attitude/i_Raw_Az[0] ,\u_Attitude/i_Raw_Gx[15] ,\u_Attitude/i_Raw_Gx[14] ,\u_Attitude/i_Raw_Gx[13] ,\u_Attitude/i_Raw_Gx[12] ,\u_Attitude/i_Raw_Gx[11] ,\u_Attitude/i_Raw_Gx[10] ,\u_Attitude/i_Raw_Gx[9] ,\u_Attitude/i_Raw_Gx[8] ,\u_Attitude/i_Raw_Gx[7] ,\u_Attitude/i_Raw_Gx[6] ,\u_Attitude/i_Raw_Gx[5] ,\u_Attitude/i_Raw_Gx[4] ,\u_Attitude/i_Raw_Gx[3] ,\u_Attitude/i_Raw_Gx[2] ,\u_Attitude/i_Raw_Gx[1] ,\u_Attitude/i_Raw_Gx[0] ,\u_Attitude/i_Raw_Gy[15] ,\u_Attitude/i_Raw_Gy[14] ,\u_Attitude/i_Raw_Gy[13] ,\u_Attitude/i_Raw_Gy[12] ,\u_Attitude/i_Raw_Gy[11] ,\u_Attitude/i_Raw_Gy[10] ,\u_Attitude/i_Raw_Gy[9] ,\u_Attitude/i_Raw_Gy[8] ,\u_Attitude/i_Raw_Gy[7] ,\u_Attitude/i_Raw_Gy[6] ,\u_Attitude/i_Raw_Gy[5] ,\u_Attitude/i_Raw_Gy[4] ,\u_Attitude/i_Raw_Gy[3] ,\u_Attitude/i_Raw_Gy[2] ,\u_Attitude/i_Raw_Gy[1] ,\u_Attitude/i_Raw_Gy[0] ,\u_Attitude/i_Raw_Gz[15] ,\u_Attitude/i_Raw_Gz[14] ,\u_Attitude/i_Raw_Gz[13] ,\u_Attitude/i_Raw_Gz[12] ,\u_Attitude/i_Raw_Gz[11] ,\u_Attitude/i_Raw_Gz[10] ,\u_Attitude/i_Raw_Gz[9] ,\u_Attitude/i_Raw_Gz[8] ,\u_Attitude/i_Raw_Gz[7] ,\u_Attitude/i_Raw_Gz[6] ,\u_Attitude/i_Raw_Gz[5] ,\u_Attitude/i_Raw_Gz[4] ,\u_Attitude/i_Raw_Gz[3] ,\u_Attitude/i_Raw_Gz[2] ,\u_Attitude/i_Raw_Gz[1] ,\u_Attitude/i_Raw_Gz[0] }),
    .clk_i(w_Clk_74)
);

endmodule
