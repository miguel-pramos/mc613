library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
  port (
    pixel_clk    : in  std_logic;
    reset_n      : in  std_logic;
    r_in         : in  std_logic_vector(7 downto 0);
    g_in         : in  std_logic_vector(7 downto 0);
    b_in         : in  std_logic_vector(7 downto 0);
    pixel_x      : out std_logic_vector(9 downto 0);
    pixel_y      : out std_logic_vector(9 downto 0);
    video_active : out std_logic;
    VGA_R        : out std_logic_vector(7 downto 0);
    VGA_G        : out std_logic_vector(7 downto 0);
    VGA_B        : out std_logic_vector(7 downto 0);
    VGA_HS       : out std_logic;
    VGA_VS       : out std_logic;
    VGA_BLANK_N  : out std_logic;
    VGA_SYNC_N   : out std_logic;
    VGA_CLK      : out std_logic
  );
end vga;

architecture behavioural of vga is
    constant H_VISIBLE_AREA : integer := 640;
    constant H_FRONT_PORCH  : integer := 16;
    constant H_SYNC_PULSE   : integer := 96;
    constant H_BACK_PORCH   : integer := 48;
    constant H_TOTAL        : integer := H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    
    constant V_VISIBLE_AREA : integer := 480;
    constant V_FRONT_PORCH  : integer := 10;
    constant V_SYNC_PULSE   : integer := 2;
    constant V_BACK_PORCH   : integer := 33;
    constant V_TOTAL        : integer := V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    signal x_counter : integer range 0 to H_TOTAL - 1 := 0;
    signal y_counter : integer range 0 to V_TOTAL - 1 := 0;
    signal video_on  : std_logic; -- Sinal interno para evitar leitura de porta 'out'

begin
    --  Lógica dos Contadores
    process(reset_n, pixel_clk)
    begin
        if reset_n = '0' then -- Corrigido para ativo baixo (padrão DE1-SoC)
            x_counter <= 0;
            y_counter <= 0;
        elsif rising_edge(pixel_clk) then
            if x_counter = H_TOTAL - 1 then
                x_counter <= 0;
                if y_counter = V_TOTAL - 1 then
                    y_counter <= 0;
                else
                    y_counter <= y_counter + 1;
                end if;
            else
                x_counter <= x_counter + 1; 
            end if;
        end if;
    end process;

    --  Geração do sinal Video Active 
    video_on <= '1' when (x_counter < H_VISIBLE_AREA) and (y_counter < V_VISIBLE_AREA) else '0';
    video_active <= video_on;

    --  Saída das Coordenadas
    pixel_x <= std_logic_vector(to_unsigned(x_counter, 10));
    pixel_y <= std_logic_vector(to_unsigned(y_counter, 10));

    --  Sinais de Sincronização
    VGA_HS <= '0' when (x_counter >= H_VISIBLE_AREA + H_FRONT_PORCH) and 
                       (x_counter < H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE) else '1';
    VGA_VS <= '0' when (y_counter >= V_VISIBLE_AREA + V_FRONT_PORCH) and 
                       (y_counter < V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE) else '1';

    --  Saídas Físicas da VGA
    VGA_R       <= r_in when video_on = '1' else (others => '0');
    VGA_G       <= g_in when video_on = '1' else (others => '0');
    VGA_B       <= b_in when video_on = '1' else (others => '0');
    VGA_BLANK_N <= video_on;
    VGA_SYNC_N  <= '0'; -- Na DE1-SoC, SYNC_N geralmente é '0' se não usar Sync-on-Green
    VGA_CLK     <= pixel_clk;

end behavioural;