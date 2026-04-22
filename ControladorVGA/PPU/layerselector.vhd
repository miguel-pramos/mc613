LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY layer_selector IS
  PORT (
    color_bg     : IN  STD_LOGIC_VECTOR (2 DOWNTO 0); -- ID Background
    color_sprite : IN  STD_LOGIC_VECTOR (2 DOWNTO 0); -- ID Sprite
    color_out    : OUT STD_LOGIC_VECTOR (1 DOWNTO 0) 
  );
END layer_selector;

ARCHITECTURE behavioral OF layer_selector IS
BEGIN

  color_out <= color_bg(1 downto 0) WHEN color_sprite(2) = '0' ELSE color_sprite(1 downto 0);

END behavioral;