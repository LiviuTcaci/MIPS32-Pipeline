library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        jump : in STD_LOGIC;
        pcsrc : in STD_LOGIC;
        jump_addr : in STD_LOGIC_VECTOR(31 downto 0);
        branch_addr : in STD_LOGIC_VECTOR(31 downto 0);
        instr_out : out STD_LOGIC_VECTOR(31 downto 0);
        pc_next : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IFetch;

architecture Behavioral of IFetch is
    type rom_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal rom : rom_type := (
        0 => B"100011_00000_01000_0000000000000000", -- X"8C000000", 00: lw $0, 0($0)
        1 => B"100011_00000_01001_0000000000000100", -- X"8C010004", 01: lw $1, 4($0)
        2 => B"001000_01001_01001_1111111111111111", -- X"2129FFFF", 02: addi $1, $1, -1
        3 => B"100011_01000_01010_0000000000000000", -- X"8D0A0000", 03: lw $2, 0($0)
        4 => B"001000_01000_01000_0000000000000100", -- X"21080004", 04: addi $0, $0, 4
        5 => B"100011_01000_01011_0000000000000000", -- X"8D0B0000", 05: lw $3, 0($0)
        6 => B"000000_01010_01011_01100_00000_101010", -- X"014B601A", 06: slt $4, $2, $3
        7 => B"000100_01100_00000_0000000000001010", -- X"118C000A", 07: beq $4, $0, exit
        8 => B"001000_01000_01000_0000000000000100", -- X"21080004", 08: addi $0, $0, 4
        9 => B"001000_01001_01001_1111111111111111", -- X"2129FFFF", 09: addi $1, $1, -1
        10 => B"000101_01001_00000_1111111111111011", -- X"1529FFFB", 10: bne $1, $0, loop
        11 => B"101011_00000_01100_0000000000001000", -- X"AC0C0008", 11: sw $4, 8($0)
        others => X"00000000"
    );

    signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pcaux, nextaddr,auxsgn:std_logic_vector(31 downto 0);
begin

    pc_process: process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                pc <= nextaddr;
            end if;
        end if;
    end process;

    instr_out <= rom(conv_integer(pc(6 downto 2)));

    pcaux <= pc+4;
    auxsgn <=branch_addr when pcsrc = '1' else pcaux;
    pc_next <= jump_addr when jump = '1' else auxsgn;

end Behavioral;