library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlador is
    Port (
        clk              : in  STD_LOGIC;
        reset            : in  STD_LOGIC;
        enable           : in  STD_LOGIC;
        solicitud_pisos  : in  STD_LOGIC_VECTOR(4 downto 0);
        solicitud_abrir  : in  STD_LOGIC;
        solicitud_cerrar : in  STD_LOGIC;
        solicitud_subir  : in  STD_LOGIC_VECTOR(4 downto 0);
        solicitud_bajar  : in  STD_LOGIC_VECTOR(4 downto 0);
        piso_actual      : in  STD_LOGIC_VECTOR(2 downto 0);
        piso_destino     : out STD_LOGIC_VECTOR(2 downto 0);
        dir              : out STD_LOGIC;
        request_valid    : out STD_LOGIC;
        puerta_abierta   : out STD_LOGIC
    );
end controlador;

architecture controlador_arch of controlador is

    signal solicitudes_combinadas : STD_LOGIC_VECTOR(4 downto 0);
    signal destino_reg            : integer range 0 to 4 := 0;
    signal direccion_reg          : STD_LOGIC := '0';
    signal valid_reg              : STD_LOGIC := '0';
    signal ascensor_movimiento    : STD_LOGIC := '0';

    signal door_counter : integer range 0 to 25 := 0;

    signal llegada : STD_LOGIC := '0';
    
begin

    llegada <= '1' when (to_integer(unsigned(piso_actual)) = destino_reg) else '0';

    process(clk, reset)
        variable i : integer;
    begin
        if reset = '1' then
            destino_reg            <= 0;
            direccion_reg          <= '0';
            valid_reg              <= '0';
            solicitudes_combinadas <= (others => '0');
            ascensor_movimiento    <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                solicitudes_combinadas <= solicitud_pisos or solicitud_subir or solicitud_bajar;
                valid_reg <= '0';
                for i in 0 to 4 loop
                    if solicitudes_combinadas(i) = '1' then
                        destino_reg <= i;
                        valid_reg   <= '1';
                        exit;
                    end if;
                end loop;
                
                if valid_reg = '1' then
                    if to_integer(unsigned(piso_actual)) < destino_reg then
                        direccion_reg <= '1';  -- Subir
                    elsif to_integer(unsigned(piso_actual)) > destino_reg then
                        direccion_reg <= '0';  -- Bajar
                    else
                        direccion_reg <= '0';
                    end if;
                end if;
                
                if to_integer(unsigned(piso_actual)) /= destino_reg then
                    ascensor_movimiento <= '1';
                else
                    ascensor_movimiento <= '0';
                end if;
            else
                destino_reg         <= to_integer(unsigned(piso_actual));
                direccion_reg       <= '0';
                valid_reg           <= '0';
                ascensor_movimiento <= '0';
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            door_counter <= 0;
        elsif rising_edge(clk) then
            if ascensor_movimiento = '1' then
                door_counter <= 0;
            elsif ((llegada = '1') or (solicitud_abrir = '1')) then
                if solicitud_cerrar = '1' then
                    door_counter <= 0;
                else
                    if door_counter < 25 then
                        door_counter <= door_counter + 1;
                    else
                        door_counter <= 0;
                    end if;
                end if;
            else
                door_counter <= 0;
            end if;
        end if;
    end process;

    puerta_abierta <= '1' when (door_counter >= 5 and door_counter < 10) else '0';

    piso_destino  <= std_logic_vector(to_unsigned(destino_reg, 3));
    dir           <= direccion_reg;
    request_valid <= valid_reg;

end controlador_arch;