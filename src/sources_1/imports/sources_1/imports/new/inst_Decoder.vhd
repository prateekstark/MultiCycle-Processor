library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity inst_decoder is
  Port ( 
  reset : in std_logic;
  irq_f : out std_logic;
  flag : in std_logic_vector(3 downto 0);
    instruct : in std_logic_vector(31 downto 0);
    inst_class : out std_logic_vector(1 downto 0);
    iw : in std_logic;
    dw : in std_logic;
    clock : in std_logic;
    rad1 : out std_logic_vector(3 downto 0);
    rad2 : out std_logic_vector(3 downto 0);
    wad : out std_logic_vector(3 downto 0);
    dt_offset : out std_logic_vector(11 downto 0);
    br_offset : out std_logic_vector(23 downto 0);
    data_reg: out std_logic_vector(31 downto 0);
    I_bit : out std_logic;
    f_set : out std_logic;
    cv_update : out std_logic;
    ld_bit : out std_logic;
    cinstr : out std_logic_vector( 4 downto 0);
    br : out std_logic_Vector(1 downto 0);
    my_offset: out std_logic_vector(7 downto 0);
    rs : out std_logic_vector(3 downto 0);
    P_bit : out std_logic;
    U_bit : out std_logic;
    B_bit : out std_logic;
    W_bit : out std_logic;
    rm : out std_logic_vector(3 downto 0);
    sh : out std_logic_vector(1 downto 0);
    Ffield : out std_logic_vector(1 downto 0);
    cond : out std_logic_vector(3 downto 0);
    store_link : out std_logic;
    isMul : out std_logic;
    wad1 : out std_logic_vector(3 downto 0);
    mul_type : out std_logic_vector(1 downto 0);
    iq : in std_logic;
    cpsr_val: out std_logic_Vector(31 downto 0);
    spsr_val: out std_logic_vector(31 downto 0);
    rm_data : in std_logic_Vector(31 downto 0);
    excpn_type : out std_logic_vector(1 downto 0);
    isExcpn1 : out std_logic;
    wen_pc : in std_logic;
    ctrl_state : in std_logic_vector(3 downto 0);
    temp_output : out std_logic
    );
end inst_decoder;

architecture Behavioral of inst_decoder is
signal compare,offspec : std_logic_vector(11 downto 0);
type instruct_type is (andd, eor, sub, rsb, add, adc, sbc, rsc, tst, teq, cmp, cmn, orr, mov, bic, mvn, mul, mla, smull, umull, smlal, umlal);
signal c_instr : std_logic_vector(4 downto 0);
type class_type is (DP,DT,BRANCH,EXCEPTION);
signal class : class_type;
signal opcode,rn,reg, check: std_logic_vector(3 downto 0);
signal cpsr,spsr, pc_temp : std_logic_Vector(31 downto 0) := "00000000000000000000000000000000";
signal F_field,in_class : std_logic_vector(1 downto 0);
signal ir,dr : std_logic_Vector(31 downto 0) := (others => '0');
signal temp_I, temp_L, temp_B,instruct7,instruct4, isShift,temp_P,temp_S,irq, is_mov : std_logic;
Signal il,temp_sh: std_logic_Vector(1 downto 0);
signal isExcpn: std_logic := '0';
begin
    sh <= temp_sh;
    isExcpn1 <= isExcpn;
--    isExcpn <= '1';
--    temp_output <= '1';
    offspec <= ir(11 downto 0);
    check <= ir(19 downto 16);
    rn <= ir(15 downto 12);
    reg <= ir(3 downto 0);
