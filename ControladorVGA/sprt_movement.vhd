library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sprt_movement is
    port (
        clk_vga     : in  std_logic; -- Clock de 25,127...MHz
        v_sync      : in  std_logic; -- Sinal VGA_VS (60Hz)
        reset       : in  std_logic;
        
        -- Saídas para a OAM
        pos_x       : out std_logic_vector(9 downto 0);
        pos_y       : out std_logic_vector(9 downto 0)
    );
end sprt_movement;

architecture behavioral of sprt_movement is
    -- Constantes de borda (considerando a bola como 32x32)
    constant X_MAX : integer := 640 - 32;
    constant Y_MAX : integer := 480 - 32;
    
    signal x_reg, y_reg : integer range 0 to 639 := 100;
    signal dx, dy       : integer range -1 to 1 := 1; -- 1 = direita/baixo, -1 = esquerda/cima
    
    signal vsync_old    : std_logic;
begin

    process(clk_vga, reset)
    begin
        if reset = '1' then
            x_reg <= 100;
            y_reg <= 100;
            dx <= 1;
            dy <= 1;
            vsync_old <= '0';
        elsif rising_edge(clk_vga) then
            vsync_old <= v_sync;
            
            -- Atualiza apenas uma vez por quadro (na borda de descida do V_SYNC)
            if vsync_old = '1' and v_sync = '0' then
                
                -- Lógica de Colisão em X
                if (x_reg >= X_MAX - 1) then
                    dx <= -1; -- Bateu na direita, vai pra esquerda
                elsif (x_reg <= 1) then
                    dx <= 1;  -- Bateu na esquerda, vai pra direita
                end if;
                
                -- Lógica de Colisão em Y
                if (y_reg >= Y_MAX - 1) then
                    dy <= -1; -- Bateu embaixo, vai pra cima
                elsif (y_reg <= 1) then
                    dy <= 1;  -- Bateu no topo, vai pra baixo
                end if;
                
                -- Movimentação
                x_reg <= x_reg + dx;
                y_reg <= y_reg + dy;
            end if;
        end if;
    end process;

    pos_x <= std_logic_vector(to_unsigned(x_reg, 10));
    pos_y <= std_logic_vector(to_unsigned(y_reg, 10));

end behavioral;