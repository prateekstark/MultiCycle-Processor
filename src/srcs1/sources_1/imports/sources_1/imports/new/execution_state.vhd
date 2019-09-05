library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execution_state is
    Port (
        ctrl_state : in std_logic_vector(3 downto 0);
        clock : in std_logic;
        instr : in std_logic; 
        step : in std_logic;
        go : in std_logic;
        reset : in std_logic;
        state : out std_logic_vector(4 downto 0) := "00001"
        );
end execution_state;

architecture Behavioral of execution_state is
signal temporal: STD_LOGIC;
signal counter : integer range 0 to 99999 := 0;
signal clock_divided : std_logic;
signal step_div,reset_div,go_div,instr_div,step_deb,reset_deb,go_deb,instr_deb: std_logic := '0';
type possible_states is (initial, cont, done, onestep, oneinstr);
signal curr_state : possible_states := initial;
begin
reset_deb <= reset;
go_deb <= go;
step_deb <= step; 
instr_deb <= instr;
--    process (clock) begin
--        if rising_edge(clock) then
--            if (counter = 99999) then
--                temporal <= NOT(temporal);
--                counter <= 0;
--            else
--                counter <= counter + 1;
--            end if;
--        end if;
--    end process;
    
--    clock_divided <= temporal;
    
--    process(clock_divided) begin
--        if(rising_edge(clock_divided)) then
--            step_div <= step;
--            go_div <= go;
--            reset_div <= reset;
--            instr_div <= instr;
--         end if;
--     end process;
    
--     reset_deb <= reset_div;
--     go_deb <= go_div;
--     step_deb <= step_div;
--     instr_deb <= instr_div;
    
--     process(clock, reset_deb)
process(clock,reset)
             begin
                 if (reset_deb = '1') then
                     curr_state <= initial;
                 else
                     if(rising_edge(clock)) then
                         case curr_state is
                             when initial =>
                                 if(go_deb = '0' and step_deb = '0' and instr_deb ='0') then
                                     curr_state <= initial;
                                     state <= "00001";
                                 else
                                     if(go_deb = '1') then
                                         curr_state <= cont;
                                         state <= "00010";
                                     else
                                        if(instr_deb = '1') then
                                         curr_state <= oneinstr ;
                                         state <= "00100";
                                        else
                                          curr_state <= onestep;
                                          state <= "01000";
                                        end if;
                                     end if;
                                 end if;
                             when onestep =>
                                 curr_state <= done;
                                 state <= "10000";
                             when cont =>
                                 if(ctrl_state = "0000") then
                                     curr_state <= done;
                                     state <= "10000";
                                 else
                                     curr_state <= cont;
                                     state <= "00010";
                                 end if;
                             when oneinstr =>
                                 if(ctrl_state = "0000" or ctrl_state = "0101" or ctrl_state = "0110" or ctrl_state = "0111" or ctrl_state = "1001") then
                                      curr_state <= done;
                                      state <= "10000";
                                 else
                                      curr_state <= oneinstr;
                                      state <= "00100";
                                 end if;
                             when done =>
                                 if(step_deb = '1' or go_deb = '1' or instr_deb ='1') then
                                     curr_state <= done;
                                     state <= "10000";
                                 else
                                     curr_state <= initial;
                                     state <= "00001";
                                 end if;
                         end case;
                     end if;
                 end if;
             end process;
end Behavioral;