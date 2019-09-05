library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity processor is
    Port(
      clk : in std_logic;
      reset : in std_logic;
      go : in std_logic;
      instr : in std_logic;
      step : in std_logic;
      iq : in std_logic
--      addr_or_data : in std_logic_vector(2 downto 0);
--      output : out std_logic_vector(15 downto 0)
--      temp_r1 : out std_logic_vector(31 downto 0)
    );
end processor;

architecture Behavioral of processor is

component dist_mem_gen_0
  PORT (
    a : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    
  );
END component;

signal mem_data: std_logic_vector(31 downto 0);
signal ctrl_state : std_logic_vector(3 downto 0);
signal inst_class : std_logic_vector(1 downto 0);
signal I_bit : std_logic;
signal wen_pc : std_logic;
signal IorD : std_logic;
signal mr : std_logic;
signal mw : std_logic;
signal iw : std_logic;
signal dw : std_logic;
signal m2r : std_logic;
signal rw : std_logic;
signal temp_r1 : std_logic_vector(31 downto 0);
signal aw : std_logic;
signal bw : std_logic;
signal b_selector : std_logic;
signal Fset : std_logic;
signal rew,cv_update : std_logic;
signal exe_state,c_instr : std_logic_vector(4 downto 0);
signal ld_bit,temp_out : std_logic;
signal pc: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
signal op1 : std_logic_Vector(31 downto 0);
signal op2 : std_logic_vector(31 downto 0);
signal offset : std_logic_vector(11 downto 0);
signal br_offset : std_logic_vector(23 downto 0);
signal ALU_res : std_logic_vector(31 downto 0);
signal ram_ad : std_logic_vector(31 downto 0);
signal pc_incr : std_logic_vector(31 downto 0);
signal br : std_logic_Vector(1 downto 0);
signal cons : std_logic_vector(31 downto 0) := "00000000000000000000000100000000";
signal dr : std_logic_vector(31 downto 0);
signal addr1,addr2,wad : std_logic_vector(3 downto 0);
signal processed_op2,op2_final : std_logic_vector(31 downto 0);
signal my_offset : std_logic_Vector(7 downto 0);
signal rs,rm : std_logic_vector(3 downto 0);
signal rs_data,op2_temp,rm_data,alu_index : std_logic_vector(31 downto 0);
signal U_bit,P_bit,W_bit,B_bit,rw_ind,pred_result,store_link, isMul, isShift, irq_f, write_psr, isExcpn, temp_output: std_logic;
signal sh,F_field : std_logic_vector(1 downto 0);
signal data_out_returns,data_out,data_temp,data_t1, link_val, psr_val : std_logic_vector(31 downto 0);
signal my_flag,cond,wad1 : std_logic_vector(3 downto 0);
--signal add_val,mul_result : std_logic_vector(63 downto 0);
signal mul_type, excpn_type : std_logic_vector(1 downto 0);
signal mul_rs_data,rot_value,shift_value : std_logic_vector(31 downto 0);
signal rd_hi,big_vector,check,pc_write_data,output_reg, cpsr, spsr, r14_svc : std_logic_vector(31 downto 0);
begin


register_file: ENTITY WORK.register_file(Behavioral) 
PORT MAP (
    m2R => m2R,
    rw => rw,
    bw => bw,
    aw => aw,
    pc_data => pc_incr,
    wen_pc => wen_pc,
    pc_out => pc,
    rd1 => op1,
    rd2 => op2,
    alu_in => ALU_res,
    clock => clk,
    dr => dr,
    rad1 => addr1,
    rad2 => addr2,
    wad => wad,
    temp_r1 => temp_r1,
    rs => rs,
    rs_data => rs_data,
    rm => rm,
    rm_data => rm_data,
    alu_index => alu_index,
    rw_ind => rw_ind,
    W_bit => W_bit,
    store_link => store_link,
    link_val => link_val,
    big_vector => big_vector,
    wad1 => wad1,
    res => alu_index,
    isMul => isMul,
    mul_type => mul_type,
    reset => reset,
    irq => irq_f,
    inst_class => inst_class,
    write_psr => write_psr,
    psr_Val => psr_val,
    isExcpn => isExcpn,
    r14_svc => r14_svc
);


shift_rotate_unit: ENTITY WORK.shift_rotate_unit(Behavioral) 
PORT MAP (
    I_bit => I_bit,
    off_val => my_offset,
    data => op2_temp,
    output => processed_op2,
    rs_data => rs_data,
    isShift => isShift,
    inst_class => inst_class,
    ctrl_state => ctrl_state,
    clock => clk,
    output_reg => output_reg
--    rot_value => rot_value,
--    shift_value => shift_value
);

inst_decoder: ENTITY WORK.inst_decoder(Behavioral) 
  PORT MAP ( 
    instruct => data_temp,
    inst_class => inst_class,
    iw  => iw,
    dw => dw,
    clock => clk,
    rad1 => addr1,
    rad2 => addr2,
    wad => wad,
    dt_offset => offset,
    br_offset => br_offset,
    data_reg => dr,
    I_bit => I_bit,
    f_set => Fset,
    cv_update => cv_update,
    ld_bit => ld_bit,
    cinstr => c_instr,
    br => br,
    my_offset => my_offset,
    rs => rs,
    U_bit => U_bit,
    rm => rm,
    P_bit => P_bit,
    W_bit => W_bit,
    B_bit =>B_bit,
    sh => sh,
    Ffield => F_field,
    cond => cond,
    store_link => store_link,
    isMul => isMul,
    wad1 => wad1,
    mul_type => mul_type,
    reset => reset,
    irq_f => irq_f,
    flag => my_flag,
    iq => iq,
    cpsr_val => cpsr,
    spsr_Val => spsr,
    rm_data => rm_data,
    excpn_type => excpn_type,
    isExcpn1 => isExcpn,
    wen_pc => wen_pc,
    ctrl_state => ctrl_state,
    temp_output => temp_output
    );

