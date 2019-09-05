library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity processor_memory_datapath is
  Port ( 
    sh : in std_logic_Vector(1 downto 0);
    data : in std_logic_vector(31 downto 0); -- data read from memory
    data_in : in std_logic_vector(31 downto 0); -- Data from processor
    data_out : out std_logic_vector(31 downto 0);
    data_out_returns : out std_logic_vector(31 downto 0);
    c_instr : in std_logic_Vector(4 downto 0);
    ALU_Res : in std_logic_vector(31 downto 0)
  );
end processor_memory_datapath;

architecture Behavioral of processor_memory_datapath is
type sh_type is (unsigned_half,signed_byte,signed_half,unsigned_byte);
signal sh_decoded : sh_type;
signal zero_byte : std_logic_vector(7 downto 0) := "00000000";
signal first_bit : std_logic_Vector(7 downto 0);
begin

first_bit <= data(15) & data(15)& data(15)& data(15)& data(15)& data(15)& data(15)& data(15) when sh = "11" else
             data(7) & data(7)& data(7)& data(7)& data(7)& data(7)& data(7)& data(7);
with sh select
sh_decoded <= unsigned_half when "01",
              signed_byte when "10",
              signed_half when "11",
              unsigned_byte when others;
              
    data_out <=       first_bit & first_bit & data(15 downto 0) when (sh_decoded = signed_half and ALU_Res(1) = '0') else
                      first_bit & first_bit & data(31 downto 16) when (sh_decoded = signed_half and ALU_Res(1) = '1') else
                      zero_byte & zero_byte & zero_byte & data(7 downto 0) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "00") else
                      zero_byte & zero_byte & zero_byte & data(15 downto 8) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "01") else
                      zero_byte & zero_byte & zero_byte & data(23 downto 16) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "10") else
                      zero_byte & zero_byte & zero_byte & data(31 downto 24) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "11") else
                      zero_byte & zero_byte & data(15 downto 0) when (sh_decoded = unsigned_half and ALU_Res(1) = '0') else
                      zero_byte & zero_byte & data(31 downto 16) when (sh_decoded = unsigned_half and ALU_Res(1) = '1') else
                      first_bit & first_bit & first_bit & data(7 downto 0) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "00") else
                      first_bit & first_bit & first_bit & data(15 downto 8) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "01") else
                      first_bit & first_bit & first_bit & data(23 downto 16) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "10") else
                      first_bit & first_bit & first_bit & data(31 downto 24) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "11");

--with sh_decoded select
--    data_out_returns <= data(31 downto 16) & data_in(15 downto 0) when unsigned_half,
--                        data(31 downto 8) & data_in(7 downto 0) when signed_byte,
--                        data(31 downto 16) & data_in(15 downto 0) when signed_half,
--                        data(31 downto 8) & data_in(7 downto 0) when others;
                        
 data_out_returns <= data(31 downto 16) & data_in(15 downto 0) when (sh_decoded = signed_half and ALU_Res(1) = '0') else
                     data_in(31 downto 16) & data(15 downto 0) when (sh_decoded = signed_half and ALU_Res(1) = '1') else
                     data(31 downto 8) & data_in(7 downto 0) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "00") else
                     data(31 downto 16) & data_in(15 downto 8) & data(7 downto 0) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "01") else
                     data(31 downto 24) & data_in(23 downto 16) & data(15 downto 0) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "10") else
                     data_in(31 downto 24) & data(23 downto 0) when (sh_decoded = unsigned_byte and ALU_Res(1 downto 0) = "11") else
                     data(31 downto 16) & data_in(15 downto 0) when (sh_decoded = unsigned_half and ALU_Res(1) = '0') else
                     data_in(31 downto 16) & data(15 downto 0) when (sh_decoded = unsigned_half and ALU_Res(1) = '1') else
                     data(31 downto 8) & data_in(7 downto 0) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "00") else
                     data(31 downto 16) & data_in(15 downto 8) & data(7 downto 0) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "01") else
                     data(31 downto 24) & data_in(23 downto 16) & data(15 downto 0) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "10") else
                     data_in(31 downto 24) & data(23 downto 0) when (sh_decoded = signed_byte and ALU_Res(1 downto 0) = "11");
                              
--How do we cater the unsigned and signed business?
end Behavioral;
