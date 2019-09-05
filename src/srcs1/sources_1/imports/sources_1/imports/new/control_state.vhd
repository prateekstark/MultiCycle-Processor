library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_state is
    Port(
        exe_state : in std_logic_vector(4 downto 0);
        clock : in std_logic;
        reset : in std_logic;
        inst_type : in std_logic_vector(1 downto 0);
        ld_bit : in std_logic;
        ctrl_state : out std_logic_vector(3 downto 0) := "0001";
        W_bit : in std_logic;
        pred_result : in std_logic;
        store_link : in std_logic;
        c_instr : in std_logic_Vector(4 downto 0)
        );
end control_state;

architecture Behavioral of control_state is
type possible_states is (fetch,decode,shift,arith,addr,brn,halt,res2RF, mem_wr, mem_rd, mem2RF, index2RF, link_wr, psr_inst,delay);
signal curr_state : possible_states := fetch;
begin

process(clock, reset)
begin
    if(reset = '1') then
        curr_state <= fetch;
        ctrl_state <= "0001";
    else
        if(rising_edge(clock) and (exe_state = "00010" or exe_state = "00100" or exe_state = "01000")) then
            case curr_state is
                when fetch =>
                    curr_state <= decode;
                    ctrl_state <= "0010";
                when decode =>
                    if(c_instr = "11101" or c_instr = "11110") then
                        curr_state <= psr_inst;
                        ctrl_state <= "1101";
                    else
                    case inst_type is
                        when "00" =>
                        if(pred_result = '1') then 
                            curr_state <= shift;
                            ctrl_state <= "1010";
                        else
                           curr_state <= res2RF;
                           ctrl_state <= "0110";
                       end if;
                        when "01" =>
                         if(pred_result = '1') then 
                            curr_state <= addr;
                            ctrl_state <= "0100";
                        else
                            curr_state <= mem2RF;
                            ctrl_state <= "1001";
                       end if;
                        when "10" =>
                            curr_state <= brn;
                            ctrl_state <= "0101";
                        when others =>
                            curr_state <= halt;
                            ctrl_state <= "0000";
                    end case;
                    end if;
                when shift =>
                    curr_state <= arith;
                    ctrl_state <= "0011";
                when arith =>
                    curr_state <= res2RF;
                    ctrl_state <= "0110";
                when res2RF =>
                    curr_state <= fetch;
                    ctrl_state <= "0001";
                when addr =>
                    if(W_bit = '1') then
                        curr_state <= index2RF;
                        ctrl_state <= "1011";
                    else
                        curr_state <= mem_rd;
                        ctrl_state <= "1000";
                    end if;
                when index2RF =>
                    curr_state <= mem_rd;
                    ctrl_state <= "1000";
                when mem_wr =>
                    curr_state <= fetch;
                    ctrl_state <= "0001";
                when mem_rd =>
                     if(ld_bit = '0') then
                           curr_state <= mem_wr;
                           ctrl_state <= "0111";
                       else
                           curr_state <= mem2RF;
                           ctrl_state <= "1001";
                       end if;
                when mem2RF =>
                    curr_state <= fetch;
                    ctrl_state <= "0001";
                when brn =>
                    if(store_link = '0') then
                        curr_state <= fetch;
                        ctrl_state <= "0001";   
                    else
                        curr_state <= link_wr;
                        ctrl_state <= "1100";   
                    end if;
                when link_wr =>
                    curr_state <= fetch;
                    ctrl_state <= "0001";   
                when psr_inst =>
                    curr_state <= fetch;
                    ctrl_state <= "0001"; 
                when others =>
                    curr_state <= fetch;
                    ctrl_state <= "0001";
            end case;
      end if;
      end if;
      end process;          
end Behavioral;