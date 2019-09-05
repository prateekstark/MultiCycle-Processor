library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
  Port ( 
    reset : in std_logic;
    irq : in std_logic;
    m2R : in std_logic;
    rw : in std_logic;
    bw : in std_logic;
    aw : in std_logic;
    pc_data : in std_logic_vector(31 downto 0);
    wen_pc : in std_logic;
    pc_out : out std_logic_vector(31 downto 0);
    rd1 : out std_logic_vector(31 downto 0);
    rd2 : out std_logic_vector(31 downto 0);
    alu_in : in std_logic_vector(31 downto 0);
    clock : in std_logic;
    dr : in std_logic_vector(31 downto 0);
    rad1 : in std_logic_vector(3 downto 0);
    rad2 : in std_logic_vector(3 downto 0);
    wad :  in std_logic_vector(3 downto 0);
    temp_r1 : out std_logic_vector(31 downto 0);
    rs : in std_logic_vector(3 downto 0);
    rs_data : out std_logic_vector(31 downto 0);
    rm : in std_logic_vector(3 downto 0);
    rm_data : out std_logic_vector(31 downto 0);
    alu_index : in std_logic_vector(31 downto 0);
    W_bit : in std_logic;
    store_link : in std_logic;
    rw_ind : in std_logic;
    link_val : in std_logic_vector(31 downto 0);
    big_vector : out std_logic_vector(31 downto 0);
    wad1 :  in std_logic_vector(3 downto 0);
    res : in std_logic_vector(31 downto 0);
    isMul : in std_logic;
    mul_type : in std_logic_vector(1 downto 0);
    inst_Class : in std_logic_vector(1 downto 0);
    psr_val : in std_logic_vector(31 downto 0);
    write_psr : in std_logic;
    isExcpn : in std_logic;
    r14_svc : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
type memory is array(15 downto 0) of std_logic_vector(31 downto 0); 
signal store : memory := (others => (others => '0'));
signal wd : std_logic_vector(31 downto 0);

signal regA : std_logic_vector(31 downto 0);
signal regB : std_logic_vector(31 downto 0);
signal i_temp : std_logic;
begin
    --We are decoding the intructions
  
    
    with m2R select
        wd <= dr when '1',
              alu_in when others;
    process(clock)
    begin
        if(rising_edge(clock)) then
            if(write_psr = '1') then
                store(to_integer(unsigned(wad))) <= psr_val;
            end if;
            if(inst_class= "11" or (irq = '1' and store_link = '0')) then
                r14_svc <= link_val;
            end if;
            if(rw = '1') then
--                if(isExcpn = '1' and wad = "1111" and rm = "1110") then
--                    store(15) <= r14_svc;
--                else
                if(store_link = '1') then
                    store(14) <= link_val;
                else
                    if(isMul = '1') then
                        
                        if(mul_type = "10" or mul_type = "11") then
                            store(to_integer(unsigned(wad))) <= wd;
                            store(to_integer(unsigned(wad1))) <= res;
                        else
                            store(to_integer(unsigned(wad1))) <= wd;
                        end if;
                    else
                        if(wad /= "1111") then
                        store(to_integer(unsigned(wad))) <= wd;
                        end if;
                    end if;
                end if;
--                end if;
            end if;
            if(aw = '1') then
            	regA <= store(to_integer(unsigned(rad1)));
           	end if;

			if(bw = '1') then
            	regB <= store(to_integer(unsigned(rad2)));
           	end if;
            if(wen_pc =  '1') then
                store(15) <= pc_data;
            end if;
           	if(rw_ind = '1') then                         
                if(W_bit = '1') then
                    store(to_integer(unsigned(rad1))) <= alu_index;
                end if;
           	end if;
        end if;
    end process;
    rd1 <= regA;
    rd2 <= regB;
    rs_data <= store(to_integer(unsigned(rs)));
    rm_data <= store(to_integer(unsigned(rm)));
    pc_out <= store(15);
    temp_r1 <= store(3);
    big_vector <= store(to_integer(unsigned(wad1)));
end Behavioral;