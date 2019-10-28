library verilog;
use verilog.vl_types.all;
entity cellram_pathdelay is
    generic(
        tACLK           : real    := 7.000000;
        tAPA            : real    := 20.000000;
        tAW             : real    := 70.000000;
        tBW             : real    := 70.000000;
        tCBPH           : real    := 5.000000;
        tCLK            : real    := 9.620000;
        tCSP            : real    := 3.000000;
        tCW             : real    := 70.000000;
        tHD             : real    := 2.000000;
        tKP             : real    := 3.000000;
        tPC             : real    := 20.000000;
        tRC             : real    := 70.000000;
        tSP             : real    := 3.000000;
        tVP             : real    := 5.000000;
        tVS             : real    := 70.000000;
        tWC             : real    := 70.000000;
        tWP             : real    := 45.000000;
        tAS             : real    := 0.000000;
        tAVH            : real    := 2.000000;
        tAVS            : real    := 5.000000;
        tCPH            : real    := 5.000000;
        tCVS            : real    := 7.000000;
        tDH             : real    := 0.000000;
        tDPDX           : real    := 10000.000000;
        tDW             : real    := 20.000000;
        tOW             : real    := 5.000000;
        tPU             : real    := 150000.000000;
        tVPH            : real    := 0.000000;
        tWPH            : real    := 10.000000;
        tWR             : real    := 0.000000;
        ADQ_BITS        : integer := 23;
        DQ_BITS         : integer := 16;
        BY_BITS         : integer := 2;
        ADDR_BITS       : integer := 23;
        COL_BITS        : integer := 7;
        MEM_BITS        : integer := 10;
        BCR             : integer := 2;
        RCR             : integer := 0;
        DIDR            : integer := 1;
        REG_SEL         : integer := 18;
        CR10            : integer := 1;
        CR15            : integer := 2;
        CR20            : integer := 3;
        GENERATION      : integer := 2;
        CR20WAIT_POLARITY: integer := 1;
        CRE_READ        : integer := 1;
        BCR_MASK        : integer := 261439;
        BCR_DEFAULT     : integer := 40223;
        RCR_MASK        : integer := 196759;
        RCR_DEFAULT     : integer := 16;
        DIDR_MASK       : integer := 262143;
        DIDR_DEFAULT    : integer := 835
    );
    port(
        clk             : in     vl_logic;
        adv_n           : in     vl_logic;
        zz_n            : in     vl_logic;
        ce_n            : in     vl_logic;
        oe_n            : in     vl_logic;
        we_n            : in     vl_logic;
        by_n            : in     vl_logic_vector;
        addr            : in     vl_logic_vector;
        clk2waite       : out    vl_logic;
        adv2dqe         : out    vl_logic;
        adv2dq          : out    vl_logic;
        adv2wi          : out    vl_logic;
        zz2pd           : out    vl_logic;
        ce2dqe          : out    vl_logic;
        ce2dq           : out    vl_logic;
        ce2cem          : out    vl_logic;
        ce2wi           : out    vl_logic;
        ce2waite        : out    vl_logic;
        ce2wait         : out    vl_logic;
        ce2rst          : out    vl_logic;
        oe2dqe          : out    vl_logic;
        oe2dq           : out    vl_logic;
        soe2dq          : out    vl_logic;
        oe2waite        : out    vl_logic;
        oe2wait         : out    vl_logic;
        we2dqe          : out    vl_logic;
        we2dq           : out    vl_logic;
        we2waite        : out    vl_logic;
        by2dqe          : out    vl_logic;
        by2dq           : out    vl_logic;
        addr2dq         : out    vl_logic;
        addr2wi         : out    vl_logic;
        saddr2dq        : out    vl_logic
    );
end cellram_pathdelay;
