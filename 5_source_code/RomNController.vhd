library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.design_pkg.all;

entity RomNController is
    port (clk : in std_logic;
          rst : in std_logic;
          in_bus: in data_in_t;
          out_bus: out data_out_t;
          E_start : out std_logic;
          E_done : in std_logic;
          tag_verify : in std_logic);
end RomNController;

architecture Behavioral of RomNController is

    signal next_reg_s : registers_t;
    signal reg_s : registers_t; 
    
begin
    -- Clock Process
    process(clk)
    begin

        if rising_edge(clk) then
            if rst = '1' then
                reg_s.gen_cnt <= 0;
                reg_s.last_valid <= 0;
                reg_s.end_of_ad <= '0';
                reg_s.ad_partial <= '0';
                reg_s.end_of_input <= '0';
                reg_s.message_partial <= '0';
                reg_s.data_bytes <= "1111";
                reg_s.is_odd <= '1';
                reg_s.initial <= '1';
                reg_s.state <= IDLE;
                
                --Initialize LFSR D
                out_bus.status.selD <= '1';
                out_bus.status.enDD <= '1';


            else
                reg_s <= next_reg_s;
            end if;
        end if;

    end process;
    
    -- Main FSM
    wombocombo : process(all)
        variable reg_nx : registers_t;
    begin
        reg_nx := reg_s;
        
        out_bus.status.key_ready <= '0';
        out_bus.status.bdi_ready <= '0';
        out_bus.status.bdo_valid <= '0';
        out_bus.status.msg_auth_valid <= '0';
        out_bus.status.bdo_valid_bytes <= (others => '0');
        out_bus.status.msg_auth_valid <= '0';
        E_start <= '0';
        -- out_bus.status.bdo_valid_bytes <= () fix later
        -- out_bus.status.end_of_block fix later
        out_bus.status.enKey <= '0';
        out_bus.status.enAM <= '0';
        out_bus.status.enN <= '0';
        out_bus.status.enS <= '0';
        out_bus.status.enCi_T <= '0';
        out_bus.status.enTag <= '0';
        out_bus.status.enDD <= '0';

        out_bus.status.selAM <= "00";
        out_bus.status.selSR <= '0';
        out_bus.status.selMR <= '0';
        out_bus.status.selD <= '0';
        out_bus.status.selT <= '0';
        out_bus.status.selS <= '0';
        out_bus.status.ldCi_T <= '0';
        out_bus.status.Bin <= (others => '0');
        out_bus.status.ctr_words <= (others => '0');
        out_bus.status.data_bytes <= (others => '1');

        case reg_s.state is
            when IDLE =>
            if (in_bus.control.key_valid = '1') then
                if (in_bus.control.key_update = '1') then
                    reg_nx.state := LOAD_KEY;
                end if;
            end if;
            if (in_bus.control.bdi_valid = '1') then
                reg_nx.state := LOAD_NPUB;
            end if;
            when LOAD_KEY => 
            out_bus.status.key_ready <= '1';
            if (in_bus.control.key_valid = '1') then
                out_bus.status.enKey <= '1';
                if(reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := IDLE;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := LOAD_KEY;
                end if;
            else
                reg_nx.state := LOAD_KEY;
            end if;
            when LOAD_NPUB =>
            out_bus.status.bdi_ready <= '1';
            if (in_bus.control.bdi_valid = '1') then
                out_bus.status.enN <= '1';
                if (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := WAIT_AD;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := LOAD_NPUB;
                end if;
            else
                reg_nx.state := LOAD_NPUB;
            end if;
            when WAIT_AD =>
            
            if (in_bus.control.bdi_type = c_encoding_t.HDR_AD) then
                reg_nx.state := LOAD_DATA;
            else
                reg_nx.state := LOAD_AD;
            end if;
            when LOAD_AD =>
            out_bus.status.bdi_ready <= '1';
            reg_nx.data_bytes := (others => '1');
            if (in_bus.control.bdi_valid = '1') then
                out_bus.status.enAM <= '1';
                if (in_bus.control.bdi_eoi = '1') then
                    reg_nx.end_of_input := '1';
                end if;
                if (in_bus.control.bdi_eot = '1') then
                    reg_nx.end_of_ad := '1';
                    if (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                        -- out_bus.status.enAM <= '0';
                        out_bus.status.selAM <= "11"; -- for this case we need to implement in the mux for the pad to include 0's 
                        reg_nx.gen_cnt := 0;
                        reg_nx.state := PROC_AD;
                        reg_nx.last_valid := reg_s.gen_cnt;
                        out_bus.status.ctr_words <= "100";
                        out_bus.status.data_bytes <= in_bus.control.bdi_valid_bytes;
                    else
                        reg_nx.last_valid := reg_nx.gen_cnt;
                        reg_nx.data_bytes := in_bus.control.bdi_valid_bytes;
                        reg_nx.ad_partial := '1';
                        -- if (bdi_eoi = '1') then
                        -- reg_nx.end_of_input := 1;
                        -- end if;
                        reg_nx.state := PAD_AD;
                    end if;
                elsif (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := PROC_AD;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := LOAD_AD;
                end if;
            end if;
            when PAD_AD =>
                if (reg_s.gen_cnt = c_encoding_t.MAX_WORDS) then
                    out_bus.status.enAM <= '0';
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := PROC_AD;
                elsif (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    out_bus.status.enAM <= '1';
                    out_bus.status.selAM <= "10"; -- case of padding with 0s plus encoding
                    reg_nx.gen_cnt := reg_s.gen_cnt + 1;
                    reg_nx.state := PAD_AD;
                    if (reg_s.last_valid = 0) then
                        out_bus.status.ctr_words <= "000";
                    end if;
                    if (reg_s.last_valid = 1) then
                        out_bus.status.ctr_words <= "001";
                    end if;
                    if (reg_s.last_valid = 2) then
                        out_bus.status.ctr_words <= "010";
                    end if;
                    if (reg_s.last_valid = 3) then
                        out_bus.status.ctr_words <= "011";
                    end if;
                    out_bus.status.data_bytes <= reg_s.data_bytes;
                else
                    out_bus.status.enAM <= '1';
                    out_bus.status.selAM <= "01"; -- pad blocks with zeros until last block w/ encoding
                    reg_nx.gen_cnt := reg_s.gen_cnt + 1;
                    reg_nx.state := PAD_AD;
                end if;
            when PROC_AD =>
                out_bus.status.Bin <= '0' & x"8"; -- Bin is 8 for AD other than last block
                if (E_done = '1') then
                    E_start <= '0';
                end if;
                if (reg_s.initial = '1') then
                    --Initialize LFSR D
                    -- out_bus.status.selD <= '1';
                    -- out_bus.status.enDD <= '1';

                    out_bus.status.selSR <= '1';
                    out_bus.status.selS <= '1';
                    out_bus.status.enS <= '1';
                    reg_nx.is_odd := '1';
                    reg_nx.initial := '0';
                    reg_nx.state := LOAD_AD;
                end if;
                if (E_done = '1') then 
                    E_start <= '0';
                    out_bus.status.selS <= '0';
                    out_bus.status.enS <= '1';
                    reg_nx.is_odd := '1';
                    if (reg_s.end_of_ad = '0') then
                        reg_nx.state := LOAD_AD;
                    else
                        reg_nx.state := PROC_LAST_AD;
                    end if;
                    -- Increment LFSR
                    out_bus.status.enDD <= '1';
                elsif (reg_s.is_odd = '0') then
                    E_start <= '1';
                    out_bus.status.selT <= '0';
                elsif (reg_s.is_odd = '1') then
                    out_bus.status.selS <= '1';
                    out_bus.status.enS <= '1';
                    reg_nx.is_odd := '0';
                    if (reg_s.end_of_ad = '1') then
                        reg_nx.state := LOAD_AD;
                    else
                        reg_nx.state := PROC_AD_N;
                    -- Increment LFSR
                    out_bus.status.enDD <= '1';
                    end if;
                end if;
            when PROC_LAST_AD =>
            out_bus.status.selMR <= '1'; -- RHO with zeros
            out_bus.status.selS <= '1';
            out_bus.status.enS <= '1';
            reg_nx.is_odd := '0';
            reg_nx.state := PROC_AD_N;
            when PROC_AD_N =>
            E_start <= '1';
            out_bus.status.selT <= '1'; -- AD as input instead of AD or M.
            if(reg_s.ad_partial = '1') then
                out_bus.status.Bin <= "11010"; -- Bin is 26 when the last block is partial
            else
                out_bus.status.Bin <= "11000"; -- Bin is 24 when the last block is full
            end if;
            if (E_done = '1') then
                E_start <= '0';
                out_bus.status.selS <= '0';
                out_bus.status.enS <= '1';
                -- Reset and Initialize LFSR D
                out_bus.status.selD <= '1';
                out_bus.status.enDD <= '1';
                reg_nx.is_odd := '1';
                reg_nx.state := LOAD_DATA;
            end if;
            when LOAD_DATA => 
            out_bus.status.bdi_ready <= '1';
            reg_nx.data_bytes := (others => '1');
            if (in_bus.control.bdi_valid = '1') then
                out_bus.status.enAM <= '1';
                if (in_bus.control.bdi_eoi = '1') then
                    reg_nx.end_of_input := '1';
                end if;
                if (in_bus.control.bdi_eot = '1') then
                    if (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                        -- out_bus.status.enAM <= '0';
                        out_bus.status.selAM <= "11"; -- for this case we need to implement in the mux for the pad to include 0's 
                        reg_nx.gen_cnt := 0;
                        reg_nx.state := PROC_DATA;
                        reg_nx.last_valid := reg_s.gen_cnt;
                        out_bus.status.ctr_words <= "100";
                        reg_nx.data_bytes := in_bus.control.bdi_valid_bytes;
                        if (in_bus.control.bdi_valid_bytes /= "1111") then
                            reg_nx.message_partial := '1';
                        end if;
                    else
                        reg_nx.last_valid := reg_nx.gen_cnt;
                        reg_nx.data_bytes := in_bus.control.bdi_valid_bytes;
                        reg_nx.message_partial := '1';
                        -- if (bdi_eoi = '1') then
                        -- reg_nx.end_of_input := 1;
                        -- end if;
                        reg_nx.state := PAD_DATA;
                    end if;
                elsif (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    reg_nx.last_valid := reg_nx.gen_cnt;
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := PROC_DATA;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := LOAD_DATA;
                end if;
            end if;
            when PAD_DATA =>
            if (reg_s.gen_cnt = c_encoding_t.MAX_WORDS) then
                out_bus.status.enAM <= '0';
                reg_nx.gen_cnt := 0;
                reg_nx.state := PROC_DATA;
            elsif (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                out_bus.status.enAM <= '1';
                out_bus.status.selAM <= "10"; -- case of padding with 0s plus encoding
                reg_nx.gen_cnt := reg_s.gen_cnt + 1;
                reg_nx.state := PAD_DATA;
                if (reg_s.last_valid = 0) then
                    out_bus.status.ctr_words <= "000";
                end if;
                if (reg_s.last_valid = 1) then
                    out_bus.status.ctr_words <= "001";
                end if;
                if (reg_s.last_valid = 2) then
                    out_bus.status.ctr_words <= "010";
                end if;
                if (reg_s.last_valid = 3) then
                    out_bus.status.ctr_words <= "011";
                end if;
                out_bus.status.data_bytes <= reg_s.data_bytes;
            else
                out_bus.status.enAM <= '1';
                out_bus.status.selAM <= "01"; -- pad blocks with zeros until last block w/ encoding
                reg_nx.gen_cnt := reg_s.gen_cnt + 1;
                reg_nx.state := PAD_DATA;
            end if;
            when PROC_DATA =>
            out_bus.status.selS <= '1';
            out_bus.status.enS <= '1';
            out_bus.status.ldCi_T <= '1'; -- Load CipherText into PISO
            reg_nx.is_odd := '0';
            if (reg_s.end_of_input = '1') then
                reg_nx.state := PROC_LAST_DATA;
            else
                reg_nx.state := PROC_DATA_N;
            end if;
            -- Increment LFSR
            out_bus.status.enDD <= '1';
            when PROC_DATA_N =>
            if (reg_s.is_odd  = '0') then
            E_start <= '1';
            reg_nx.is_odd := '1';
            end if;
            out_bus.status.selT <= '1'; -- AD as input instead of AD or M.
            out_bus.status.Bin <= '0' & x"4"; -- Bin is 4 for M/Ci other than last block
            if (E_done = '1') then
                E_start <= '0';
                out_bus.status.selS <= '0';
                out_bus.status.enS <= '1';
                reg_nx.state := OUTPUT_DATA;
            end if;
            when PROC_LAST_DATA => 
            if (reg_s.is_odd = '0') then
                E_start <= '1';
                reg_nx.is_odd := '1';
            end if;
            out_bus.status.selT <= '1'; -- AD as input instead of AD or M.
            if(reg_s.message_partial = '1') then
                out_bus.status.Bin <= "10101"; -- Bin is 21 when the last block is partial
            else
                out_bus.status.Bin <= "10100"; -- Bin is 20 when the last block is full
            end if;
            if (E_done = '1') then
                E_start <= '0';
                out_bus.status.selS <= '0';
                out_bus.status.enS <= '1';
                reg_nx.state := OUTPUT_DATA;
            end if;
            when OUTPUT_DATA =>
            out_bus.status.bdo_valid <= '1';
            out_bus.status.bdo_valid_bytes <= (others => '1');
            if (in_bus.control.bdo_ready = '1') then
                out_bus.status.enCi_T <= '1'; -- iterate through PISO
                if (reg_s.gen_cnt = reg_s.last_valid) then
                    reg_nx.gen_cnt := 0;
                    if (reg_s.message_partial = '1') then
                        out_bus.status.bdo_valid_bytes <= reg_s.data_bytes;
                    end if;
                    if (reg_s.end_of_input = '1') then
                        reg_nx.state := PROC_TAG;
                    else
                        reg_nx.state := LOAD_DATA;
                    end if;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := OUTPUT_DATA;
                end if;
            else
                reg_nx.state := OUTPUT_DATA;
            end if;
            when PROC_TAG =>
            out_bus.status.selMR <= '1';
            if(in_bus.control.decrypt_in = '1') then
                out_bus.status.ldCi_T <= '1';
                reg_nx.state := OUTPUT_TAG;
            else
                reg_nx.state := VERIFY_TAG;
            end if;
            when OUTPUT_TAG =>
            out_bus.status.bdo_valid <= '1';
            out_bus.status.bdo_valid_bytes <= (others => '1');
            if (in_bus.control.bdo_ready = '1') then
                out_bus.status.enCi_T <= '1'; -- Iterate through PISO
                if (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := IDLE;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := OUTPUT_TAG;
                end if;
            else
                reg_nx.state := OUTPUT_TAG;
            end if;
            when VERIFY_TAG =>
            out_bus.status.bdi_ready <= '1';
            if (in_bus.control.bdi_valid = '1') then
                out_bus.status.enTag <= '1';
                if (reg_s.gen_cnt = c_encoding_t.NUM_WORDS) then
                    reg_nx.gen_cnt := 0;
                    reg_nx.state := TAG_ACK;
                else
                    reg_nx.gen_cnt := reg_nx.gen_cnt + 1;
                    reg_nx.state := VERIFY_TAG;
                end if;
            else
                reg_nx.state := VERIFY_TAG;
            end if;
            when TAG_ACK =>
            out_bus.status.selMR <= '1';
            if (tag_verify = '1') then
                reg_nx.state := SUCCESS;
            else
                reg_nx.state := FAILURE;
            end if;
            when SUCCESS =>
            out_bus.status.msg_auth_valid <= '1';
            out_bus.status.msg_auth <= '1';
            if (in_bus.control.msg_auth_ready = '1') then
                reg_nx.state := IDLE;
            else
                reg_nx.state := SUCCESS;
            end if;
            when FAILURE =>
            out_bus.status.msg_auth_valid <= '1';
            out_bus.status.msg_auth <= '0';
            if (in_bus.control.msg_auth_ready = '1') then
                reg_nx.state := IDLE;
            else
                reg_nx.state := FAILURE;
            end if;
        end case;
        next_reg_s <= reg_nx;
    end process wombocombo;
end architecture Behavioral;