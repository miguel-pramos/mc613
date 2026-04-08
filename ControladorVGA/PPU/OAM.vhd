LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY oam_memory IS
    PORT (
        -- Interface de Escrita
        we          : IN  STD_LOGIC;                     -- 1 = Salvar nova posição
        sprite_sel  : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); -- Escolhe qual sprite mover (00, 01, 10, 11)
        in_x        : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); -- Nova coordenada X do sprite
        in_y        : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); -- Nova coordenada Y do sprite
        in_id       : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); -- Novo ID visual do sprite
        
        -- Interface de Leitura 
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); -- X atual da tela
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); -- Y atual da tela
        
        -- Saída para a "Sprite Memory"
        sprite_id_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END oam_memory;

ARCHITECTURE behavioral OF oam_memory IS

    -- 1. Criação do tipo "Ficha de Sprite" (RECORD)
    -- Isso agrupa as 3 informações vitais de um objeto
    TYPE sprite_info IS RECORD
        x  : UNSIGNED(9 DOWNTO 0);
        y  : UNSIGNED(9 DOWNTO 0);
        id : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;

    -- 2. Nossa memória OAM é uma lista com 4 dessas "fichas" (Índices 0 a 3)
    TYPE oam_array IS ARRAY (0 TO 3) OF sprite_info;

    -- 3. Inicializando a memória. 
    SIGNAL oam : oam_array := (
        0 => (x => TO_UNSIGNED(100, 10), y => TO_UNSIGNED(100, 10), id => x"01"),
        1 => (x => TO_UNSIGNED(200, 10), y => TO_UNSIGNED(150, 10), id => x"02"),
        2 => (x => TO_UNSIGNED(300, 10), y => TO_UNSIGNED(200, 10), id => x"03"),
        3 => (x => TO_UNSIGNED(400, 10), y => TO_UNSIGNED(250, 10), id => x"04")
    );

BEGIN

    -- =======================================================
    -- PROCESSO DE ESCRITA (Movimentação)
    -- =======================================================
    PROCESS(we, sprite_sel, in_x, in_y, in_id)
        VARIABLE index : INTEGER;
    BEGIN
        index := TO_INTEGER(UNSIGNED(sprite_sel));
        IF we = '1' THEN
            oam(index).x  <= UNSIGNED(in_x);
            oam(index).y  <= UNSIGNED(in_y);
            oam(index).id <= in_id;
        END IF;
    END PROCESS;

    -- =======================================================
    -- PROCESSO DE LEITURA (Bounding Box / Hitbox)
    -- =======================================================
    PROCESS(pixel_x, pixel_y, oam)
        VARIABLE px : UNSIGNED(9 DOWNTO 0);
        VARIABLE py : UNSIGNED(9 DOWNTO 0);
    BEGIN
        px := UNSIGNED(pixel_x);
        py := UNSIGNED(pixel_y);
        
        -- Começamos assumindo que o pixel atual é transparente (ID 0)
        sprite_id_out <= "00000000";

        -- Verificamos os 4 sprites (do último para o primeiro).
        -- Fazer do 3 DOWNTO 0 garante que o Sprite 0 tenha "prioridade" e desenhe por cima dos outros!
        FOR i IN 3 DOWNTO 0 LOOP
            
            -- A MÁGICA: O pixel X está entre o Início do Sprite e o Fim dele (X + 32)? 
            -- E o pixel Y está entre o Topo do Sprite e o Fundo dele (Y + 32)?
            IF (px >= oam(i).x) AND (px < (oam(i).x + 32)) AND
               (py >= oam(i).y) AND (py < (oam(i).y + 32)) THEN
                
                -- Se bateu na área do sprite, joga o ID dele para a saída!
                sprite_id_out <= oam(i).id;
                
            END IF;
        END LOOP;
        
    END PROCESS;

END behavioral;