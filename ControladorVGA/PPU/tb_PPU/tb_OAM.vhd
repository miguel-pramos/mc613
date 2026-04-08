LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_oam_memory IS
END tb_oam_memory;

ARCHITECTURE behavior OF tb_oam_memory IS

    COMPONENT oam_memory
        PORT(
            we            : IN  STD_LOGIC;
            sprite_sel    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            in_x          : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            in_y          : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            in_id         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            pixel_x       : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            pixel_y       : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
            sprite_id_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    signal we            : std_logic := '0';
    signal sprite_sel    : std_logic_vector(1 downto 0) := "00";
    signal in_x          : std_logic_vector(9 downto 0) := (others => '0');
    signal in_y          : std_logic_vector(9 downto 0) := (others => '0');
    signal in_id         : std_logic_vector(7 downto 0) := (others => '0');
    signal pixel_x       : std_logic_vector(9 downto 0) := (others => '0');
    signal pixel_y       : std_logic_vector(9 downto 0) := (others => '0');
    signal sprite_id_out : std_logic_vector(7 downto 0);

BEGIN

    -- 3. Instanciando a Unidade Sob Teste (UUT)
    uut: oam_memory PORT MAP (
        we => we,
        sprite_sel => sprite_sel,
        in_x => in_x,
        in_y => in_y,
        in_id => in_id,
        pixel_x => pixel_x,
        pixel_y => pixel_y,
        sprite_id_out => sprite_id_out
    );

    stim_proc: process
    begin		
        -- Aguarda o sistema estabilizar
        wait for 100 ns;
        
        -- Teste A: Pixel vazio (0,0). Esperado: ID 00000000 (transparente)
        pixel_x <= std_logic_vector(to_unsigned(0, 10));
        pixel_y <= std_logic_vector(to_unsigned(0, 10));
        wait for 20 ns;

        -- Teste B: Dentro do Sprite 0 (X=110, Y=110). Esperado: ID x"01"
        pixel_x <= std_logic_vector(to_unsigned(110, 10));
        pixel_y <= std_logic_vector(to_unsigned(110, 10));
        wait for 20 ns;

        -- Teste C: Fora do Sprite 0, quase na borda (X=132, Y=100). Esperado: ID 00000000
        -- (O sprite vai de 100 até 131)
        pixel_x <= std_logic_vector(to_unsigned(132, 10));
        pixel_y <= std_logic_vector(to_unsigned(100, 10));
        wait for 20 ns;

        -- Teste D: Dentro do Sprite 3 (X=415, Y=265). Esperado: ID x"04"
        pixel_x <= std_logic_vector(to_unsigned(415, 10));
        pixel_y <= std_logic_vector(to_unsigned(265, 10));
        wait for 20 ns;

        -- Teste E: Dentro do Sprite 2 (X=310, Y=210). Esperado: ID x"03"
        pixel_x <= std_logic_vector(to_unsigned(310, 10));
        pixel_y <= std_logic_vector(to_unsigned(210, 10));
        wait for 20 ns;

        -- Teste F: Dentro do Sprite 1 (X=210, Y=160). Esperado: ID x"02"
        pixel_x <= std_logic_vector(to_unsigned(210, 10));
        pixel_y <= std_logic_vector(to_unsigned(160, 10));
        wait for 20 ns;
        
        -- Vamos mover o Sprite 0 para X=50, Y=50 e mudar o ID para x"99"
        we <= '1';
        sprite_sel <= "00"; -- Seleciona o Sprite 0
        in_x <= std_logic_vector(to_unsigned(50, 10));
        in_y <= std_logic_vector(to_unsigned(50, 10));
        in_id <= x"99";
        wait for 20 ns;
        
        -- Desliga a escrita
        we <= '0';
        wait for 20 ns;

        -- Teste G: Antiga posição do Sprite 0 (110, 110). Esperado: ID 00000000
        pixel_x <= std_logic_vector(to_unsigned(110, 10));
        pixel_y <= std_logic_vector(to_unsigned(110, 10));
        wait for 20 ns;

        -- Teste H: Nova posição do Sprite 0 (60, 60). Esperado: ID x"99"
        pixel_x <= std_logic_vector(to_unsigned(60, 10));
        pixel_y <= std_logic_vector(to_unsigned(60, 10));
        wait for 20 ns;

        -- Fim da simulação
        wait;
    end process;

END behavior;