--    irq <= iq and (not(cpsr(7)));
    irq_f <= irq;
    cpsr(7) <= '1' when ((in_class = "11" and ctrl_state = "0010") or reset = '1' or irq = '1') else
                rm_data(7) when c_instr = "11110" else
                spsr(7) when (temp_S = '1' and rn = "1111" and reg = "1110" and isExcpn = '1' and ctrl_state = "0011");
    cpsr(31 downto 28) <= flag when not((c_instr = "01101" and ir(20) = '1' and ir(15 downto 12) = "1111" and ir(3 downto 0) = "1110") or c_instr = "11110")else
                          rm_data(31 downto 28) when c_instr = "11110" else
                          spsr(31 downto 28) when (temp_S = '1' and rn = "1111" and reg = "1110" and isExcpn = '1' and ctrl_state = "0011");    
    temp_S <= ir(20);
    cond <= ir(31 downto 28);
    F_field <= ir(27 downto 26);
    br_offset <= ir(23 downto 0);
    opcode <= ir(24 downto 21);
    rad1 <= ir(15 downto 12) when c_instr = "11100" else
            ir(19 downto 16);
    rad2 <= ir(3 downto 0) when (class = DP) else ir(15 downto 12);
    rm <= ir(3 downto 0);
    wad <= ir(15 downto 12);
    wad1 <= ir(19 downto 16);
    compare <= ir(31 downto 20); 
    dt_offset <= ir(11 downto 0);
    --We are decoding the intructions
    data_reg <= dr; 
    I_bit <= ir(25);
    f_set <= '1' when (ir(20) = '1' and class = DP) else
             '0'; 
    ld_bit <= '1' when(ir(20) = '1' and class = DT) else
              '0';
    my_offset <= ir(11 downto 4);                
    rs <= ir(11 downto 8);
    P_bit <= ir(24);
    U_bit <= ir(23);
    B_bit <= ir(22);
    W_bit <= '1' when ir(24) = '0' else
              ir(21);
    temp_I <= ir(25);
    temp_L <= ir(20);
    temp_B <= ir(22);
     instruct7 <=ir(7);
     instruct4 <=ir(4);
     il <= ir(25) & ir(20);
--     sh <= ir(6 downto 5);
     temp_sh <= offspec(6 downto 5) when F_field = "00" else
          "00";
     Ffield <= F_field;
process(clock)
begin
if(rising_edge(clock)) then

    if(iw='1') then 
        ir <= instruct;
    else
        if(dw='1') then
            dr <= instruct;
         end if;
    end if;
end if;
end process;

process(ir,clock)
begin
    if(clock = '0' or clock = '1') then
    if(iq = '1' and cpsr(7) = '0') then
        irq <= '1';
        isExcpn <='1';
        excpn_type <= "10";
        
    else 
    irq <= '0';
    end if;
    if(wen_pc = '1' and is_mov = '1') then
        isExcpn <= '0';
        is_mov <= '0';
        irq <= '0';
    end if;  
        
    if(rising_edge(isExcpn) and ctrl_state = "0001") then
        spsr(31 downto 28) <= cpsr(31 downto 28);
        spsr(7) <= cpsr(7);
    end if;
--    if((reset ='1' or irq = '1') and (not((c_instr = "01101" and temp_S = '1' and rn = "1111" and reg = "1110") or c_instr = "11110"))) then
--        cpsr(7) <= '1'; --nahi chalana
--    end if;
        case F_field is 
            when "00" =>
                        store_link <= '0';
                        if(temp_I = '0' and opcode(3 downto 2) = "10" and temp_S = '0') then
                            if(opcode(0) = '0' and temp_S = '0' and check = "1111" and offspec = "000000000000") then
                                c_instr <= "11101";
                                cv_update <= '0';
                                in_class <= "00";
                                class <= DP;
                            elsif(opcode(0) = '1' and temp_S = '0' and check = "1001" and rn = "1111" and offspec(11 downto 4) = "00000000") then
                                c_instr <= "11110";
                                cv_update <= '0';
                                in_class <= "00";
                                class <= DP;
--                                if(temp_B = '0') then
--                                cpsr(31 downto 28) <= rm_data(31 downto 28);
--                                cpsr(7) <= rm_data(7);
--                                else
--                                spsr(31 downto 28) <= rm_data(31 downto 28);
--                                spsr(7) <= rm_data(7);
--                                end if;
                            else
                               c_instr <= "10111";
                               cv_update <= '0';
                               excpn_type <= "00";
                               in_class <= "11";
--                               cpsr(7) <= '1';
                               isExcpn <= '1';
                               class <= EXCEPTION;
                            end if;
                         else
                        if(temp_I = '0' and instruct7 = '1' and instruct4 ='1' and temp_sh = "00") then
