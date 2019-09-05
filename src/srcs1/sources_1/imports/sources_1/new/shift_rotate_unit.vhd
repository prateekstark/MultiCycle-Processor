library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_rotate_unit is
  Port (
  clock : in std_logic;
    I_bit: in std_logic;
    off_val : in std_logic_Vector(7 downto 0);
    data : in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0);
    rs_data : in std_logic_Vector(31 downto 0);
    isShift : in std_logic;
    inst_class : in std_logic_vector(1 downto 0);
    ctrl_state : in std_logic_Vector(3 downto 0);
    output_reg : out std_logic_vector(31 downto 0)
--    rot_value: in std_logic_Vector(31 downto 0);
--    shift_value: in std_logic_Vector(31 downto 0)
);
end shift_rotate_unit;

architecture Behavioral of shift_rotate_unit is
signal offset : std_logic_vector(7 downto 0);
signal rot_ans : std_logic_vector(31 downto 0);
signal rot_value : std_logic_vector(31 downto 0);
type shft_type is (LSL,LSR,ASR,RORight);
signal shift : shft_type;
signal shift_value : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal shift_ans: std_logic_Vector(31 downto 0);  
signal zero: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal first_bit : std_logic_Vector(15 downto 0);
signal asr_vec,ans,ans_reg : std_logic_vector(31 downto 0);
signal num : integer RANGE 0 to 31; 
begin
first_bit <= data(31) & data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31)& data(31);
asr_vec <= first_bit & first_bit; 
offset <= "0000" & data(11 downto 8) when (I_bit = '1' and inst_class = "00") else
          off_val;

num <= to_integer(unsigned(shift_value(31 downto 0)));
--num1 <= to_integer(unsigned(offset)) -1;

rot_value <= "000000000000000000000000" & data(7 downto 0) when I_bit = '1' else
             "00000000000000000000000000000000";

rot_ans <=   rot_value(((2 * to_integer(unsigned(offset)))-1) downto 0) & rot_value(31 downto (2*to_integer(unsigned(offset)))) when (I_bit = '1' and isShift = '1' AND inst_Class ="00") else
            "00000000000000000000000000000000";
 --rot_value(31 downto num) & rot_value(num1 downto 0)
shift <= LSL when((I_bit ='0' or (I_bit= '1' and inst_class = "01")) and offset(2 downto 1) = "00") else
         LSR when((I_bit ='0' or (I_bit= '1' and inst_class = "01")) and offset(2 downto 1) = "01") else
         ASR when((I_bit ='0' or (I_bit= '1' and inst_class = "01")) and offset(2 downto 1) = "10") else
         RORight when((I_bit ='0' or (I_bit= '1' and inst_class = "01")) and offset(2 downto 1) = "11"); 

shift_value <= "000000000000000000000000000" & offset(7 downto 3) when (((I_bit = '1' and inst_class = "01") or (I_bit = '0' and inst_class = "00")) and offset(0)= '0') else
               "000000000000000000000000000" & rs_data(4 downto 0) when (I_bit = '0' and offset(0)= '1') else
               "00000000000000000000000000000000";

    shift_ans <= zero((to_integer(unsigned(shift_value))-1) downto 0) & data(31 downto (to_integer(unsigned(shift_value)))) when (shift = LSR and isShift = '1') else
                 data((31 - (to_integer(unsigned(shift_value)))) downto 0) & zero(((to_integer(unsigned(shift_value)))-1) downto 0) when (shift = LSL and isShift = '1') else
                 asr_vec((to_integer(unsigned(shift_value))-1) downto 0) & data(31 downto (to_integer(unsigned(shift_value)))) when (shift = ASR and isShift = '1') else
                 data(((2* to_integer(unsigned(shift_value)))-1) downto 0) & data(31 downto (2 * to_integer(unsigned(shift_value))))  when (shift = RORight and isShift = '1') else
                 "00000000000000000000000000000000";
       
 ans <= rot_ans when ((I_bit = '1' and inst_class = "00")  and isShift = '1') else 
           shift_ans when (((I_bit = '0' and inst_class = "00") or (I_bit ='1' and inst_class ="01")) and isShift = '1') else
           data;
 process(clock)
 begin
    if(ctrl_state = "1010") then
        ans_reg <= ans;
    end if;
 end process;
 
 output <= ans;
 output_reg <= ans_reg;
end Behavioral;