`timescale 1ns / 1ps
`default_nettype none

module ZXUno_PCXT_512KB(
	input  wire				CLK_50MHZ,

	output wire	[2:0]		VGA_R,
	output wire	[2:0]		VGA_G,
	output wire	[2:0]		VGA_B,
	output wire				VGA_HSYNC,
	output wire				VGA_VSYNC,

	output wire				SRAM_WE_n,
	output wire	[18:0]	SRAM_A,
	inout  wire	[7:0]		SRAM_D,

	output wire				uart_rx,
	input  wire				uart_tx,

	inout  wire				clkps2,
	inout  wire				dataps2,

	output wire				AUDIO_L,
	output wire				AUDIO_R,

	output wire				SD_nCS,
	output wire				SD_CK,
	output wire				SD_MOSI,
	input  wire				SD_MISO
	/*
	output	wire					LED,
	inout		wire					PS2CLKA,
	inout		wire					PS2CLKB,
	inout		wire					PS2DATA,
	inout		wire					PS2DATB,
	input		wire					P_A,
	input		wire					P_U,
	input		wire					P_D,
	input		wire					P_L,
	input		wire					P_R,
	input		wire					P_tr
	*/
	);
	
	wire clk_100;
	wire clk_50;
	wire clk_28_571;	
	wire clk_14_815;
	wire clk_3_571;

	dcm dcm_system 
	(
		.CLK_IN1(CLK_50MHZ), 
		.CLK_OUT1(clk_100),
		.CLK_OUT2(clk_50),
		.CLK_OUT3(clk_28_571),
		.CLK_OUT4(clk_14_815),
		.CLK_OUT5(clk_3_571)
	);

	wire spiCk = SD_CK;
	wire spiSs2, spiSs3, spiSs4, spiSsIo, spiMosi, spiMiso;

	wire kbiCk = clkps2; wire kboCk; assign clkps2 = kboCk ? 1'bZ : kboCk;
	wire kbiDQ = dataps2; wire kboDQ; assign dataps2 = kboDQ ? 1'bZ : kboDQ;

	substitute_mcu #(.sysclk_frequency(50)) controller
	(
		.clk          (clk_50 ),
		.reset_in     (1'b1   ),
		.reset_out    (       ),
		.spi_cs       (SD_nCS ),
		.spi_clk      (SD_CK  ),
		.spi_mosi     (SD_MOSI),
		.spi_miso     (SD_MISO),
		.spi_req      (       ),
		.spi_ack      (1'b1   ),
		.spi_ss2      (spiSs2 ),
		.spi_ss3      (spiSs3 ),
		.spi_ss4      (spiSs4 ),
		.spi_srtc     (       ),
		.conf_data0   (spiSsIo),
		.spi_toguest  (spiMosi),
		.spi_fromguest(spiMiso),
		.ps2k_clk_in  (kbiCk  ),
		.ps2k_dat_in  (kbiDQ  ),
		.ps2k_clk_out (kboCk  ),
		.ps2k_dat_out (kboDQ  ),
		.ps2m_clk_in  (1'b0   ),
		.ps2m_dat_in  (1'b0   ),
		.ps2m_clk_out (       ),
		.ps2m_dat_out (       ),
		.joy1         (8'hFF  ),
		.joy2         (8'hFF  ),
		.joy3         (8'hFF  ),
		.joy4         (8'hFF  ),
		.buttons      (8'hFF  ),
		.rxd          (1'b0   ),
		.txd          (       ),
		.intercept    (       ),
		.c64_keys     (64'hFFFFFFFF)
	);

	localparam CONF_STR =
	{
		"PCXT;;",
	//	"F,ROM,Load ROM;",
	//	"S0,VHD,Mount VHD;",
	//	"O3,SD ROM at slot 07,On,Off;",
	//	"T2,Warm Reset;",
	//	"T1,Cold Reset;",
	//	"T9,Reset FPGA;",
		"V,V1.0;"
	};

	wire[63:0] status;

	wire ps2kci, ps2kco;
	wire ps2kdi, ps2kdo;

	user_io #(.STRLEN(13), .SD_IMAGES(1)) user_io
	(
		.conf_str      (CONF_STR),
		.conf_addr     (        ),
		.conf_chr      (8'd0    ),

		.clk_sys       (clk_50  ),
		.clk_sd        (clk_50  ),

		.SPI_CLK       (spiCk   ),
		.SPI_SS_IO     (spiSsIo ),
		.SPI_MOSI      (spiMosi ),
		.SPI_MISO      (spiMiso ),

		.joystick_0    (),
		.joystick_1    (),
		.joystick_2    (),
		.joystick_3    (),
		.joystick_4    (),
		.joystick_analog_0(),
		.joystick_analog_1(),

		.status        (status),
		.buttons       (),
		.switches      (),
		.ypbpr         (),
		.no_csync      (),
		.core_mod      (),
		.scandoubler_disable(),

		.rtc           (),

		.sd_rd         (),
		.sd_wr         (),
		.sd_ack        (),
		.sd_ack_conf   (),
		.sd_lba        (),
		.sd_conf       (),
		.sd_sdhc       (),
		.sd_buff_addr  (),
		.sd_din        (),
		.sd_din_strobe (),
		.sd_dout       (),
		.sd_dout_strobe(),
		.img_size      (),
		.img_mounted   (),

		.ps2_kbd_clk   (ps2kco),
		.ps2_kbd_data  (ps2kdo),
		.ps2_kbd_clk_i (ps2kci),
		.ps2_kbd_data_i(ps2kdi),
		.ps2_mouse_clk (),
		.ps2_mouse_data(),
		.ps2_mouse_clk_i(1'b0),
		.ps2_mouse_data_i(1'b0),

		.key_code      (),
		.key_strobe    (),
		.key_pressed   (),
		.key_extended  (),
		.mouse_x       (),
		.mouse_y       (),
		.mouse_z       (),
		.mouse_idx     (),
		.mouse_flags   (),
		.mouse_strobe  (),

		.serial_data   (8'd0),
		.serial_strobe (1'd0)
	);

	wire[5:0] osdR;
	wire[5:0] osdG;
	wire[5:0] osdB;

	osd #(.OSD_AUTO_CE(1'b1)) osd
	(
		.clk_sys(clk_28_571),
		.ce     (1'b0   ),
		.SPI_SCK(spiCk  ),
		.SPI_SS3(spiSs3 ),
		.SPI_DI (spiMosi),
		.rotate (2'd0   ),
		.VSync  (VGA_VSYNC),
		.HSync  (VGA_HSYNC),
		.R_in   (R      ),
		.G_in   (G      ),
		.B_in   (B      ),
		.R_out  (osdR   ),
		.G_out  (osdG   ),
		.B_out  (osdB   )
	);

	wire [5:0] R;
	wire [5:0] G;
	wire [5:0] B;

	system_512KB sys_inst
	(
		.clk_100(clk_100),
		.clk_chipset(clk_50),
		.clk_vga(clk_28_571),
		.clk_uart(clk_14_815),
		.clk_tandy_snd(clk_3_571),
		
		.VGA_R(R),
		.VGA_G(G),
		.VGA_B(B),
		.VGA_HSYNC(VGA_HSYNC),
		.VGA_VSYNC(VGA_VSYNC),

		.SRAM_ADDR(SRAM_A),
		.SRAM_DATA(SRAM_D),
		.SRAM_WE_n(SRAM_WE_n),

		.uart_rx(uart_tx),
		.uart_tx(uart_rx),

//		.LED(LED),

//		.clkps2(clkps2),
//		.dataps2(dataps2),

		.ps2_data_in(ps2kci),
		.ps2_clock_in(ps2kdi),
		.ps2_data_out(ps2kco),
		.ps2_clock_out(ps2kdo),

		.AUD_L(AUDIO_L),
		.AUD_R(AUDIO_R)

//	 	.PS2_CLK1(PS2CLKA),
//		.PS2_CLK2(PS2CLKB),
//		.PS2_DATA1(PS2DATA),
//		.PS2_DATA2(PS2DATB)

//		.SD_n_CS(SD_nCS),
//		.SD_DI(SD_DI),
//		.SD_CK(SD_CK),
//		.SD_DO(SD_DO),
//		.joy_up(P_U),
//		.joy_down(P_D),
//		.joy_left(P_L),
//		.joy_right(P_R),
//		.joy_fire1(P_tr),
//		.joy_fire2(P_A)
	);

	assign VGA_R = osdR[5:3];
	assign VGA_G = osdG[5:3];
	assign VGA_B = osdB[5:3];

endmodule