execution_state: ENTITY WORK.execution_state(Behavioral) 
PORT MAP( 
        ctrl_state => ctrl_state,
        clock => clk,
        instr => instr,
        step => step,
        go => go,
        reset => reset,
        state => exe_state
);


predicate_unit: ENTITY WORK.predicate_unit(Behavioral) 
PORT MAP( 
    cond => cond,
    flag => my_flag,
    pred_result => pred_result
);


processor_memory_datapath: ENTITY WORK.processor_memory_datapath(Behavioral) 
PORT MAP( 
    
    sh => sh,
    data => mem_data,
    data_in => op2,
    data_out => data_out,
    data_out_returns => data_out_returns,
    c_instr => c_instr,
    ALU_Res => ALU_Res
);

ALU: ENTITY WORK.ALU(Behavioral) 
PORT MAP(

    clock => clk,
    ctrl_state => ctrl_state,
    c_instr => c_instr,
    pc => pc,
    rd1 => op1,
    rd2 => op2_final,
    insex => offset,
    inss2 => br_offset,
    B_selector => b_selector,
    cv_update => cv_update,
    f_set => Fset,
    rew => rew,
    ALU_out => ALU_res,
    pc_incr => pc_incr,
    br => br,
    wen_pc => wen_pc,
    temp_out => temp_out,
    U_bit => U_bit,
    P_bit => P_bit,
    alu_index => alu_index,
    my_flag => my_flag,
    pred_result => pred_result,
    store_link => store_link,
    link_val => link_val,
    mul_type => mul_type,
    mul_rs_data => rs_data,
    B_bit => B_bit,
    rd_hi => big_vector,
    wad => wad,
    irq => irq_f,
    reset => reset,
    excpn_type => excpn_type,
    isExcpn => isExcpn,
    r14_svc => r14_svc
);

signals: ENTITY WORK.signals(Behavioral) 
PORT MAP ( 
        ctrl_state => ctrl_state,
        c_instr => c_instr,
        inst_class => inst_class,
        I_bit => I_bit,
        wen_pc => wen_pc,
        IorD => IorD,
        mr => mr,
        mw => mw,
        iw => iw,
        dw => dw,
        m2r => m2r,
        rw => rw,
        aw => aw,
        bw => bw,
        b_selector => b_selector,
        rew => rew,
        isShift => isShift,
        pred_result => pred_result,
        rw_ind => rw_ind,
        write_psr => write_psr
);

contol_state: ENTITY WORK.control_state(Behavioral) 
PORT MAP ( 
        exe_state => exe_state,
        clock => clk,
        reset => reset,
        inst_type => inst_class,
        ld_bit => ld_bit,
        ctrl_state => ctrl_state,
        W_bit => W_bit,
        pred_result => pred_result,
        store_link => store_link,
        c_instr => c_instr
);

memory: dist_mem_gen_0 port map(
   a => ram_ad(10 downto 2),
   d => data_t1,
   clk => clk,
   we => mw,
   spo => mem_data
);

--rot_value <= "000000000000000000000000" & op2_temp(7 downto 0) when I_bit = '1' else
--             "00000000000000000000000000000000";
             
--shift_value <= "000000000000000000000000000" & my_offset(7 downto 3) when (I_bit = '0' and my_offset(0)= '0') else
--            rs_data when (I_bit = '0' and my_offset(0)= '1') else
--            "00000000000000000000000000000000";

data_temp <= data_out when ((F_field = "00" and ctrl_state = "1000") or (F_field = "01" and B_bit = '1'))  else
             mem_data;
             
data_t1 <= data_out_returns when (F_field = "00") else
           op2; 

--pc_write_data <= ALU_res whe/
with IorD select
    ram_ad <= pc when '0',
              ALU_res when others;

    op2_final <= processed_op2 when (c_instr = "10010" or c_instr = "10011") else
                 output_reg when (inst_class = "00" and c_instr /= "11100") else 
                 op2; 
              
op2_temp <= rm_data when ((inst_class ="00" and I_bit = '0') or c_instr = "11000" or c_instr = "11001" or c_instr = "10010" or c_instr = "10011") else
            "00000000000000000000" & offset;

psr_val <= cpsr when B_bit = '0' else
           spsr;
                       
check <= mem_data(31 downto 1) & pc(0 downto 0);               
--with addr_or_data select
--                  output <= pc(15 downto 0) when "000",
--                           temp_r1(15 downto 0) when "001",
--                           mem_data(15 downto 0) when "010",
--                           mem_data(31 downto 16) when "011",
--                           ALU_res(15 downto 0) when "100",
--                           ram_ad(31 downto 16) when "101",
--                           "000000000000" & ctrl_state when "110",
--                           "000000000000000" & rew when others;
end Behavioral;