--                            if(temp_sh = "00" ) then
                            isShift <= '0';                            
                            case opcode is
                                when "0000" =>
                                c_instr <= "11100";
                                     class <= DP;
                                     in_class <= "00";
                                     mul_type <= "00"; --mul
                                when "0001" =>
                                c_instr <= "11100";
                                      class <= DP;
                                      in_class <= "00";
                                      mul_type <= "01"; --mla
                                 when "0100" =>
                                 c_instr <= "11100";
                                       class <= DP;
                                       in_class <= "00";
                                       mul_type <= "10"; --smull
                                when "0101" =>
                                c_instr <= "11100";
                                        class <= DP;
                                        in_class <= "00";
                                        mul_type <= "11"; --smlal
                                when "0110" =>
                                c_instr <= "11100";
                                         class <= DP;
                                         in_class <= "00";
                                         mul_type <= "10"; --umull
                                         
                                when "0111" =>
                                c_instr <= "11100";
                                  class <= DP;
                                  in_class <= "00";
                                  mul_type <= "11"; --umlal
                                
                              when others =>
                              c_instr <= "10111";
                                    class <= EXCEPTION;
                                    excpn_type <= "00";
                                    in_class <= "11";
                                    mul_type <= "00"; --mul
--                                    cpsr(7) <= '1';
                                    isExcpn <= '1';
                            end case;
                        
--                            end if;
                        else
                        if(temp_I = '0' and instruct7 = '1' and instruct4 = '1' and temp_sh /= "00") then
                            class <= DT;
                            in_class <= "01";
                        else
                            class <= DP;
                            in_class <= "00";
                        end if;
                        br <= "00";
                        
                        if(temp_I = '0' and instruct7 = '1' and instruct4 = '1' and temp_sh/= "00") then
                            isShift <= '0';
--                            sh <= offspec(6 downto 5);
                            if(temp_B = '1') then
                                if(temp_L = '0') then --- STR SH IMM 
                                    c_instr <= "11000";
                                    cv_update <= '0';
                                else
                                   c_instr <= "11001";              --LDR SH IMM    
                                   cv_update <= '0';      
                                end if;
                            else
                                if(temp_L = '0') then --- STR SH REG 
                                    c_instr <= "11010";
                                    cv_update <= '0';
                                else
                                   c_instr <= "11011";              --LDR SH REG    
                                   cv_update <= '0';      
                                end if;
                            end if;
                       else  
                                isShift <= '1';
                            case opcode is
                                when "0000" =>
                                    c_instr <= "00000";
                                    cv_update <= '0';
                                when "0001" =>
                                    c_instr <= "00001";
                                    cv_update <= '0';
                                when "0010" =>
                                    c_instr <= "00010";
                                    cv_update <= '1';
                                when "0011" =>
                                    c_instr <= "00011";
                                    cv_update <= '1';
                                when "0100" =>
                                    c_instr <= "00100";
                                    cv_update <= '1';
                                when "0101" =>
                                    c_instr <= "00101";
                                    cv_update <= '1';
                                when "0110" =>
                                    c_instr <= "00110";
                                    cv_update <= '1';
                                when "0111" =>
                                    c_instr <= "00111";
                                    cv_update <= '1';
                                when "1000" =>
                                    if(temp_S = '1') then
                                        c_instr <= "01000";
                                        cv_update <= '0';
                                    else
                                        c_instr <= "10111";
                                        cv_update <= '0';
                                        excpn_type <= "00";
                                        in_class <= "11";
--                                        cpsr(7) <= '1';
                                        isExcpn <= '1';
                                        class <= EXCEPTION;
                                    end if;
                                when "1001" =>
                                    if(temp_S = '1') then
                                        c_instr <= "01001";
                                        cv_update <= '0';
                                    else
                                        c_instr <= "10111";
                                        cv_update <= '0';
                                        excpn_type <= "00";
                                        in_class <= "11";
--                                        cpsr(7) <= '1';
                                        isExcpn <= '1';
                                        class <= EXCEPTION;
                                    end if;
                                when "1010" =>
                                if(temp_S = '1') then
                                    c_instr <= "01010";
                                    cv_update <= '1';
                                else
                                    c_instr <= "10111";
