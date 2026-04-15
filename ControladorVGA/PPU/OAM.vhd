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
        
        -- Saída síncrona: Bit(2) é "Existe Sprite?", Bits(1 downto 0) é o ID
        sprite_id_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0) 
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
        0 => (x => TO_UNSIGNED(100, 10), y => TO_UNSIGNED(100, 10), id => "00"),
        1 => (x => TO_UNSIGNED(200, 10), y => TO_UNSIGNED(150, 10), id => "01"),
        2 => (x => TO_UNSIGNED(300, 10), y => TO_UNSIGNED(200, 10), id => "10"),
        3 => (x => TO_UNSIGNED(400, 10), y => TO_UNSIGNED(250, 10), id => "11")
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
            
            -- Valor padrão (nada detectado)
            sprite_id_out <= "000"; 

            -- O loop agora acontece dentro da borda de clock
            FOR i IN 0 TO 3 LOOP
                IF (px >= oam(i).x) AND (px < (oam(i).x + 32)) AND
                   (py >= oam(i).y) AND (py < (oam(i).y + 32)) THEN
                    
                    sprite_id_out <= '1' & oam(i).id;
                    
                END IF;
            END LOOP;
            
        END IF;
    END PROCESS;

END behavioral;