library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;

entity ALU is
  Port (
  irq : in std_logic; 
    reset : in std_logic;
    clock : in std_logic;
    ctrl_state: in std_logic_vector(3 downto 0);
    c_instr : in std_logic_vector(4 downto 0);
    pc : in std_logic_vector(31 downto 0);
    rd1 : in std_logic_vector(31 downto 0);
    rd2 : in std_logic_vector(31 downto 0);
    insex : in std_logic_vector(11 downto 0);
    inss2 : in std_logic_vector(23 downto 0);
    B_selector : in std_logic;
    rew : in std_logic;
    ALU_out : out std_logic_vector(31 downto 0);
    pc_incr : out std_logic_vector(31 downto 0);
    br : in std_logic_vector(1 downto 0);
    wen_pc : in std_logic;
    f_set : in std_logic;
    cv_update : in std_logic;
    temp_out : out std_logic;
    U_bit : in std_logic;
    P_bit : in std_logic;
    alu_index : out std_logic_vector(31 downto 0);
    pred_result : in std_logic;
    my_flag : out std_logic_vector(3 downto 0);
    store_link : in std_logic;
    link_val : out std_logic_vector(31 downto 0);
    mul_type : in std_logic_vector(1 downto 0);
    mul_rs_data : in std_logic_vector(31 downto 0);
    B_bit : in std_logic;
    rd_hi : in std_logic_vector(31 downto 0);
    wad : in std_logic_vector(3 downto 0);
    excpn_type : in std_logic_vector(1 downto 0);
    isExcpn : in std_logic;
    r14_svc: in std_logic_vector(31 downto 0)
    );
end ALU;

architecture Behavioral of ALU is
signal op1 : std_logic_vector(31 downto 0);
signal op2 : std_logic_vector(31 downto 0);
signal result : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal flag : std_logic_vector(3 downto 0) := "0000";
signal result_reg : std_logic_vector(31 downto 0);
signal four : std_logic_Vector(31 downto 0);
signal br_offset : std_logic_Vector(31 downto 0);
signal pc_int : std_logic_vector(31 downto 0):= (others=>'0');--"--00000000000000000000000000000000";
signal carry : std_logic_vector(31 downto 0);
signal c31,c32 : std_logic;
signal result_temp,result_addr_reg, link_reg : std_logic_vector(31 downto 0);
signal mul_result: std_logic_vector(63 downto 0);
signal add_val: std_logic_vector(63 downto 0);
signal count: integer := 0;
signal op2_comp,op1_comp : std_logic_vector(31 downto 0);
signal one : std_logic_Vector(31 downto 0) := "00000000000000000000000000000001";
begin
op2_comp <= std_logic_vector(signed(not(op2)) + signed(one));
op1_comp <= std_logic_vector(signed(not(op1)) + signed(one));
four <= "00000000000000000000000000000100";
carry <= "0000000000000000000000000000000" & flag(1);
op1 <= rd1;
add_val <= rd_hi & op1;
br_offset <= "00000000" & inss2;

    op2 <= rd2 when (B_selector = '0' or c_instr = "11010" or c_instr = "11011" or c_instr = "10010" or c_instr = "10011") else
           "000000000000000000000000" & insex(11 downto 8) & insex(3 downto 0) when (B_selector = '1' and (c_instr ="11000" or c_instr = "11001")) else
           "00000000000000000000" & insex;
