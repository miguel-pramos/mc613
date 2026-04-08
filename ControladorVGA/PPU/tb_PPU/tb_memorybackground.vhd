LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_memorybackground IS
END tb_memorybackground;

ARCHITECTURE behavior OF tb_memorybackground IS

    -- Component Declaration atualizado para 1 bit
    COMPONENT memorybackground
        PORT(
            we          : IN  STD_LOGIC;
            write_addr  : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
            data_in     : IN  STD_LOGIC;                    
            pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            tile_id_out : OUT STD_LOGIC                     
        );
    END COMPONENT;

    -- Sinais internos atualizados
    signal we          : std_logic := '0';
    signal write_addr  : std_logic_vector(8 downto 0) := (others => '0');
    signal data_in     : std_logic := '0';                 
    signal pixel_x     : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y     : std_logic_vector(9 downto 0) := (others => '0');
    signal tile_id_out : std_logic;                      

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
        -- Reset inicial
        we <= '0';
        write_addr <= (others => '0');
        data_in <= '0';
        wait for 100 ns;

        -- === PASSO 1: ESCRITA NA MEMÓRIA (Testando 1 bit) ===
        
        -- Define Tile 0 como "Parede" (1)
        we <= '1';
        write_addr <= std_logic_vector(to_unsigned(0, 9));
        data_in    <= '1'; 
        wait for 20 ns;

        -- Define Tile 1 como "Chão" (0)
        write_addr <= std_logic_vector(to_unsigned(1, 9));
        data_in    <= '0';
        wait for 20 ns;

        -- Define Tile 20 (primeiro da segunda linha) como "Parede" (1)
        write_addr <= std_logic_vector(to_unsigned(20, 9));
        data_in    <= '1';
        wait for 20 ns;

        we <= '0'; -- Desativa escrita
        wait for 40 ns;

        -- === PASSO 2: LEITURA E VERIFICAÇÃO ===
        
        -- Teste 1: Pixel (10, 10) está no Tile 0
        -- Esperado: tile_id_out = '1'
        pixel_x <= std_logic_vector(to_unsigned(10, 10));
        pixel_y <= std_logic_vector(to_unsigned(10, 10));
        wait for 20 ns;

        -- Teste 2: Pixel (40, 10) está no Tile 1 (X=1, Y=0)
        -- Esperado: tile_id_out = '0'
        pixel_x <= std_logic_vector(to_unsigned(40, 10));
        pixel_y <= std_logic_vector(to_unsigned(10, 10));
        wait for 20 ns;

        -- Teste 3: Pixel (10, 40) está no Tile 20 (X=0, Y=1)
        -- Esperado: tile_id_out = '1'
        pixel_x <= std_logic_vector(to_unsigned(10, 10));
        pixel_y <= std_logic_vector(to_unsigned(40, 10));
        wait for 20 ns;

        report "Simulação de 1-bit finalizada!" severity note;
        wait;
    end process;

END behavior;