LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY oam_memory IS
    PORT (
        clk         : IN  STD_LOGIC;                   
        
        -- Interface de Escrita
        we          : IN  STD_LOGIC;                     
        sprite_sel  : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); 
        in_x        : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        in_y        : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        in_id       : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); 
        
        -- Interface de Leitura 
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        
        -- Saídas para a "Sprite Memory"
        sprite_id_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); 
        sprite_x_out  : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
        sprite_y_out  : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)   
    );
END oam_memory;

ARCHITECTURE behavioral OF oam_memory IS

    TYPE sprite_info IS RECORD
        x  : UNSIGNED(9 DOWNTO 0);
        y  : UNSIGNED(9 DOWNTO 0);
        id : STD_LOGIC_VECTOR(1 DOWNTO 0);
    END RECORD;

    TYPE oam_array IS ARRAY (0 TO 3) OF sprite_info;

    SIGNAL oam : oam_array := (
        0 => (x => TO_UNSIGNED(100, 10), y => TO_UNSIGNED(100, 10), id => "00"), -- Topo Esquerda
        1 => (x => TO_UNSIGNED(132, 10), y => TO_UNSIGNED(100, 10), id => "01"), -- Topo Direita (+32 no X)
        2 => (x => TO_UNSIGNED(100, 10), y => TO_UNSIGNED(132, 10), id => "10"), -- Baixo Esquerda (+32 no Y)
        3 => (x => TO_UNSIGNED(132, 10), y => TO_UNSIGNED(132, 10), id => "11")  -- Baixo Direita (+32 em X e Y)
    );

BEGIN

    -- PROCESSO ÚNICO SÍNCRONO
    PROCESS(clk)
        VARIABLE px : UNSIGNED(9 DOWNTO 0);
        VARIABLE py : UNSIGNED(9 DOWNTO 0);
        VARIABLE index_write : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            
            -- LÓGICA DE ESCRITA
            index_write := TO_INTEGER(UNSIGNED(sprite_sel));
            IF we = '1' THEN
                oam(index_write).x  <= UNSIGNED(in_x);
                oam(index_write).y  <= UNSIGNED(in_y);
                oam(index_write).id <= in_id;
            END IF;

            -- LÓGICA DE LEITURA (Síncrona)
            px := UNSIGNED(pixel_x);
            py := UNSIGNED(pixel_y);
            
            sprite_id_out <= "000";
            sprite_x_out  <= (OTHERS => '0'); 
            sprite_y_out  <= (OTHERS => '0'); 

            -- O loop de detecção
            FOR i IN 3 DOWNTO 0 LOOP
                IF (px >= oam(i).x) AND (px < (oam(i).x + 32)) AND
                   (py >= oam(i).y) AND (py < (oam(i).y + 32)) THEN
                   
                    sprite_id_out <= '1' & oam(i).id;
                    
                    sprite_x_out  <= STD_LOGIC_VECTOR(oam(i).x);
                    sprite_y_out  <= STD_LOGIC_VECTOR(oam(i).y);
                END IF;
            END LOOP;
            
        END IF;
    END PROCESS;

END behavioral;