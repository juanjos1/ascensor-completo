library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ascensorcompleto is
    Port (
        clk                : in  std_logic;
        reset              : in  std_logic;
        btn_energia        : in  std_logic;  
        btn_subir1         : in  std_logic;
        btn_bajar5         : in  std_logic;
        btn_subir2         : in  std_logic; 
        btn_bajar2         : in  std_logic;
        btn_subir3         : in  std_logic;
        btn_bajar3         : in  std_logic;
        btn_subir4         : in  std_logic;
        btn_bajar4         : in  std_logic;
        btn_piso1          : in  std_logic;
        btn_piso2          : in  std_logic;
        btn_piso3          : in  std_logic;
        btn_piso4          : in  std_logic;
        btn_piso5          : in  std_logic;
        btn_abrir          : in  std_logic;
        btn_cerrar         : in  std_logic;
        persona_entra      : in  std_logic;
        persona_sale       : in  std_logic;
		  
		  
        salida_audio_alarma : out std_logic; 
        salida_luz_alarma   : out std_logic;  
        pisos_7seg          : out std_logic_vector(6 downto 0);
        pisos_7seg_1          : out std_logic_vector(6 downto 0);
        puerta_abierta_out  : out std_logic ;
		  luz_out : buffer std_logic;
		  dir_out_completo :out std_logic;
	     dir_out_completo_bajar :out std_LOGIC



    );
end ascensorcompleto;

architecture Behavioral of ascensorcompleto is


    signal clk_1hz  : std_logic := '0';
    signal count_div: integer range 0 to 49999999 := 0;


    signal solicitud_subir  : std_logic_vector(4 downto 0);
    signal solicitud_bajar  : std_logic_vector(4 downto 0);
    signal solicitud_pisos  : std_logic_vector(4 downto 0) := (others => '0');
    signal solicitud_abrir  : std_logic;
    signal solicitud_cerrar : std_logic;
    signal piso_destino     : std_logic_vector(2 downto 0);
    signal dir              : std_logic;
	 signal dir_se           : std_LOGIC;
	 signal dir_out_completo_bajar_se     : STD_logic;
    signal request_valid    : std_logic;
    signal puerta_abierta   : std_logic;  
    signal piso_actual_int  : std_logic_vector(2 downto 0);
    signal piso_7seg_int    : std_logic_vector(6 downto 0);
    signal llegada          : std_logic;
    signal alarma_personas  : std_logic;
    signal alarma_sonora_int : std_logic;
    signal alarma_visual_int : std_logic;
	 signal luz_se         :std_logic;
    signal deshabilitadora_int: std_logic;
    signal enable_ctrl      : std_logic;
    
 
    component panelafuera is
        Port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            btn_subir1      : in  std_logic;
            btn_bajar5      : in  std_logic;
            btn_subir2      : in  std_logic;
            btn_bajar2      : in  std_logic;
            btn_subir3      : in  std_logic;
            btn_bajar3      : in  std_logic;
            btn_subir4      : in  std_logic;
            btn_bajar4      : in  std_logic;
            piso_actual     : in  std_logic_vector(2 downto 0);
            solicitud_subir : out std_logic_vector(4 downto 0);
            solicitud_bajar : out std_logic_vector(4 downto 0)
        );
    end component;
    
    component paneldentro is
        Port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            btn_piso1       : in  std_logic;
            btn_piso2       : in  std_logic;
            btn_piso3       : in  std_logic;
            btn_piso4       : in  std_logic;
            btn_piso5       : in  std_logic;
            btn_abrir       : in  std_logic;
            btn_cerrar      : in  std_logic;
            piso_actual     : in  std_logic_vector(2 downto 0);
            solicitud_pisos : out std_logic_vector(4 downto 0);
            solicitud_abrir : out std_logic;
            solicitud_cerrar: out std_logic
        );
    end component;
    
    component controlador is
        Port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            enable          : in  std_logic;
            solicitud_pisos : in  std_logic_vector(4 downto 0);
            solicitud_abrir : in  std_logic;
            solicitud_cerrar: in  std_logic;
            solicitud_subir : in  std_logic_vector(4 downto 0);
            solicitud_bajar : in  std_logic_vector(4 downto 0);
            piso_actual     : in  std_logic_vector(2 downto 0);
            piso_destino    : out std_logic_vector(2 downto 0);
            dir             : out std_logic;
            request_valid   : out std_logic;
            puerta_abierta  : out std_logic
        );
    end component;
    
    component controladorvertical is
        Port (
            clk          : in  std_logic;
            reset        : in  std_logic;
            piso_destino : in  std_logic_vector(2 downto 0);
            dir          : in  std_logic;
            piso_actual  : out std_logic_vector(2 downto 0);
            piso_7seg    : out std_logic_vector(6 downto 0);
				dir_out      : out std_LOGIC;
				dir_out_bajar :out std_LOGIC;
				
            llegada      : out std_logic
        );
    end component;
    
    component sensorpersonas is
        Port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            persona_entra : in  std_logic;
            persona_sale  : in  std_logic;
            num_personas  : out integer;
            alarma_personas : out std_logic;
			   luz                :out std_logic

        );
    end component;
    
    component alarma is
        Port (
            reloj               : in  std_logic;
            reinicio            : in  std_logic;
            activacion_manual   : in  std_logic;
            activacion_contador : in  std_logic;
            alarma_sonora       : out std_logic;
            alarma_visual       : out std_logic;
            deshabilitadora     : out std_logic

        );
    end component;
    