--                                    cpsr(7) <= '1';
                                    cv_update <= '0';
                                    excpn_type <= "00";
                                    in_class <= "11";
                                    isExcpn <= '1';
                                    class <= EXCEPTION;
                                end if;
                                when "1011" =>
                                if(temp_S = '1') then
                                    c_instr <= "01011";
                                    cv_update <= '1';
                                else
                                    c_instr <= "10111";
                                    cv_update <= '0';
                                    excpn_type <= "00";
                                    in_class <= "11";
                                    isExcpn <= '1';
                                    class <= EXCEPTION;
--                                    cpsr(7) <= '1';
                                end if;
                                when "1100" =>
                                    c_instr <= "01100";
                                    cv_update <= '0';
                                when "1101" =>
                                    c_instr <= "01101";
                                    if(temp_S = '1' and rn = "1111" and reg = "1110" and isExcpn = '1') then
--                                        cpsr <= spsr;
                                        if(ctrl_state = "0110") then
                                            is_mov <= '1';
                                        else
                                            is_mov <= '0';
                                        end if;
                                    end if;
                                    cv_update <= '0';
                                when "1110" =>
                                    c_instr <= "01110";
                                    cv_update <= '0';
                                when others =>
                                    c_instr <= "01111";
                                    cv_update <= '0';
                   
                           end case;
                     end if;
                     end if;
                     end if;
        when "01" =>
                    store_link <= '0';
                    class <= DT;
                    in_class <= "01";
                    br <= "00";
                    if(temp_B = '1') then
--                        sh <= "00";
                        if(temp_L = '0') then
                            if(temp_I = '0') then
                                c_instr <= "11000";
                                cv_update <= '0';
                            else
                                c_instr <= "11010";
                                cv_update <= '0';
                            end if;
                        else
                            if(temp_I = '0') then
                                c_instr <= "11001";
                                cv_update <= '0';
                            else
                                c_instr <= "11011";
                                cv_update <= '0';
                            end if;
                        end if;
                    else
                    case il is
                        when "00" =>
                            isShift <= '0';          -- STR IMM
                            c_instr <= "10000";
                            cv_update <= '0';
                        when "01" =>     
                            isShift <= '0';     -- LDR IMM
                            c_instr <= "10001";
                            cv_update <= '0';
                        when "10" =>       
                            isShift <= '1';   -- STR REG    
                            c_instr <= "10010";
                            cv_update <= '0';
                        when others =>   
                            isShift <= '1';                -- LDR REG   
                            c_instr <= "10011";
                            cv_update <= '0';
                    end case;
                    end if;
        when "10" =>
                    isShift <= '0';
                    class <= BRANCH;
                    in_class <= "10";
                    if(temp_I ='1') then
                        if(opcode(3) = '1') then 
                            c_instr <= "10100"; --
                            cv_update <= '0';
                            br <= "11";
                            store_link <= '1';
                        else
                        case ir(31 downto 24) is
                            when "11101010" =>
                            store_link <= '0';
                                c_instr <= "10100"; --
                                cv_update <= '0';
                                br <= "11";
                            when "00001010" =>
                                store_link <= '0';
                                c_instr <= "10101"; --
                                cv_update <= '0';
                                br <= "01";    
                            when others =>
                                c_instr <= "10110"; --
                                cv_update <= '0';
                                br <= "10";
                                store_link <= '0';
                         end case;
                   end if;
                  end if;                      
    when others => 
                isShift <= '0';
                store_link <= '0';
                class <= EXCEPTION;
                isExcpn <= '1';
                if(temp_I = '1' and opcode(3) = '1') then
                    excpn_type <= "01";
                else
                    excpn_type <= "00";
                end if;
                in_class <= "11";
                c_instr <= "10111";
                cv_update <= '0';
                br <= "00";
--                cpsr(7) <= '1';
    end case;
 end if;
end process;
inst_class <= in_class;
isShift <= '1' when ((in_class ="00" and c_instr /= "11100") or c_instr = "10010" or c_instr = "10011") else
            '0';
isMul <= '1' when c_instr = "11100" else
         '0';
cinstr <= c_instr;      
cpsr_val <= cpsr;
spsr_val <= spsr;                          
end Behavioral;