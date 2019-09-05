---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2019 04:06:55 PM
-- Design Name: 
-- Module Name: hardware_interface - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hardware_interface is
  Port (
        clock : in std_logic;
        keypad_row : in std_logic_vector(3 downto 0);
        keypad_column: out std_logic_vector(3 downto 0);
        irq : out std_logic
       );
end hardware_interface;

architecture Behavioral of hardware_interface is
signal counter: integer range 0 to 9999 := 0;
signal temporal : std_logic:= '0';
begin

process(clock)
begin
if(rising_edge(clock)) then
    if(counter < 3000) then
        temporal <= '1';
    else
        temporal <= '0';
        if(counter = 9999) then
            counter <= 0;
        end if;
    end if;
end if;
end process;
irq <= temporal;

process(clock,keypad_row,keypad_column)
begin
if(irq = '1')
end Behavioral;
