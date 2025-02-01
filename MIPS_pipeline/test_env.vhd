library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

    component MPG is
        Port ( enable : out STD_LOGIC;
               btn : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;

    component SSD is
        Port ( clk : in STD_LOGIC;
               digits : in STD_LOGIC_VECTOR(31 downto 0);
               an : out STD_LOGIC_VECTOR(7 downto 0);
               cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;

    component IFetch
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               en : in STD_LOGIC;
               BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
               JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
               Jump : in STD_LOGIC;
               PCSrc : in STD_LOGIC;
               Instruction : out STD_LOGIC_VECTOR(31 downto 0);
               PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component ID
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               Instr : in STD_LOGIC_VECTOR(25 downto 0);
               WD : in STD_LOGIC_VECTOR(31 downto 0);
               WriteAddress : in STD_LOGIC_VECTOR(4 downto 0);
               RegWrite : in STD_LOGIC;
               rd, rt : out STD_LOGIC_VECTOR(4 downto 0); -- new
               --RegDst : in STD_LOGIC;
               ExtOp : in STD_LOGIC;
               RD1 : out STD_LOGIC_VECTOR(31 downto 0);
               RD2 : out STD_LOGIC_VECTOR(31 downto 0);
               Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
               func : out STD_LOGIC_VECTOR(5 downto 0);
               sa : out STD_LOGIC_VECTOR(4 downto 0));
    end component;

    component UC
        Port ( Instr : in STD_LOGIC_VECTOR(5 downto 0);
               RegDst : out STD_LOGIC;
               ExtOp : out STD_LOGIC;
               ALUSrc : out STD_LOGIC;
               Branch : out STD_LOGIC;
               Jump : out STD_LOGIC;
               ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
               MemWrite : out STD_LOGIC;
               MemtoReg : out STD_LOGIC;
               RegWrite : out STD_LOGIC);
    end component;

    component EX is
        Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
               RD1 : in STD_LOGIC_VECTOR(31 downto 0);
               RD2 : in STD_LOGIC_VECTOR(31 downto 0);
               Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
               RegDst : in STD_LOGIC; -- new
               rt,rd: in STD_LOGIC_VECTOR(4 downto 0); -- new
               rWA : out STD_LOGIC_VECTOR(4 downto 0);  -- new
               func : in STD_LOGIC_VECTOR(5 downto 0);
               sa : in STD_LOGIC_VECTOR(4 downto 0);
               ALUSrc : in STD_LOGIC;
               ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
               BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
               ALURes : out STD_LOGIC_VECTOR(31 downto 0);
               Zero : out STD_LOGIC);
    end component;

    component MEM
        port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
               RD2 : in STD_LOGIC_VECTOR(31 downto 0);
               MemWrite : in STD_LOGIC;
               MemData : out STD_LOGIC_VECTOR(31 downto 0);
               ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal enable, zero,MemWrite, MemtoReg, RegWrite, Branch, ALUSrc, RegDst, ExtOp,Jump, PCSrc,en, rst : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
    signal rWA,rt, rd, sa : STD_LOGIC_VECTOR(4 downto 0);
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    signal ALUResOut, MemData, ALURes, BranchAddress, Ext_imm, RD2, RD1, PCp4, Instruction, WD, JumpAddress, digits : STD_LOGIC_VECTOR(31 downto 0);

    -- signal for register file
    signal IF_ID : std_logic_vector(63 downto 0);
    signal ID_EX : std_logic_vector(157 downto 0);
    signal EX_MEM : std_logic_vector(105 downto 0);
    signal MEM_WB : std_logic_vector(70 downto 0);


