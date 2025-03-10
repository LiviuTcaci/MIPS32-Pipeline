library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end MEM;

architecture Behavioral of MEM is

    type mem_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal MEM : mem_type := (
        X"0000000C", -- address of the start of the array
        X"0000000A", -- length of the array
        X"00000000",
        X"00000000",
        X"00000000",
        X"00000000",
        X"00000000",
        X"00000000",
        X"00000000", -- addr 8 of the result
        X"00000000",
        X"00000000",
        X"00000000",
        X"00000001", -- 1 -- addr of the start of array 12
        X"00000002", -- 2
        X"00000003", -- 3
        X"00000004", -- 4
        X"00000005", -- 5
        X"00000006", -- 6
        X"00000007", -- 7
        X"00000008", -- 8
        X"00000009", -- 9
        X"0000000A", -- 10
        others => X"00000000");

begin

    -- Data Memory
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite = '1' then
                MEM(conv_integer(ALUResIn(7 downto 2))) <= RD2;
            end if;
        end if;
    end process;

    -- outputs
    MemData <= MEM(conv_integer(ALUResIn(7 downto 2)));
    ALUResOut <= ALUResIn;

end Behavioral;