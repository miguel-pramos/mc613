LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memorybackground IS
    PORT (
        clk         : IN  STD_LOGIC;                     -- Novo: Entrada de Clock
        we          : IN  STD_LOGIC;                     
        write_addr  : IN  STD_LOGIC_VECTOR (8 DOWNTO 0); 
        data_in     : IN  STD_LOGIC;                    
        
        pixel_x     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        pixel_y     : IN  STD_LOGIC_VECTOR (9 DOWNTO 0); 
        
        tile_id_out : OUT STD_LOGIC                  
    );
END memorybackground;

ARCHITECTURE behavioral OF memorybackground IS
    TYPE ram_array IS ARRAY (0 TO 511) OF STD_LOGIC;
    
    IMPURE FUNCTION preencher_ram RETURN ram_array IS
        VARIABLE tmp_ram : ram_array := (OTHERS => '0');
    BEGIN
        FOR i IN 0 TO 149 LOOP
            tmp_ram(i) := '1';
        END LOOP;   
        RETURN tmp_ram;
    END FUNCTION;

    SIGNAL ram_memory : ram_array := preencher_ram;

    -- Sinais internos para a lógica de endereço
    SIGNAL read_addr : INTEGER RANGE 0 TO 511;
  
BEGIN
    -- A lógica combinacional para calcular o endereço permanece fora do processo 
    -- ou pode ser colocada dentro se você quiser registrar o endereço também.
    read_addr <= TO_INTEGER(UNSIGNED(pixel_y(9 DOWNTO 5))) * 20 + 
                 TO_INTEGER(UNSIGNED(pixel_x(9 DOWNTO 5)));

    -- PROCESSO SÍNCRONO (Escrita e Leitura)
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- Escrita síncrona
            IF we = '1' THEN
                ram_memory(TO_INTEGER(UNSIGNED(write_addr))) <= data_in;
            END IF;

            -- Leitura síncrona (Padrão para inferência de Block RAM)
            -- O dado na saída muda um ciclo após o endereço estar disponível
            tile_id_out <= ram_memory(read_addr);
        END IF;
    END PROCESS;

END behavioral;