my_flag <= flag;
process(c_instr,ctrl_state,clock)
begin
if(pred_result = '1') then
    case c_instr is
        when "00000" => --and
            result <= op1 and op2;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "00001" => --eor
            result <= op1 xor op2;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "00010" => --sub
            result <= std_logic_vector(signed(op1) + signed(op2_comp));
            c31 <= op1(31) xor (op2_comp(31) xor result(31));
        when "00011" => --rsb
            result <= std_logic_vector(signed(op2) + signed(op1_comp));
            c31 <= op1_comp(31) xor (op2(31) xor result(31));
        when "00100" => --add
            result <= std_logic_vector(signed(op1) + signed(op2));
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "00101" => --adc
            result <= std_logic_vector(signed(op1) + signed(op2) + signed(carry));
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "00110" => --sbc
            result <= std_logic_vector(signed(op1) + signed(not(op2)) + signed(carry));
            c31 <= op1(31) xor (op2_comp(31) xor result(31));
        when "00111" => --rsc
            result <= std_logic_vector(signed(op2) + signed(not(op1)) + signed(carry));
            c31 <= op1_comp(31) xor (op2(31) xor result(31));
        when "01000" => --tst
            result <= op1 and op2;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "01001" => --teq
            result <= op1 xor op2;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "01010" => --cmp
            result <= std_logic_vector(signed(op1) + signed(op2_comp));
            c31 <= op1(31) xor (op2_comp(31) xor result(31));
        when "01011" => --cmn
            result <= std_logic_vector(signed(op1) + signed(op2));
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "01100" => --orr
            result <= op1 or op2;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "01101" => --mov
            result <= op2;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "01110" => --bic
            result <= op1 and (not(op2));
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "01111" => --mvn
            result <= not(op2);
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "10000" => --STR IMM
            if(P_bit = '1') then
                if(U_bit = '1') then
                    result <= std_logic_vector(signed(op1) + signed(op2));
                else
                    result <= std_logic_vector(signed(op1) - signed(op2));
                end if;
            else
                result <= op1;
            end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "10001" => --LDR IMM
                    if(P_bit = '1') then
            if(U_bit = '1') then
                result <= std_logic_vector(signed(op1) + signed(op2));
            else
                result <= std_logic_vector(signed(op1) - signed(op2));
            end if;
            else
                result <= op1;
            end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "10010" => -- STR REG
            if(P_bit = '1') then
                if(U_bit = '1') then
                    result <= std_logic_vector(signed(op1) + signed(op2));
                else
                    result <= std_logic_vector(signed(op1) - signed(op2));
                end if;
            else
                result <= op1;
            end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "10011" =>  --LDR REG
            if(P_bit = '1') then
                    if(U_bit = '1') then
                        result <= std_logic_vector(signed(op1) + signed(op2));
                    else
                        result <= std_logic_vector(signed(op1) - signed(op2));
                    end if;
                else
                    result <= op1;
                end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "11000" => --STR SH IMM
            if(P_bit = '1') then
                    if(U_bit = '1') then
                        result <= std_logic_vector(signed(op1) + signed(op2));
                    else
                        result <= std_logic_vector(signed(op1) - signed(op2));
                    end if;
                else
                    result <= op1;
                end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "11001" => --LDR SH IMM 
            if(P_bit = '1') then
                    if(U_bit = '1') then
                        result <= std_logic_vector(signed(op1) + signed(op2));
                    else
                        result <= std_logic_vector(signed(op1) - signed(op2));
                    end if;
                else
                    result <= op1;
                end if;
            c31 <= op1(31) xor (op2(31) xor result(31));        
        when "11010" => --STR SH REG
            if(P_bit = '1') then
                    if(U_bit = '1') then
                        result <= std_logic_vector(signed(op1) + signed(op2));
                    else
                        result <= std_logic_vector(signed(op1) - signed(op2));
                    end if;
                else
                    result <= op1;
                end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
    
        when "11011" => -- LDR SH REG
            if(P_bit = '1') then
                if(U_bit = '1') then
                    result <= std_logic_vector(signed(op1) + signed(op2));
                else
                    result <= std_logic_vector(signed(op1) - signed(op2));
                end if;
            else
                result <= op1;
            end if;
            c31 <= op1(31) xor (op2(31) xor result(31));
        when "11100" =>
            case mul_type is
                when "00" =>
                    mul_result <= std_logic_Vector(signed(mul_rs_data) * signed(op2));
                    
                when "01" =>
                    mul_result <= std_logic_Vector((signed(mul_rs_data) * signed(op2)) + signed(op1));
                when "10" =>
                    if(B_bit = '0') then
                        mul_result <= std_logic_Vector(unsigned(mul_rs_data) * unsigned(op2));
                    else
                        mul_result <= std_logic_Vector(signed(mul_rs_data) * signed(op2));                    
                    end if;
                when others => 
                    if(B_bit = '0') then
                        mul_result <= std_logic_Vector((unsigned(mul_rs_data) * unsigned(op2)) + unsigned(add_val));
                    else
                        mul_result <= std_logic_Vector((signed(mul_rs_data) * signed(op2)) + signed(add_val));        
                    end if;                  
           end case;
           c31 <= op1(31) xor (op2(31) xor mul_result(31));  -- check/verify
        when others =>
            result <= "00000000000000000000000000000000";
            c31 <= op1(31) xor (op2(31) xor result(31));
    end case;
    if(U_bit = '1') then
       result_temp <= std_logic_vector(signed(op1) + signed(op2));
    else
       result_temp <= std_logic_vector(signed(op1) - signed(op2));
    end if;
else
    result <= "00000000000000000000000000000000";
    result_temp <= "00000000000000000000000000000000";
    c31 <= '0';
end if;
end process;
            
process(ctrl_state)
begin
if(reset = '1') then
    pc_int <= "00000000000000000000000000000000";
    link_reg <= std_logic_vector(signed(pc) + signed(four));
else
case ctrl_state is
    when "0101" =>
        
        if(store_link = '1') then
            link_reg <= std_logic_vector(signed(pc) + signed(four));
            pc_int <= std_logic_vector(signed(pc) + signed((br_offset(21 downto 0)&"00"))+signed(four) + signed(four));   
        else
            if(excpn_type = "10" and count = 0) then
                    pc_int <= "00000000000000000000000000011000";
                    link_reg <= std_logic_vector(signed(pc) + signed(four));
                    count <= 1;
            else
                if(pred_result = '1' and ((br = "01" and flag(2) ='1') or (br="10" and flag(2) = '0') or(br ="11"))) then                 
                    pc_int <= std_logic_vector(signed(pc) + signed((br_offset(21 downto 0)&"00"))+signed(four) + signed(four));
                else
                    pc_int <= std_logic_vector(signed(pc) + signed(four));
                end if;
            end if;
        end if;
    when "0000" =>
            link_reg <= std_logic_vector(signed(pc) + signed(four));
            if(excpn_type = "00") then
                pc_int <= "00000000000000000000000000000100";
            elsif (excpn_type = "01") then 
                pc_int <= "00000000000000000000000000001000";
            elsif(excpn_type = "10" and count = 0) then
                pc_int <= "00000000000000000000000000011000";
                count <= 1;
            end if;