begin

    process(clk, reset)
    begin
        if reset = '1' then
            count_div <= 0;
            clk_1hz   <= '0';
        elsif rising_edge(clk) then
            if count_div = 49999999 then
                clk_1hz   <= not clk_1hz;
                count_div <= 0;
            else
                count_div <= count_div + 1;
            end if;
        end if;
    end process;
    

    enable_ctrl <= not deshabilitadora_int;
    

    PanelAfuera_inst: panelafuera
        port map (
            clk             => clk,
            reset           => reset,
            btn_subir1      => btn_subir1,
            btn_bajar5      => btn_bajar5,
            btn_subir2      => btn_subir2,
            btn_bajar2      => btn_bajar2,
            btn_subir3      => btn_subir3,
            btn_bajar3      => btn_bajar3,
            btn_subir4      => btn_subir4,
            btn_bajar4      => btn_bajar4,
            piso_actual     => piso_actual_int,  
            solicitud_subir => solicitud_subir,
            solicitud_bajar => solicitud_bajar
        );
    

    PanelDentro_inst: paneldentro
        port map (
            clk             => clk,
            reset           => reset,
            btn_piso1       => btn_piso1,
            btn_piso2       => btn_piso2,
            btn_piso3       => btn_piso3,
            btn_piso4       => btn_piso4,
            btn_piso5       => btn_piso5,
            btn_abrir       => btn_abrir,
            btn_cerrar      => btn_cerrar,
            piso_actual     => piso_actual_int,
            solicitud_pisos => solicitud_pisos,
            solicitud_abrir => solicitud_abrir,
            solicitud_cerrar=> solicitud_cerrar
        );
    
  
    Controlador_inst: controlador
        port map (
            clk             => clk_1hz,
            reset           => reset,
            enable          => enable_ctrl,
            solicitud_pisos => solicitud_pisos,
            solicitud_abrir => solicitud_abrir,
            solicitud_cerrar=> solicitud_cerrar,
            solicitud_subir => solicitud_subir,
            solicitud_bajar => solicitud_bajar,
            piso_actual     => piso_actual_int,
            piso_destino    => piso_destino,
            dir             => dir,
            request_valid   => request_valid,
			---	buzzer          => buzzer_out_se,
            puerta_abierta  => puerta_abierta
        );
    
 
    ControladorVertical_inst: controladorvertical
        port map (
            clk          => clk_1hz,
            reset        => reset,
            piso_destino => piso_destino,
            dir          => dir,
            piso_actual  => piso_actual_int,
            piso_7seg    => piso_7seg_int,
            llegada      => llegada,
				dir_out         => dir_se,
				dir_out_bajar => dir_out_completo_bajar_se
        );
    
    
    SensorPersonas_inst: sensorpersonas
        port map (
            clk           => clk,
            reset         => reset,
            persona_entra => persona_entra,
            persona_sale  => persona_sale,
            num_personas  => open,  
            alarma_personas => alarma_personas,
				luz => luz_se
        );
    

    Alarma_inst: alarma
        port map (
            reloj               => clk,
            reinicio            => reset,
            activacion_manual   => btn_energia, 
            activacion_contador => alarma_personas,
            alarma_sonora       => alarma_sonora_int,
            alarma_visual       => alarma_visual_int,
            deshabilitadora     => deshabilitadora_int
        );

    salida_audio_alarma <= alarma_sonora_int;
    salida_luz_alarma   <= alarma_visual_int;
    pisos_7seg          <= piso_7seg_int;
	 pisos_7seg_1        <= piso_7seg_int;
    puerta_abierta_out  <= puerta_abierta;
	 luz_out              <= luz_se;
    dir_out_completo    <= dir_se;
	 dir_out_completo_bajar<= dir_out_completo_bajar_se;
end Behavioral;
