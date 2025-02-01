library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MEM is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);
        MemWrite : in STD_LOGIC;
        MemData : out STD_LOGIC_VECTOR(31 downto 0)
    );
end MEM;

architecture Behavioral of MEM is
    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (
        others => (others => '0'));
    signal addr : STD_LOGIC_VECTOR(5 downto 0);
begin
    addr <= ALUResIn(7 downto 2); -- cuz discard last 2

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if MemWrite = '1' then
                    ram(conv_integer(addr)) <= RD2;
                    MemData <= RD2;
                end if;
            end if;
        end if;
    end process;
    MemData <= ram(conv_integer(addr)); -- citire asincrona
end Behavioral;