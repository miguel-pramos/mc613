LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY layer_selector IS
  PORT (
    color_bg     : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); -- ID Background
    color_sprite : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); -- ID Sprite
    color_out    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) 
  );
END layer_selector;

ARCHITECTURE behavioral OF layer_selector IS
BEGIN

  color_out <= color_bg WHEN color_sprite = "00000000" ELSE color_sprite;

END behavioral;