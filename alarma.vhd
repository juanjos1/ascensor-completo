library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Alarma is
    Port (
        reloj               : in  STD_LOGIC;  
        reinicio            : in  STD_LOGIC;  
        activacion_manual   : in  STD_LOGIC;  
        activacion_contador : in  STD_LOGIC;  
        alarma_sonora       : out STD_LOGIC;  
        alarma_visual       : out STD_LOGIC;  
        deshabilitadora     : out STD_LOGIC   
    );
end Alarma;

architecture Comportamiento of Alarma is
    signal alarma_activa : STD_LOGIC;
    
    signal buzzer_freq   : STD_LOGIC := '0';
    signal count_buzzer  : integer range 0 to 9999 := 0;  
    
    signal visual_freq   : STD_LOGIC := '0';
    signal count_visual  : integer range 0 to 24999999 := 0;  
begin
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            count_buzzer <= 0;
            buzzer_freq  <= '0';
        elsif rising_edge(reloj) then
            if count_buzzer = 12499 then
                buzzer_freq <= not buzzer_freq;
                count_buzzer <= 0;
            else
                count_buzzer <= count_buzzer + 1;
            end if;
        end if;
    end process;
    
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            count_visual <= 0;
            visual_freq  <= '0';
        elsif rising_edge(reloj) then
            if count_visual = 24999999 then
                visual_freq <= not visual_freq;
                count_visual <= 0;
            else
                count_visual <= count_visual + 1;
            end if;
        end if;
    end process;
    
    alarma_activa <= activacion_manual or activacion_contador;
    
    alarma_sonora <= buzzer_freq when (activacion_manual or activacion_contador) = '1' else '0';
    
    process(activacion_manual, visual_freq)
    begin
        if activacion_manual = '1' then
            alarma_visual <= visual_freq;
        else
            alarma_visual <= '0';
        end if;
    end process;
    
    deshabilitadora <= '1' when alarma_activa = '1' else '0';
end Comportamiento;

