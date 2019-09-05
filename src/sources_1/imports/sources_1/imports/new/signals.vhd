library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity signals is
    Port(
        ctrl_state : in std_logic_vector(3 downto 0);
        c_instr : in std_logic_vector(4 downto 0);
        inst_class : in std_logic_vector(1 downto 0);
        I_bit : in std_logic;
        wen_pc : out std_logic;
        IorD : out std_logic;
        mr : out std_logic;
        mw : out std_logic;
        iw : out std_logic;
        dw : out std_logic;
        m2r : out std_logic;
        rw : out std_logic;
        aw : out std_logic;
        bw : out std_logic;
        b_selector : out std_logic;
        rew : out std_logic;
        rw_ind : out std_logic;
        pred_result : in std_logic;
        isShift : out std_logic;
        write_psr : out std_logic
--        br: out std_logic_vector(1 downto 0)
        );
end signals;

architecture Behavioral of signals is
begin

process(ctrl_state,c_instr)
begin
	case ctrl_state is
		when "0000" =>	--halt
			IorD <= '0';
			isShift <= '0';
			mr <= '0';
			iw <= '0';
			dw <= '0';
			mw <= '0';
			wen_pc <= '0';
			m2r <= '0';
			rw <= '0';
			write_psr <= '0';
			aw <= '0';
			bw <= '0';
			b_selector <= '0';
			rew <= '0';
			rw_ind <= '0';
--			br <= "00";
		when "0001" =>
			IorD <= '0';
			isShift <= '0';
			mr <= '1';
			iw <= '1';
			dw <= '0';
			mw <= '0';
			wen_pc <= '1';
			m2r <= '0';
			write_psr <= '0';
			rw <= '0';
			aw <= '0';
			bw <= '0';
			b_selector <= '0';
			rew <= '0';
--			br <= "00";
            rw_ind <= '0';
		when "0010" =>
			IorD <= '0';
			isShift <= '0';
			mr <= '0';
			iw <= '0';
			dw <= '0';
			mw <= '0';
			write_psr <= '0';
			wen_pc <= '0';
			m2r <= '0';
			rw <= '0';
			aw <= '1';
			bw <= '1';
			b_selector <= '0';
			rw_ind <= '0';
			rew <= '0';
--			br <= "00";
        when "1010" =>
            IorD <= '0';
            if (c_instr /= "11100") then
                isShift <= '1';
            else
                isShift <= '0';
            end if;
            mr <= '0';
            iw <= '0';
            dw <= '0';
            mw <= '0';
            wen_pc <= '0';
            rw_ind <= '0';
            m2r <= '0';
            rw <= '0';
            aw <= '0';
            write_psr <= '0';
            bw <= '0';
            if(I_bit = '0' or inst_class = "01") then
            b_selector <= '0';
            else
                b_selector <= '1';
            end if;
            rew <= '0';
		when "0011" =>
			IorD <= '0';
			isShift <= '0';
			mr <= '0';
			iw <= '0';
			dw <= '0';
			mw <= '0';
			wen_pc <= '0';
			m2r <= '0';
			rw_ind <= '0';
			rw <= '0';
			aw <= '0';
			bw <= '0';
--			if(I_bit = '1') then
--			     b_selector <= '1'; 
--			else
			     b_selector <= '0';
--			end if;
			rew <= '1';
			write_psr <= '0';
--			br <= "00";
		when "0100" =>
			IorD <= '0';
			mr <= '0';
			 if(c_instr = "10010" or c_instr = "10011") then
			     isShift <= '1';
             else
                isShift <= '0';
			 end if;
			iw <= '0';
			dw <= '0';
			mw <= '0';
			wen_pc <= '0';
			rw_ind <= '0';
			m2r <= '0';
			rw <= '0';
			aw <= '0';
			bw <= '0';
			write_psr <= '0';
			b_selector <= '1';
			rew <= '1';
		when "0101" =>
			IorD <= '0';
			mr <= '0';
			isShift <= '0';
			iw <= '0';
			dw <= '0';
			mw <= '0';
			wen_pc <= '0';
			m2r <= '0';
			rw_ind <= '0';
			rw <= '0';
			aw <= '0';
			bw <= '0';
			write_psr <= '0';
			b_selector <= '0';
			rew <= '0';
		when "0110" =>
			IorD <= '0';
			mr <= '0';
			isShift <= '0';
			iw <= '0';
			dw <= '0';
			rw_ind <= '0';
			mw <= '0';
			wen_pc <= '0';
			m2r <= '0';
			if(pred_result = '1' and c_instr /= "01010" and c_instr /= "01011" and c_instr /= "01000" and c_instr /= "01001") then 
			    rw <= '1';
			else 
			    rw <= '0';
			end if;
			aw <= '0';
			write_psr <= '0';
			bw <= '0';
			b_selector <= '0';
			rew <= '0';
--			br <= "00";
		when "0111" =>
			IorD <= '1';
			isShift <= '0';
			mr <= '0';
			iw <= '0';
			dw <= '0';
			mw <= '1';
			rw_ind <= '0';
			wen_pc <= '0';
			m2r <= '0';
			rw <= '0';
			aw <= '0';
			bw <= '0';
			write_psr <= '0';
			b_selector <= '0';
			rew <= '0';
--			br <= "00";
		when "1000" =>
			IorD <= '1';
			mr <= '1';
			isShift <= '0';
			iw <= '0';
			dw <= '1';
			mw <= '0';
			wen_pc <= '0';
			m2r <= '0';
			rw <= '0';
			rw_ind <= '0';
			aw <= '0';
			bw <= '0';
			write_psr <= '0';
			b_selector <= '0';
			rew <= '0';
	   when "1011" => 
            IorD <= '0';
            mr <= '0';
            iw <= '0';
            dw <= '0';
            isShift <= '0';
            mw <= '0';
            rw_ind <= '1';
            wen_pc <= '0';
            m2r <= '0';
            rw <= '0';
            aw <= '0';
            bw <= '0';
            write_psr <= '0';
            b_selector <= '0';
            rew <= '0';
		when "1100" => 
            IorD <= '0';
            mr <= '0';
            iw <= '0';
            dw <= '0';
            mw <= '0';
            isShift <= '0';
            rw_ind <= '0';
            wen_pc <= '0';
            write_psr <= '0';
            m2r <= '0';
            rw <= '1';
            aw <= '0';
            bw <= '0';
            b_selector <= '0';
            rew <= '0';
        when "1101" =>
            IorD <= '0';
            mr <= '0';
            iw <= '0';
            dw <= '0';
            mw <= '0';
            isShift <= '0';
            rw_ind <= '0';
            wen_pc <= '0';
            m2r <= '0';
            rw <= '0';
            aw <= '0';
            bw <= '0';
            b_selector <= '0';
            rew <= '0';
            if(c_instr = "11101") then
                write_psr <= '1';
            else
                write_psr <= '0';
            end if;
		when others =>
			IorD <= '0';
			write_psr <= '0';
			mr <= '0';
			iw <= '0';
			dw <= '0';
			            isShift <= '0';

			mw <= '0';
			wen_pc <= '0';
			m2r <= '1';
			rw_ind <= '0';
			if(pred_result = '1') then
			     rw <= '1';
            else
                rw <= '0';
            end if;
			aw <= '0';
			bw <= '0';
			b_selector <= '0';
			rew <= '0';
--			br <= "00";
	end case;
end process;
end Behavioral;