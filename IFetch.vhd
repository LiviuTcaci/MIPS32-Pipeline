library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          en : in STD_LOGIC;
          BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
          JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
          Jump : in STD_LOGIC;
          PCSrc : in STD_LOGIC;
          Instruction : out STD_LOGIC_VECTOR(31 downto 0);
          PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

    -- Memorie ROM
    type tROM is array (0 to 34) of STD_LOGIC_VECTOR(31 downto 0);
    signal ROM : tROM := (

        -------------- PROGRAM DE TEST 15 --------------
        -- Să se determine dacă valorile unui șir de N elemente sunt ordonate crescător.
        -- Șirul este stocat în memorie începând cu adresa A (A≥12). A și N se citesc de la
        -- adresele 0, respectiv 4. Rezultatul (1=true / 0=false) se va scrie la adresa 8.

        B"000000_00000_00000_00001_00000_100000", -- 0: add $1, $0, $0       -- X"00000820"
        B"100011_00000_00010_0000000000000000",  -- 1: lw $2, 0($0)          -- X"8C020000"
        B"100011_00000_00100_0000000000000100",  -- 2: lw $4, 4($0)          -- X"8C040004"
        B"000000_00000_00000_00000_00000_000000", -- 3: NOOP                 -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 4: NOOP                 -- X"00000000"
        B"001000_00100_00100_1111111111111111",  -- 5: addi $4, $4, -1       -- X"2084FFFF"
        B"000000_00000_00000_00000_00000_000000", -- 6: NOOP                 -- X"00000000"
        B"000000_00000_00001_00111_00000_100000", -- 7: add $7, $0, $1       -- X"00013820"
        B"000100_00001_00100_0000000000011001",  -- 8: beq $1, $4, 25        -- X"10240019"
        B"000000_00000_00000_00000_00000_000000", -- 9: NOOP                 -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 10: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 11: NOOP                -- X"00000000"
        B"001000_00010_00110_0000000000000000",  -- 12: addi $6, $2, 0       -- X"20460000"
        B"000000_00000_00000_00000_00000_000000", -- 13: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 14: NOOP                -- X"00000000"
        B"100011_00110_00011_0000000000000000",  -- 15: lw $3, 0($6)         -- X"8CC30000"
        B"001000_00110_00110_0000000000000100",  -- 16: addi $6, $6, 4       -- X"20C60004"
        B"100011_00110_00101_0000000000000000",  -- 17: lw $5, 0($6)         -- X"8CC50000"
        B"000000_00000_00000_00000_00000_000000", -- 18: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 19: NOOP                -- X"00000000"
        B"000000_00011_00101_01000_00000_101010", -- 20: slt $8, $3, $5      -- X"0065482A"
        B"000000_00000_00000_00000_00000_000000", -- 21: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 22: NOOP                -- X"00000000"
        B"000100_01000_00000_0000000000000111",  -- 23: beq $8, $0, 7        -- X"11000007"
        B"000000_00000_00000_00000_00000_000000", -- 24: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 25: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 26: NOOP                -- X"00000000"
        B"001000_00001_00001_0000000000000001",  -- 27: addi $1, $1, 1       -- X"20210001"
        B"001000_00010_00010_0000000000000100",  -- 28: addi $2, $2, 4       -- X"20420004"
        B"000010_00000000000000000000000101",    -- 29: j 5                  -- X"08000005"
        B"000000_00000_00000_00000_00000_000000", -- 30: NOOP                -- X"00000000"
        B"001000_00000_00111_0000000000000000",  -- 31: addi $7, $0, 0       -- X"20070000"
        B"000000_00000_00000_00000_00000_000000", -- 32: NOOP                -- X"00000000"
        B"000000_00000_00000_00000_00000_000000", -- 33: NOOP                -- X"00000000"
        B"101011_00000_00111_0000000000001000",  -- 34: sw $7, 8($0)         -- X"AC070008"

        -----------------------------------------
        others => X"00000000");                     -- 35: SLL $0, $0, 0, X"00000000" -- NOOP
    -----------------------------------------

    signal PC : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal PCAux, NextAddr, AuxSgn : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- Program Counter
    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= NextAddr;
            end if;
        end if;
    end process;

    -- Instruction OUT
    Instruction <= ROM(conv_integer(PC(6 downto 2)));

    -- PC + 4
    PCAux <= PC + 4;
    PCp4 <= PCAux;

    -- MUX for branch
    AuxSgn <= BranchAddress when PCSrc = '1' else PCAux;

    -- MUX for jump
    NextAddr <= JumpAddress  when Jump = '1' else AuxSgn;

end Behavioral;