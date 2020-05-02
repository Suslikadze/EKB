----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Wed Apr 29 14:18:59 2020
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: tb_EKB_top.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::ProASIC3L> <Die::A3PE3000L> <Package::484 FBGA>
-- Author: <Name>
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity tb_EKB_top is
end tb_EKB_top;

architecture behavioral of tb_EKB_top is

    constant SYSCLK_PERIOD : time := 13 ns; -- 76.9231MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    component EKB_top
        -- ports
        port( 
		--IMX_252_first--
        IMX_1_XHS		:in std_logic;  
        IMX_1_XVS		:in std_logic;  
        IMX_1_XCLR		:out std_logic;  
        IMX_1_SCK		:out std_logic;  
        IMX_1_SDI		:out std_logic;  
        IMX_1_SDO		:out std_logic;  
        IMX_1_XCE		:out std_logic;  
        IMX_1_INCK		:out std_logic;  
        IMX_1_XTRIG		:out std_logic;  
        IMX_1_CH_0_P	:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX 1
        IMX_1_CH_0_N	:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX 1
        IMX_1_CH_1_P	:in std_logic_vector(0 to 0);	-- channel 1 DDR IMX 1
        IMX_1_CH_1_N	:in std_logic_vector(0 to 0);	-- channel 1 DDR IMX 1
        IMX_1_CH_2_P	:in std_logic_vector(0 to 0);	-- channel 2 DDR IMX 1
        IMX_1_CH_2_N	:in std_logic_vector(0 to 0);	-- channel 2 DDR IMX 1
        IMX_1_CH_3_P	:in std_logic_vector(0 to 0);	-- channel 3 DDR IMX 1
        IMX_1_CH_3_N	:in std_logic_vector(0 to 0);	-- channel 4 DDR IMX 1
        IMX_1_CLK_P		:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX CLK 
        IMX_1_CLK_N		:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX CLK 
            --IMX_252_second--	
        IMX_2_XHS		:in std_logic;  
        IMX_2_XVS		:in std_logic;  
        IMX_2_XCLR		:out std_logic;  
        IMX_2_SCK		:out std_logic;  
        IMX_2_SDI		:out std_logic;  
        IMX_2_SDO		:out std_logic;  
        IMX_2_XCE		:out std_logic;  
        IMX_2_INCK		:out std_logic;  
        IMX_2_XTRIG		:out std_logic;  
        IMX_2_CH_0_P	:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX 2
        IMX_2_CH_0_N	:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX 2
        IMX_2_CH_1_P	:in std_logic_vector(0 to 0);	-- channel 1 DDR IMX 2
        IMX_2_CH_1_N	:in std_logic_vector(0 to 0);	-- channel 1 DDR IMX 2
        IMX_2_CH_2_P	:in std_logic_vector(0 to 0);	-- channel 2 DDR IMX 2
        IMX_2_CH_2_N	:in std_logic_vector(0 to 0);	-- channel 2 DDR IMX 2
        IMX_2_CH_3_P	:in std_logic_vector(0 to 0);	-- channel 3 DDR IMX 2
        IMX_2_CH_3_N	:in std_logic_vector(0 to 0);	-- channel 3 DDR IMX 2
        IMX_2_CLK_P		:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX CLK 
        IMX_2_CLK_N		:in std_logic_vector(0 to 0);	-- channel 0 DDR IMX CLK 
            --ADV7343--	
        DAC_Y			:out std_logic_vector(7 downto 0);
        DAC_PHSYNC		:out std_logic;
        DAC_PVSYNC		:out std_logic;
        DAC_PBLK		:out std_logic;
        DAC_LF1			:out std_logic;
        DAC_LF2			:out std_logic;
        DAC_SDA			:out std_logic;
        DAC_SCL			:out std_logic;
        DAC_CLK			:out std_logic;
        DAC_SFL			:out std_logic;
            --Memory 1--	
        DATA_Mem_1		:inout std_logic_vector(7 downto 0);
        ADDR_Mem_1		:out std_logic_vector(18 downto 0);
        WE_Mem_1		:out std_logic;
        CEn_Mem_1		:out std_logic;
        OE_Mem_1		:out std_logic;
            --Other--	
        Get_m			:out std_logic;
        Sync			:out std_logic;
        CMD1			:out std_logic;
        CMD2			:out std_logic;
        Wide_Narrow		:out std_logic;
        GPIO0			:out std_logic;
        GPIO1			:out std_logic;
        GPIO2			:out std_logic;
        GPIO3			:out std_logic;
        GPIO4			:out std_logic;
        GPIO5			:out std_logic;
        GPIO6			:out std_logic;
        GPIO7			:out std_logic;
        GPIO8			:out std_logic;
        GPIO9			:out std_logic;
        GPIO10			:out std_logic;
        GPIO			:out std_logic_vector(3 downto 0);
        CLK_in			:in std_logic;
        Reset_main		:in std_logic
        );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