--           pc_int <= std_logic_vector(signed(pc) + signed(four));
    when "0110" =>
            if(isExcpn = '1' and wad = "1111") then
                pc_int <= r14_svc;
            else
           if(excpn_type = "10" and count = 0) then
                    pc_int <= "00000000000000000000000000011000";
                    link_reg <= std_logic_vector(signed(pc) + signed(four));
                    count <= 1;
           else
           if(wad = "1111" and c_instr = "01101") then
           pc_int <= result_reg;
           else 
           pc_int <= std_logic_vector(signed(pc) + signed(four));
           end if;
           end if;
           end if;  
    when "0111" =>
            if(excpn_type = "10" and count = 0) then
                pc_int <= "00000000000000000000000000011000";
                link_reg <= std_logic_vector(signed(pc) + signed(four));
                count <= 1;
            else
                pc_int <= std_logic_vector(signed(pc) + signed(four));
            end if;
    when "1001" =>
           if(excpn_type = "10" and count = 0) then
                    pc_int <= "00000000000000000000000000011000";
                    link_reg <= std_logic_vector(signed(pc) + signed(four));
                    count <= 1;
            else
                    pc_int <= std_logic_vector(signed(pc) + signed(four));
            end if;
    when "1101" =>
               if(excpn_type = "10" and count = 0) then
                        pc_int <= "00000000000000000000000000011000";
                        link_reg <= std_logic_vector(signed(pc) + signed(four));
                        count <= 1;
                else
                        pc_int <= std_logic_vector(signed(pc) + signed(four));
                end if;
    when others =>
            pc_int <= pc_int ;
end case;
end if;
end process;              
pc_incr <= pc_int;         
link_val <= link_reg;        
process(clock)
begin
    if(rising_edge(clock)) then
        if(rew = '1') then
            if(c_instr = "11100") then
                result_reg <= mul_result(31 downto 0);
                result_addr_reg <= mul_result(63 downto 32);
            else 
                result_reg <= result;
                result_addr_reg <= result_temp;
            end if;
    end if;

  if(f_set = '1' and ctrl_state = "0011") then
    if(c_instr = "11100") then
        if(mul_result = "0000000000000000000000000000000000000000000000000000000000000000") then
            flag(2) <= '1';
        else
            flag(2) <= '0';
        end if;
        flag(3) <= mul_result(63);
    else
        if(result = "00000000000000000000000000000000") then
                flag(2) <= '1';
            else
                flag(2) <= '0';
            end if;
            flag(3) <= result(31);
    end if;
   
    if(cv_update = '1') then
         case c_instr is
            when "00010" =>
                flag(1) <= (op1(31) and op2_comp(31)) or (op1(31) and c31) or (c31 and op2_comp(31));
                flag(0) <= c31 xor ((op1(31) and op2_comp(31)) or (op1(31) and c31) or (c31 and op2_comp(31)));
            when "00011" =>
                flag(1) <= (op2(31) and op1_comp(31)) or (op2(31) and c31) or (c31 and op1_comp(31));
                flag(0) <= c31 xor ((op2(31) and op1_comp(31)) or (op2(31) and c31) or (c31 and op1_comp(31)));
            when "00110" =>
                flag(1) <= (op1(31) and op2_comp(31)) or (op1(31) and c31) or (c31 and op2_comp(31));
                flag(0) <= c31 xor ((op1(31) and op2_comp(31)) or (op1(31) and c31) or (c31 and op2_comp(31)));
            when "00111" =>
                flag(1) <= (op2(31) and op1_comp(31)) or (op2(31) and c31) or (c31 and op1_comp(31));
                flag(0) <= c31 xor ((op2(31) and op1_comp(31)) or (op2(31) and c31) or (c31 and op1_comp(31)));
            when "01010" =>
                flag(1) <= (op1(31) and op2_comp(31)) or (op1(31) and c31) or (c31 and op2_comp(31));
                flag(0) <= c31 xor ((op1(31) and op2_comp(31)) or (op1(31) and c31) or (c31 and op2_comp(31)));
            when others =>
                flag(1) <= (op1(31) and op2(31)) or (op1(31) and c31) or (c31 and op2(31));
                flag(0) <= c31 xor ((op1(31) and op2(31)) or (op1(31) and c31) or (c31 and op2(31)));
            end case;
         
    end if;
  end if;
end if;
end process;
ALU_out <= result_reg;
alu_index <= result_addr_reg;
temp_out <= c31;
end Behavioral;