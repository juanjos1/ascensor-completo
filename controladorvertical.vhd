library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controladorvertical is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        piso_destino : in  STD_LOGIC_VECTOR(2 downto 0);
        dir          : in  STD_LOGIC;
        -- Salidas:
        piso_actual  : out STD_LOGIC_VECTOR(2 downto 0);
        piso_7seg    : out STD_LOGIC_VECTOR(6 downto 0);
        llegada      : out STD_LOGIC;
		  dir_out      : out std_LOGIC;
		  dir_out_bajar :out std_LOGIC
		  
    );
end controladorvertical;

architecture controladorvertical_arch of controladorvertical is
    signal piso_act_reg : integer range 0 to 4 := 0;
    signal llegada_reg  : STD_LOGIC := '0';
    signal destino_int  : integer range 0 to 4 := 0; 
	 
    function decode_7seg(digit: unsigned(3 downto 0)) return std_logic_vector is
    begin
       case digit is
         when "0000" => return "1111001"; 
         when "0001" => return "0100100"; 
         when "0010" => return "0110000"; 
         when "0011" => return "0011001"; 
		   when "0100" => return "0010010";	
         when others => return "1111111"; 
       end case;
    end function;
    
begin
    process(clk, reset)

    begin
        if reset = '1' then
            piso_act_reg <= 0;
            llegada_reg  <= '0';
			destino_int <= 0;
        elsif rising_edge(clk) then
           destino_int <= to_integer(unsigned(piso_destino));

            if piso_act_reg = destino_int then
                llegada_reg <= '1';  
            else
                llegada_reg <= '0';
                if dir = '1' then  
                    if piso_act_reg < 4 then
                        piso_act_reg <= piso_act_reg + 1;
                    end if;
                else  
                    if piso_act_reg > 0 then
                        piso_act_reg <= piso_act_reg - 1;
                    end if;
                end if;
            end if;
        end if;
		  

		  
    end process;
    
	 
	 
    piso_actual <= std_logic_vector(to_unsigned(piso_act_reg, 3));
    piso_7seg   <= decode_7seg(to_unsigned(piso_act_reg, 4));
    llegada     <= llegada_reg;
    dir_out<=dir;
	 dir_out_bajar <= '1' when (dir = '0' and piso_act_reg /= destino_int) else '0';
end controladorvertical_arch;
