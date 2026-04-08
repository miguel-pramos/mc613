LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_memorybackground IS
-- Testbench não possui portas
END tb_memorybackground;

ARCHITECTURE behavior OF tb_memorybackground IS

    -- Component Declaration para o módulo original
    COMPONENT memorybackground
        PORT(
            we          : IN  STD_LOGIC;
            write_addr  : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
            data_in     : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
            pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            tile_id_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    END COMPONENT;

    -- Sinais internos para conectar ao componente
    signal we          : std_logic := '0';
    signal write_addr  : std_logic_vector(8 downto 0) := (others => '0');
    signal data_in     : std_logic_vector(8 downto 0) := (others => '0');
    signal pixel_x     : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y     : std_logic_vector(9 downto 0) := (others => '0');
    signal tile_id_out : std_logic_vector(8 downto 0);

BEGIN

    -- Instância da Unidade Sob Teste (UUT)
    uut: memorybackground PORT MAP (
          we => we,
          write_addr => write_addr,
          data_in => data_in,
          pixel_x => pixel_x,
          pixel_y => pixel_y,
          tile_id_out => tile_id_out
        );

    -- Processo de estímulo
    stim_proc: process
    begin		
        -- Aguarda um tempo inicial
        wait for 100 ns;

        -- TESTE 1: Pixel (0,0) -> Deve resultar no Tile 0
        pixel_x <= std_logic_vector(to_unsigned(0, 10));
        pixel_y <= std_logic_vector(to_unsigned(0, 10));
        wait for 20 ns;

        -- TESTE 2: Pixel (32, 0) -> Deve resultar no Tile 1 (X=1, Y=0)
        -- Endereço = 0 * 20 + 1 = 1
        pixel_x <= std_logic_vector(to_unsigned(32, 10));
        pixel_y <= std_logic_vector(to_unsigned(0, 10));
        wait for 20 ns;

        -- TESTE 3: Pixel (0, 32) -> Deve resultar no Tile 20 (X=0, Y=1)
        -- Endereço = 1 * 20 + 0 = 20
        pixel_x <= std_logic_vector(to_unsigned(0, 10));
        pixel_y <= std_logic_vector(to_unsigned(32, 10));
        wait for 20 ns;

        -- TESTE 4: Pixel (639, 479) -> Canto inferior direito
        -- Tile X = 639/32 = 19, Tile Y = 479/32 = 14
        -- Endereço = 14 * 20 + 19 = 280 + 19 = 299
        pixel_x <= std_logic_vector(to_unsigned(639, 10));
        pixel_y <= std_logic_vector(to_unsigned(479, 10));
        wait for 20 ns;

        -- Finaliza a simulação
        wait;
    end process;

END behavior;