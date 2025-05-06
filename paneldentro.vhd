library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity paneldentro is
    Port (
        clk             : in  STD_LOGIC;  
        reset           : in  STD_LOGIC;  
        btn_piso1       : in  STD_LOGIC;  
        btn_piso2       : in  STD_LOGIC;  
        btn_piso3       : in  STD_LOGIC;  
        btn_piso4       : in  STD_LOGIC;  
        btn_piso5       : in  STD_LOGIC;  
        btn_abrir       : in  STD_LOGIC;  
        btn_cerrar      : in  STD_LOGIC;  
        piso_actual     : in  STD_LOGIC_VECTOR(2 downto 0); 
        puertas_abiertas: in  STD_LOGIC;  
        puertas_cerradas: in  STD_LOGIC;  
        solicitud_pisos : out STD_LOGIC_VECTOR(4 downto 0); 
        solicitud_abrir : out STD_LOGIC;  
        solicitud_cerrar: out STD_LOGIC   
    );
end paneldentro;

architecture paneldentro_arch of paneldentro is
    signal pisos_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal abrir_reg, cerrar_reg : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pisos_reg <= (others => '0');
            abrir_reg <= '0';
            cerrar_reg <= '0';
        elsif rising_edge(clk) then
            if btn_piso1 = '1' then
                pisos_reg(0) <= '1';
            end if;
            if btn_piso2 = '1' then
                pisos_reg(1) <= '1';
            end if;
            if btn_piso3 = '1' then
                pisos_reg(2) <= '1';
            end if;
            if btn_piso4 = '1' then
                pisos_reg(3) <= '1';
            end if;
            if btn_piso5 = '1' then
                pisos_reg(4) <= '1';
            end if;
            
            if btn_abrir = '1' then
                abrir_reg <= '1';
            end if;
            if btn_cerrar = '1' then
                cerrar_reg <= '1';
            end if;

            if pisos_reg(to_integer(unsigned(piso_actual))) = '1' then
                pisos_reg(to_integer(unsigned(piso_actual))) <= '0';
            end if;

            if puertas_abiertas = '1' then
                abrir_reg <= '0';
            end if;
            if puertas_cerradas = '1' then
                cerrar_reg <= '0';
            end if;
        end if;
    end process;
    
    -- Se asignan los registros a las salidas
    solicitud_pisos <= pisos_reg;
    solicitud_abrir <= abrir_reg;
    solicitud_cerrar <= cerrar_reg;

end paneldentro_arch;
