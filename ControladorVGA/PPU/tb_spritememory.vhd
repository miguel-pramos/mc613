LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_tileset_memory IS
END tb_tileset_memory;

ARCHITECTURE behavior OF tb_tileset_memory IS

    
    COMPONENT tileset_memory
        PORT (
            tile_id  : IN  STD_LOGIC;
            pixel_x  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            pixel_y  : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
            color_id : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    END COMPONENT;

    
    SIGNAL tb_tile_id  : STD_LOGIC := '0';
    SIGNAL tb_pixel_x  : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_pixel_y  : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
    
    -- O sinal de saída apenas aguarda o resultado do chip.
    SIGNAL tb_color_id : STD_LOGIC_VECTOR (2 DOWNTO 0);

BEGIN

    UUT: tileset_memory PORT MAP (
        tile_id  => tb_tile_id,
        pixel_x  => tb_pixel_x,
        pixel_y  => tb_pixel_y,
        color_id => tb_color_id
    );

    stim_proc: PROCESS
    BEGIN
        -- --- TESTE 1: Lendo o Tile 0, no pixel superior esquerdo (0,0) ---
        -- Como tile_id é '0', esperamos que color_id seja "001"
        tb_tile_id <= '0';
        tb_pixel_x <= std_logic_vector(to_unsigned(0, 10));
        tb_pixel_y <= std_logic_vector(to_unsigned(0, 10));
        WAIT FOR 10 ns; -- Damos um tempo para a eletricidade virtual propagar

        -- --- TESTE 2: Lendo o Tile 0, em um pixel do meio (15,15) ---
        -- Esperamos que color_id continue "001", pois o Tile 0 é sólido nessa versão
        tb_pixel_x <= std_logic_vector(to_unsigned(15, 10));
        tb_pixel_y <= std_logic_vector(to_unsigned(15, 10));
        WAIT FOR 10 ns;

        -- --- TESTE 3: Lendo o Tile 1 ---
        -- Trocamos o ID. Agora esperamos que color_id seja "010"
        tb_tile_id <= '1';
        tb_pixel_x <= std_logic_vector(to_unsigned(0, 10));
        tb_pixel_y <= std_logic_vector(to_unsigned(0, 10));
        WAIT FOR 10 ns;

        -- --- TESTE 4: Testando o limite da matemática (Pixel global 63) ---
        -- Como extraímos apenas os 5 bits no seu código, a coordenada global 63 
        -- equivale ao índice interno 31 (resto da divisão).
        -- Como ainda estamos no tile 1, esperamos color_id = "010".
        tb_pixel_x <= std_logic_vector(to_unsigned(63, 10));
        tb_pixel_y <= std_logic_vector(to_unsigned(63, 10));
        WAIT FOR 10 ns;

        -- Fim da simulação (O VHDL entra em pausa infinita aqui)
        WAIT; 
    END PROCESS;

END behavior;