begin

    monopulse : MPG port map(
        enable => en,
        btn => btn(0),
        clk => clk
    );
    monopulse2 : MPG port map(
        enable => rst,
        btn => btn(1),
        clk => clk
    );

    -- main units
    inst_IFetch : IFetch port map(
        clk => clk,
        rst => rst,
        en => en,
        BranchAddress => EX_MEM(36 downto 5),
        JumpAddress => JumpAddress,
        Jump => Jump,
        PCSrc => PCSrc,
        Instruction => Instruction,
        PCp4 => PCp4
    );
    inst_ID : ID port map(
        en => en,
        Instr => IF_ID(25 downto 0),
        ExtOp => ExtOp,
        WriteAddress => MEM_WB(70 downto 66),
        WD => WD,
        clk => clk,
        rd => rd,
        rt => rt,
        RegWrite => MEM_WB(1),
        --RegDst : in STD_LOGIC;
        RD1 => RD1,
        RD2 => RD2,
        Ext_Imm => Ext_Imm,
        func => func,
        sa => sa
    );
    inst_UC : UC port map(
        Instr => IF_ID(31 downto 26),
        RegDst => RegDst,
        ExtOp => ExtOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        Jump => Jump,
        ALUOp => ALUOp,
        MemWrite => MemWrite,
        MemtoReg => MemtoReg,
        RegWrite => RegWrite
    );
    inst_EX : EX port map(
        RD1 => ID_EX(40 downto 9),
        RD2 => ID_EX(72 downto 41),
        Ext_Imm => ID_EX(104 downto 73),
        func => ID_EX(110 downto 105),
        sa => ID_EX(115 downto 111),
        RegDst => ID_EX(0),
        rd => ID_EX(120 downto 116),
        rt => ID_EX(125 downto 121),
        PCp4 => ID_EX(157 downto 126),
        ALUSrc => ID_EX(1),
        ALUOp => ID_EX(5 downto 3),
        Zero => zero,
        BranchAddress => BranchAddress,
        ALURes => ALURes,
        rWA => rWA
    );
    inst_MEM : MEM port map(
        clk => clk,
        en => en,
        ALUResIn => EX_MEM(68 downto 37),
        RD2 => EX_MEM(105 downto 74),
        MemWrite => EX_MEM(1),
        MemData => MemData,
        ALUResOut => ALUResOut
    );

    -- Write-Back unit
    -- WD <= MemData when MemtoReg = '1' else ALUResOut;
    WD <= MEM_WB(33 downto 2) when MEM_WB(0) = '0' else MEM_WB(65 downto 34);

    -- branch control
    -- PCSrc <= branch and zero;
    PCSrc <= EX_MEM(0) and EX_MEM(4);

    -- jump address
    --JumpAddress <= PCp4(31 downto 28) & Instruction(25 downto 0) & "00";
    JumpAddress <= IF_ID(63 downto 60) & IF_ID(25 downto 0) & "00";

    -- SSD display MUX
    with sw(7 downto 5) select
        digits <=
        IF_ID(31 downto 0) when "000",
            IF_ID(63 downto 32) when "001",
            ID_EX(40 downto 9) when "010",
            ID_EX(72 downto 41) when "011",
            ID_EX(104 downto 73) when "100",
            EX_MEM(68 downto 37) when "101",
            MEM_WB(65 downto 34) when "110",
            WD when "111",
            (others => 'X') when others;

    display : SSD port map(clk, digits, an, cat);

    -- main controls on the leds
    led(10 downto 0) <= RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite & ALUOp;

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                IF_ID(31 downto 0) <= Instruction;
                IF_ID(63 downto 32) <= PCp4;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                ID_EX(0) <= RegDst;
                ID_EX(1) <= ALUSrc;
                ID_EX(2) <= Branch;
                ID_EX(5 downto 3) <= ALUOp;
                ID_EX(8) <= MemWrite;
                ID_EX(7) <= MemtoReg;
                ID_EX(6) <= RegWrite;
                ID_EX(40 downto 9) <= RD1;
                ID_EX(72 downto 41) <= RD2;
                ID_EX(104 downto 73) <= Ext_Imm;
                ID_EX(110 downto 105) <= func;
                ID_EX(115 downto 111) <= sa;
                ID_EX(120 downto 116) <= rd;
                ID_EX(125 downto 121) <= rt;
                ID_EX(157 downto 126) <= IF_ID(63 downto 32);
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                EX_MEM(0) <= ID_EX(2); -- Branch
                EX_MEM(1) <= ID_EX(8); -- MemWrite
                EX_MEM(2) <= ID_EX(7); -- MemtoReg
                EX_MEM(3) <= ID_EX(6); -- RegWrite
                EX_MEM(4) <= zero;
                EX_MEM(36 downto 5) <= BranchAddress;
                EX_MEM(68 downto 37) <= ALURes;
                EX_MEM(73 downto 69) <= rWA;
                EX_MEM(105 downto 74) <= ID_EX(72 downto 41);
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                MEM_WB(0) <= EX_MEM(2); -- MemtoReg
                MEM_WB(1) <= EX_MEM(3); -- RegWrite
                MEM_WB(33 downto 2) <= ALUResOut;
                MEM_WB(65 downto 34) <= MemData;
                MEM_WB(70 downto 66) <= EX_MEM(73 downto 69);
            end if;
        end if;
    end process;
end Behavioral;