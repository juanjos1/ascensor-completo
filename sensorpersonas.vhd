library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sensorpersonas is
    Port (
        clk              : in  std_logic;  
        reset            : in  std_logic;  
        persona_entra    : in  std_logic;  
        persona_sale     : in  std_logic;  
        num_personas     : out integer;    
        alarma_personas  : out std_logic;   
		  luz:out std_logic
    );
end sensorpersonas;

architecture arch_sensor of sensorpersonas is
    signal contador        : integer := 0;
    signal clk_div         : std_logic := '0'; 
    signal count1          : integer range 0 to 24999999 := 0;  
begin

    process(clk)
    begin 
        if rising_edge(clk) then
            count1 <= count1 + 1;
            if count1 = 24999999 then
                clk_div <= not clk_div;
                count1 <= 0;
            end if;
        end if;
    end process;

    process(clk_div, reset)
    begin
        if reset = '1' then
            contador <= 0;
        elsif rising_edge(clk_div) then
            if persona_entra = '1' and contador < 11 then
                contador <= contador + 1;
            elsif persona_sale = '1' and contador > 0 then
                contador <= contador - 1;
            end if;
        end if;
    end process;
    
    num_personas <= contador;
    alarma_personas <= '1' when contador > 10 else '0';
	 luz<= '1' when contador >1 else'0';
  
end arch_sensor;