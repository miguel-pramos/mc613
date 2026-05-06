library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dram_submodule is
    port (
        clk : in std_logic;
        rst : in std_logic;
        wEn : in std_logic;
        req : in std_logic;

        o_cas : out std_logic;
        o_ras : out std_logic;
        o_cs : out std_logic;
        o_we : out std_logic;
        ready : out std_logic
    );
end dram_submodule;

architecture Behavioural of dram_submodule is

    -- Sinais internos corrigidos (sem in/out)
    signal w_general_timer_end : std_logic;
    signal w_refresh_timer_end : std_logic;
    signal w_timer_clocks : std_logic_vector(3 downto 0);
    signal w_general_timer_on : std_logic;
    signal w_refresh_timer_on : std_logic;

begin

    -- Refresh sempre ligado exceto em reset
    w_refresh_timer_on <= not rst;

    -- FSM
    u_fsm_controller : entity work.fsm_dram_controller
        port map(
            clk => clk,
            rst => rst,
            wEn => wEn,
            req => req,
            general_timer_end => w_general_timer_end,
            refresh_timer_end => w_refresh_timer_end,

            s_cas => o_cas,
            s_ras => o_ras,
            s_cs => o_cs,
            s_we => o_we,
            ready => ready,
            timer_clocks => w_timer_clocks,
            general_timer_on => w_general_timer_on
        );

    -- temporizador geral
    u_general_timer : entity work.general_timer
        port map(
            clk => clk,
            timer_on => w_general_timer_on,
            max_ticks => w_timer_clocks,
            timer_end => w_general_timer_end
        );

    -- teporizador auto refresh
    u_refresh_timer : entity work.refresh_timer
        port map(
            clk => clk,
            timer_on => w_refresh_timer_on,
            timer_end => w_refresh_timer_end
        );

end Behavioural;