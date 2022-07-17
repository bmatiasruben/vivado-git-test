----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.05.2022 11:01:00
-- Design Name: 
-- Module Name: idelay - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity idelay is
    port (
        clk_i : in std_logic;
        signal_o : out std_logic;
        delayed_o : out std_logic;
        super_delayed_o : out std_logic;
        delay_select : in std_logic_vector(7 downto 0);
        led_o : out std_logic_vector(7 downto 0)
    );
end idelay;

architecture Behavioral of idelay is

    signal counter : integer := 0;
    signal sig_aux : std_logic := '0';
    signal clk_aux : std_logic;
    signal delayed_aux : std_logic;
    signal select_aux : std_logic_vector(4 downto 0);

begin

    delayed_o <= delayed_aux;
    signal_o <= sig_aux;
    select_aux <= "00" & delay_select(7 downto 5);

    stim_proc : process (clk_aux)
    begin
        if rising_edge(clk_aux) then
            if counter < 32 then
                counter <= counter + 1;
                sig_aux <= '0';
            else
                counter <= 0;
                sig_aux <= '1';
            end if;
        end if;
    end process;

    -- led_o(7 downto 5) <= (others => '0');

    clk_wiz : entity work.clk_wiz_0 port map(
        clk_in1 => clk_i,
        clk_out1 => clk_aux
        );

    delayctrl_i : IDELAYCTRL port map(
        RST => '0',
        REFCLK => clk_aux,
        RDY => open
    );

    delay_i : IDELAYE2 generic map(
        CINVCTRL_SEL => "FALSE", -- Enable dynamic clock inversion (FALSE, TRUE)
        DELAY_src => "DATAIN", -- Delay input (IDATAIN, DATAIN)
        HIGH_PERFORMANCE_MODE => "TRUE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
        IDELAY_TYPE => "VAR_LOAD", -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        IDELAY_VALUE => 0, -- Input delay tap setting (0-31)
        PIPE_SEL => "FALSE", -- Select pipelined mode, FALSE, TRUE
        REFCLK_FREQUENCY => 200.0, -- IDELAYCTRL clock input frequency in MHz (190.0-210.0).
        SIGNAL_PATTERN => "CLOCK" -- DATA, CLOCK input signal
    )
    port map(
        -- Input signals
        C => clk_aux, -- Reference clock
        REGRST => '0', -- Reset for pipeline register (used in VAR_LOAD_PIPE)
        LD => '1', -- Loads IDELAYE2 to preprogrammed in VARIABLE and to CNTVALUEIN in VAR_LOAD 
        CE => '0', -- Enables increment/decrement function
        INC => '1', -- 1 = increment, 0 = decrement
        CINVCTRL => '0', -- Dynamically inverts clock polarity
        CNTVALUEIN => delay_select(4 downto 0), -- Dinamycally loadable tap value
        IDATAIN => '0', -- Input data from pins
        LDPIPEEN => '0', -- enable pipeline register
        DATAIN => sig_aux, -- input data from FPGA
        -- Output signals
        DATAOUT => delayed_aux, -- output signal
        CNTVALUEOUT => led_o(4 downto 0) -- output tap value for checking stuff
    );
    delay2_i : IDELAYE2 generic map(
        CINVCTRL_SEL => "FALSE", -- Enable dynamic clock inversion (FALSE, TRUE)
        DELAY_src => "DATAIN", -- Delay input (IDATAIN, DATAIN)
        HIGH_PERFORMANCE_MODE => "TRUE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
        IDELAY_TYPE => "VAR_LOAD", -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        IDELAY_VALUE => 0, -- Input delay tap setting (0-31)
        PIPE_SEL => "FALSE", -- Select pipelined mode, FALSE, TRUE
        REFCLK_FREQUENCY => 200.0, -- IDELAYCTRL clock input frequency in MHz (190.0-210.0).
        SIGNAL_PATTERN => "CLOCK" -- DATA, CLOCK input signal
    )
    port map(
        -- Input signals
        C => clk_aux, -- Reference clock
        REGRST => '0', -- Reset for pipeline register (used in VAR_LOAD_PIPE)
        LD => '1', -- Loads IDELAYE2 to preprogrammed in VARIABLE and to CNTVALUEIN in VAR_LOAD 
        CE => '0', -- Enables increment/decrement function
        INC => '1', -- 1 = increment, 0 = decrement
        CINVCTRL => '0', -- Dynamically inverts clock polarity
        CNTVALUEIN => select_aux, -- Dinamycally loadable tap value
        IDATAIN => '0', -- Input data from pins
        LDPIPEEN => '0', -- enable pipeline register
        DATAIN => delayed_aux, -- input data from FPGA
        -- Output signals
        DATAOUT => super_delayed_o, -- output signal
        CNTVALUEOUT(4 downto 3) => open,
        CNTVALUEOUT(2 downto 0) => led_o(7 downto 5) -- output tap value for checking stuff
    );

end Behavioral;