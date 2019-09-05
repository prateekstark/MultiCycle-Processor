library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity predicate_unit is
  Port (
  cond : in std_logic_vector(3 downto 0);
  flag : in std_logic_vector(3 downto 0);
  pred_result : out std_logic
  );
end predicate_unit;

architecture Behavioral of predicate_unit is
begin
with cond select
    pred_result <= flag(2) when "0000",
                   not(flag(2)) when "0001",
                   flag(1) when "0010",
                   not(flag(1)) when "0011",
                   flag(3) when "0100",
                   not(flag(3)) when "0101",
                   flag(0) when "0110",
                   not(flag(0)) when "0111",
                   flag(1) and (not(flag(2))) when "1000",
                   not(flag(1) and (not(flag(2)))) when "1001",
                   not(flag(3) xor flag(0)) when "1010",
                   flag(3) xor flag(0) when "1011",
                   not((flag(2)) or (flag(3) xor flag(0))) when "1100",
                   (flag(2)) or (flag(3) xor flag(0)) when "1101",
                   '1' when "1110",
                   '0' when others;           
end Behavioral;