-- Instantiate Unit Under Test:  CONSTANTS
EKB_top_0 : EKB_top
    -- port map
    port map( 
    --IMX_252_first--
    IMX_1_XHS	    => '0',
    IMX_1_XVS	    => '0',
    IMX_1_XCLR		=>  open,
    IMX_1_SCK		=>  open,
    IMX_1_SDI		=>  open,
    IMX_1_SDO		=>  open,
    IMX_1_XCE		=>  open,
    IMX_1_INCK		=>  open,
    IMX_1_XTRIG		=>  open,
    IMX_1_CH_0_P	=> (others=> '0'),
    IMX_1_CH_0_N	=> (others=> '0'),
    IMX_1_CH_1_P	=> (others=> '0'),
    IMX_1_CH_1_N	=> (others=> '0'),
    IMX_1_CH_2_P	=> (others=> '0'),
    IMX_1_CH_2_N	=> (others=> '0'),
    IMX_1_CH_3_P	=> (others=> '0'),
    IMX_1_CH_3_N	=> (others=> '0'),
    IMX_1_CLK_P		=> (others=> '0'),
    IMX_1_CLK_N		=> (others=> '0'),
        --IMX_252_second--	
    IMX_2_XHS	    => '0',
    IMX_2_XVS	    => '0',
    IMX_2_XCLR		=>  open, 
    IMX_2_SCK		=>  open, 
    IMX_2_SDI		=>  open, 
    IMX_2_SDO		=>  open, 
    IMX_2_XCE		=>  open, 
    IMX_2_INCK		=>  open, 
    IMX_2_XTRIG		=>  open, 
    IMX_2_CH_0_P	=> (others=> '0'),
    IMX_2_CH_0_N	=> (others=> '0'),
    IMX_2_CH_1_P	=> (others=> '0'),
    IMX_2_CH_1_N	=> (others=> '0'),
    IMX_2_CH_2_P	=> (others=> '0'),
    IMX_2_CH_2_N	=> (others=> '0'),
    IMX_2_CH_3_P	=> (others=> '0'),
    IMX_2_CH_3_N	=> (others=> '0'),
    IMX_2_CLK_P		=> (others=> '0'),
    IMX_2_CLK_N		=> (others=> '0'),
        --ADV7343--	
    DAC_Y			=>  open,
    DAC_PHSYNC		=>  open,
    DAC_PVSYNC		=>  open,
    DAC_PBLK		=>  open,
    DAC_LF1			=>  open,
    DAC_LF2			=>  open,
    DAC_SDA			=>  open,
    DAC_SCL			=>  open,
    DAC_CLK			=>  open,
    DAC_SFL			=>  open,
        --Memory 1--	
    DATA_Mem_1		=>  open,
    ADDR_Mem_1		=>  open,
    WE_Mem_1		=>  open,
    CEn_Mem_1		=>  open,
    OE_Mem_1		=>  open,
        --Other--	
    Get_m			=>  open,
    Sync			=>  open,
    CMD1			=>  open,
    CMD2			=>  open,
    Wide_Narrow		=>  open,
    GPIO0			=>  open,
    GPIO1			=>  open,
    GPIO2			=>  open,
    GPIO3			=>  open,
    GPIO4			=>  open,
    GPIO5			=>  open,
    GPIO6			=>  open,
    GPIO7			=>  open,
    GPIO8			=>  open,
    GPIO9			=>  open,
    GPIO10			=>  open,
    GPIO			=>  open,
    CLK_in		    => SYSCLK,
    Reset_main  	=> NSYSRESET

    );

end behavioral;

