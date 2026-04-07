library ieee;
use ieee.numeric.all;
use ieee.std_logic_1164.all;

entity vga_controller is
  port (
    -- Entradas de Controle de Clock e Reset
    pixel_clk    : in  std_logic;                     -- Clock de 25.175 MHz gerado pelo PLL
    reset_n      : in  std_logic;                     -- Reset assíncrono (ativo baixo)

    -- Entradas de Cor (vindos da PPU)
    r_in         : in  std_logic_vector(7 downto 0);  -- Intensidade do vermelho do pixel atual
    g_in         : in  std_logic_vector(7 downto 0);  -- Intensidade do verde do pixel atual
    b_in         : in  std_logic_vector(7 downto 0);  -- Intensidade do azul do pixel atual

    -- Saídas de Controle Interno (enviados para a PPU)
    pixel_x      : out std_logic_vector(9 downto 0);  -- Coordenada X atual
    pixel_y      : out std_logic_vector(9 downto 0);  -- Coordenada Y atual
    video_active : out std_logic;                     -- '1' se estiver dentro da área visível (Active Video)

    -- Saídas Físicas (conectadas aos pinos da DE1-SoC)
    VGA_R        : out std_logic_vector(7 downto 0);  -- Saída VGA Vermelha
    VGA_G        : out std_logic_vector(7 downto 0);  -- Saída VGA Verde
    VGA_B        : out std_logic_vector(7 downto 0);  -- Saída VGA Azul
    VGA_HS       : out std_logic;                     -- Sincronismo Horizontal
    VGA_VS       : out std_logic;                     -- Sincronismo Vertical
    VGA_BLANK_N  : out std_logic;                     -- Fora da área visível (ou seja, deve ser '0' no blanking)
    VGA_SYNC_N   : out std_logic;                     -- Sincronização de vídeo
    VGA_CLK      : out std_logic                      -- Clock do pixel (espelho do pixel_clk)
    );
end vga_controller;

architecture behavioural of vga is
    constant H_VISIBLE_AREA : integer := 640;  -- Largura da área visível
    constant H_FRONT_PORCH : integer := 16;    -- Tempo de frente (front porch)
    constant H_SYNC_PULSE : integer := 96;      -- Duração do pulso de sincronização horizontal
    constant H_BACK_PORCH : integer := 48;      -- Tempo de trás (back porch)
    constant H_TOTAL : integer := H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;  -- Total de ciclos horizontais     
    
    constant V_VISIBLE_AREA : integer := 480;  -- Altura da área visível
    constant V_FRONT_PORCH : integer := 10;    -- Tempo de frente (front porch)
    constant V_SYNC_PULSE : integer := 2;       -- Duração do pulso de sincronização vertical
    constant V_BACK_PORCH : integer := 33;     -- Tempo de trás (back porch)
    constant V_TOTAL : integer := V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;  -- Total de ciclos verticais

    signal x_counter : integer range 0 to H_TOTAL - 1 := 0;  -- Contador horizontal
    signal y_counter : integer range 0 to V_TOTAL - 1 := 0;  -- Contador vertical

begin
    process(reset_n, pixel_clk)
    begin
        if reset_n = '1' then
            pixel_x <= (others => '0');
            pixel_y <= (others => '0');
            video_active <= '0';
        end if;

        if rising_edge(pixel_clk) then
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

    -- Gerenciamento de video_active
    process(pixel_x, pixel_y)
    begin
        if (pixel_x < H_VISIBLE_AREA) and (pixel_y < V_VISIBLE_AREA) then
            video_active <= '1';
        else
            video_active <= '0';
        end if;
    end process;

    pixel_x <= std_logic_vector(x_counter) when (x_counter < H_VISIBLE_AREA) else (others => '0');
    pixel_y <= std_logic_vector(y_counter) when (y_counter < V_VISIBLE_AREA) else (others => '0');

    -- Gerenciamento dos sinais de sincronização
    VGA_HS <= '0' when (x_counter >= H_VISIBLE_AREA + H_FRONT_PORCH) and (x_counter < H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE) else '1';
    VGA_VS <= '0' when (y_counter >= V_VISIBLE_AREA + V_FRONT_PORCH) and (y_counter < V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE) else '1';
    

    -- Saídas VGA
    VGA_R <= r_in when video_active = '1' else (others => '0');
    VGA_G <= g_in when video_active = '1' else (others => '0');
    VGA_B <= b_in when video_active = '1' else (others => '0');
    VGA_BLANK_N <= video_active;  -- Ativo quando dentro da área visível
    VGA_SYNC_N <= '1';  -- Sincronização de vídeo (fixo em '1')
    VGA_CLK <= pixel_clk;  -- Espelho do clock de pixel 

end behavioural;