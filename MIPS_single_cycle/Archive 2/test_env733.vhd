library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_env633 is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env633;

architecture Behavioral of test_env633 is
    -- Instantiate MPG component
    component MPG is
        Port ( enable : out STD_LOGIC;
               btn : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;

    component IFetch is
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
    end component;

    component ID is
        Port (
            clk : in STD_LOGIC;
            en : in STD_LOGIC;
            RegWrite : in STD_LOGIC;
            RegDst : in STD_LOGIC;
            ExtOp : in STD_LOGIC;
            Instr : in STD_LOGIC_VECTOR(31 downto 0);
            WriteData : in STD_LOGIC_VECTOR(31 downto 0);
            RD1 : out STD_LOGIC_VECTOR(31 downto 0);
            RD2 : out STD_LOGIC_VECTOR(31 downto 0);
            Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
            func : out STD_LOGIC_VECTOR(5 downto 0);
            sa : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

    component UC is
        Port (
            Instr : in STD_LOGIC_VECTOR(31 downto 0);
            RegDst : out STD_LOGIC;
            ExtOp : out STD_LOGIC;
            ALUSrc : out STD_LOGIC;
            Branch : out STD_LOGIC;
            Jump : out STD_LOGIC;
            MemWrite : out STD_LOGIC;
            MemtoReg : out STD_LOGIC;
            RegWrite : out STD_LOGIC;
            ALUOp : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component EX is
        Port (
            clk : in STD_LOGIC;
            ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
            func : in STD_LOGIC_VECTOR(5 downto 0);
            sa : in STD_LOGIC_VECTOR(4 downto 0);
            RD1 : in STD_LOGIC_VECTOR(31 downto 0);
            RD2 : in STD_LOGIC_VECTOR(31 downto 0);
            Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
            ALUSrc : in STD_LOGIC;
            ALURes : inout STD_LOGIC_VECTOR(31 downto 0);
            Zero : inout STD_LOGIC;
            BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
            pc : in STD_LOGIC_VECTOR(31 downto 0);
            GTZ : out STD_LOGIC;
            GEZ : out STD_LOGIC
        );
    end component;

    component MEM is
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
            RD2 : in STD_LOGIC_VECTOR(31 downto 0);
            MemWrite : in STD_LOGIC;
            MemData : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component SSD is
        Port ( clk : in STD_LOGIC;
               digits : in STD_LOGIC_VECTOR(31 downto 0);
               an : out STD_LOGIC_VECTOR(7 downto 0);
               cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;


    signal MPG_enable : std_logic;

    signal reset, enable, jump, pcsrc : STD_LOGIC;
    signal jump_addr, branch_addr, instr_out, pc_next : STD_LOGIC_VECTOR(31 downto 0);

    signal Instr,digits,sum : STD_LOGIC_VECTOR(31 downto 0);

    signal WD, RD1, RD2, Ext_Imm : STD_LOGIC_VECTOR(31 downto 0);
    signal sa : STD_LOGIC_VECTOR(4 downto 0);
    signal RegDst, ExtOp, ALUSrc, Branch, MemWrite, MemtoReg ,RegWrite_signal : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
    signal JumpR : STD_LOGIC;
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    signal extended_func, extended_sa : STD_LOGIC_VECTOR(31 downto 0);
    signal ALURes : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero : STD_LOGIC;
    signal BranchAddress : STD_LOGIC_VECTOR(31 downto 0);
    signal pc : STD_LOGIC_VECTOR(31 downto 0);
    signal GTZ, GEZ : STD_LOGIC;
    signal MemData : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResOut : STD_LOGIC_VECTOR(31 downto 0);
    signal JumpAddress : STD_LOGIC_VECTOR(31 downto 0);


begin
    -- Instantiate MPG for address counter enable
    MPG_inst : MPG
        port map (
            enable => MPG_enable,
            btn => btn(0),  -- Assuming btn(0) is used for enable
            clk => clk
        );

    IFetch_inst : IFetch
        port map (
            clk => clk,
            reset => btn(1),  -- Assuming btn(1) is used for reset
            enable => MPG_enable,
            jump => sw(0),  -- Assuming sw(0) is used for jump
            pcsrc => sw(1),  -- Assuming sw(1) is used for pcsrc
            jump_addr => X"00000000",
            branch_addr => X"00000010",
            instr_out => instr_out,
            pc_next => pc_next
        );

    ID_inst : ID
        port map (
            clk => clk,
            en => MPG_enable,
            RegWrite => RegWrite_signal,
            RegDst => RegDst,
            ExtOp => ExtOp,
            Instr => instr_out,
            WriteData => WD,
            RD1 => RD1,
            RD2 => RD2,
            Ext_Imm => Ext_Imm,
            func => func,
            sa => sa
        );

    UC_inst : UC
        port map (
            Instr => instr_out,
            RegDst => RegDst,
            ExtOp => ExtOp,
            ALUSrc => ALUSrc,
            Branch => Branch,
            Jump => jump,
            MemWrite => MemWrite,
            MemtoReg => MemtoReg,
            RegWrite => RegWrite_signal,
            ALUOp => ALUOp
        );

    EX_inst : EX
        port map (
            clk => clk,
            ALUOp => ALUOp,
            func => func,
            sa => sa,
            RD1 => RD1,
            RD2 => RD2,
            Ext_Imm => Ext_Imm,
            ALUSrc => ALUSrc,
            ALURes => ALURes,
            Zero => Zero,
            BranchAddress => BranchAddress,
            pc => pc_next,
            GTZ => open,
            GEZ => open
        );
    MEM_inst : MEM
        port map (
            clk => clk,
            reset => btn(1),  -- Assuming btn(1) is used for reset
            enable => MPG_enable,
            ALUResIn => ALURes,
            RD2 => RD2,
            MemWrite => MemWrite,
            MemData => open
        );


    SSD_inst : SSD
        port map (
            clk => clk,
            digits => digits,
            an => an,
            cat => cat
        );

    sum <= RD1+RD2;

    extended_func <= "00000000000000000000000000" & func; -- 26 '0's + 6 bits = 32 bits
    extended_sa <= "000000000000000000000000000" & sa; -- 27 '0's + 5 bits = 32 bits

    with sw(7 downto 5) select
        digits <= Instr when "000", -- Display Instruction from IFetch
        pc_next when "001", -- Display PC+4 from IFetch
        RD1 when "010", -- Display RD1 from ID
        RD2 when "011", -- Display RD2 from ID
        Ext_Imm when "100", -- Display Ext_Imm from ID
        ALURes when "101", -- Display ALURes from EX
        MemData when "110", -- Display MemData from MEM
        WD when "111", -- Display WD from ID
        (others => '0') when others;

    led (9 downto 0) <= ALUop & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite_signal;

    -- Implement the multiplexer for the WB unit
    ALUResOut <= ALURes when MemtoReg = '0' else MemData;

    -- Implement the control logic PCSrc for the conditional jump
    PCSrc <= Branch and Zero;

    -- Implement the calculation of the unconditional jump address Jump Address
    JumpAddress <= pc_next(31 downto 28) & instr_out(25 downto 0) & "00";

end Behavioral;