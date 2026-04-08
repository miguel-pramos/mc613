LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memorybackground IS
    PORT (
        we          : IN  STD_LOGIC;                     
        write_addr  : IN  STD_LOGIC_VECTOR (8 DOWNTO 0); 
        data_in     : IN  STD_LOGIC;                    
        
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        
        tile_id_out : OUT STD_LOGIC                  
    );
END memorybackground;

ARCHITECTURE behavioral OF memorybackground IS
    -- A memória agora armazena apenas 1 bit por posição
    TYPE ram_array IS ARRAY (0 TO 511) OF STD_LOGIC;
    
    -- Função para inicializar a memória (ex: tudo em '0')
    IMPURE FUNCTION preencher_ram RETURN ram_array IS
        VARIABLE tmp_ram : ram_array := (OTHERS => '0');
    BEGIN
        -- Exemplo: Preencher os primeiros 150 tiles com '1' e o restante com '0'
        FOR i IN 0 TO 149 LOOP
            tmp_ram(i) := '1';
        END LOOP;   
        RETURN tmp_ram;
    END FUNCTION;

    SIGNAL ram_memory : ram_array := preencher_ram;

    SIGNAL tile_x    : UNSIGNED(4 DOWNTO 0);
    SIGNAL tile_y    : UNSIGNED(4 DOWNTO 0);
    SIGNAL read_addr : INTEGER RANGE 0 TO 511;
  
BEGIN
    -- Lógica de endereçamento permanece a mesma (VGA 640x480 com tiles 32x32)
    tile_x <= UNSIGNED(pixel_x(9 DOWNTO 5));
    tile_y <= UNSIGNED(pixel_y(9 DOWNTO 5));

    read_addr <= TO_INTEGER(tile_y) * 20 + TO_INTEGER(tile_x);

    -- PROCESSO DE ESCRITA
    PROCESS(we, write_addr, data_in)
    BEGIN
        IF we = '1' THEN
            ram_memory(TO_INTEGER(UNSIGNED(write_addr))) <= data_in;
        END IF;
    END PROCESS;

    -- LEITURA
    tile_id_out <= ram_memory(read_addr);

END behavioral;