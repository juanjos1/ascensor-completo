library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  

entity panelafuera is
    Port (
        clk            : in  STD_LOGIC;  
        reset          : in  STD_LOGIC;  
        btn_subir1     : in  STD_LOGIC;  
        btn_bajar5     : in  STD_LOGIC; 
        btn_subir2     : in  STD_LOGIC;  
        btn_bajar2     : in  STD_LOGIC;  
        btn_subir3     : in  STD_LOGIC;  
        btn_bajar3     : in  STD_LOGIC;  
        btn_subir4     : in  STD_LOGIC;  
        btn_bajar4     : in  STD_LOGIC;  
        piso_actual    : in  STD_LOGIC_VECTOR(2 downto 0); 
        solicitud_subir: out STD_LOGIC_VECTOR(4 downto 0); 
        solicitud_bajar: out STD_LOGIC_VECTOR(4 downto 0)   
    );
end panelafuera;

architecture panelafuera_arch of panelafuera is
    signal subir_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal bajar_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            subir_reg <= (others => '0');
            bajar_reg <= (others => '0');
        elsif rising_edge(clk) then
            if btn_subir1 = '1' then
                subir_reg(0) <= '1';
            end if;
            if btn_subir2 = '1' then
                subir_reg(1) <= '1';
            end if;
            if btn_subir3 = '1' then
                subir_reg(2) <= '1';
            end if;
            if btn_subir4 = '1' then
                subir_reg(3) <= '1';
            end if;
            
            if btn_bajar5 = '1' then
                bajar_reg(4) <= '1';
            end if;
            if btn_bajar4 = '1' then
                bajar_reg(3) <= '1';
            end if;
            if btn_bajar3 = '1' then
                bajar_reg(2) <= '1';
            end if;
            if btn_bajar2 = '1' then
                bajar_reg(1) <= '1';
            end if;

            if to_integer(unsigned(piso_actual)) <= 4 then  
                if subir_reg(to_integer(unsigned(piso_actual))) = '1' then
                    subir_reg(to_integer(unsigned(piso_actual))) <= '0';
                end if;
                if bajar_reg(to_integer(unsigned(piso_actual))) = '1' then
                    bajar_reg(to_integer(unsigned(piso_actual))) <= '0';
                end if;
            end if;
        end if;
    end process;

    solicitud_subir <= subir_reg;
    solicitud_bajar <= bajar_reg;

end panelafuera_arch;

