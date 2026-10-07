# RTL-Design-LAB
# RTL Design Lab — RGB 轉 YUV 硬體加速器

[English](README.md) | 繁體中文

本專案以 Verilog 實作三個版本的 RGB → YUV 色彩空間轉換電路，分別探討 **面積、延遲（latency）、吞吐量（throughput）** 之間的設計取捨。三個版本使用相同的頂層介面（`RGB2YUV`），驗證方式是將一張 256×256 的 BMP 影像逐像素送入電路，再把 Y、U、V 三個分量各自輸出成影像檔。

本專案為國立中山大學「電子系統層級設計與驗證」（Electronic System-Level Design and Verification）課程的 Lab 1（2026 年 3 月）。

## 轉換公式

```
Y =  0.299·R + 0.587·G + 0.114·B
U = -0.169·R - 0.331·G + 0.500·B + 128
V =  0.500·R - 0.419·G - 0.081·B + 128
```

係數以 **Q8 定點數**（乘以 256）表示，資料路徑為 9-bit 有號數。乘法器先算出完整的 18-bit 乘積，再取 `[16:8]` 位元，等同於除以 256 並無條件捨去。

| 係數 | 數值 | Q8 |
|---|---|---|
| Y：R、G、B | 0.299、0.587、0.114 | 76、150、29 |
| U：R、G、B | −0.169、−0.331、0.500 | −43、−84、128 |
| V：R、G、B | 0.500、−0.419、−0.081 | 128、−107、−20 |

運算拆成以下中間值，三個版本的差別在於如何排程這些運算：

```
t1 = R·0.299   t2 = G·0.587   t3 = B·0.114    t4 = t1 + t2        Y = t4 + t3
t6 = R·-0.169  t7 = G·-0.331  t8 = B·0.5      t9 = t6 + t7   t10 = t8 + 128    U = t9 + t10
t12 = R·0.5    t13 = G·-0.419 t14 = B·-0.081  t15 = t12 + t13 t16 = t14 + 128  V = t15 + t16
```

## 設計版本

| | Version 1 | Version 2 | Version 3 |
|---|---|---|---|
| 運算單元 | 1 個乘法器 + 1 個加法器 | 3 個乘法器 + 3 個加法器 | 3 個乘法器 + 3 個加法器 |
| 架構 | 共用資料路徑，含 MUX、6 個暫存器、係數 ROM、22-bit 控制字 | FSM + Datapath，5 個 state 的排程 | Pipeline，initiation interval（II）= 3 |
| 延遲（運算） | 11 cycles | 5 cycles | 5 cycles |
| 每筆像素間隔 | 12 cycles | 6 cycles | 3 cycles（連續輸入時） |
| 設計目標 | 最小面積 | 降低延遲 | 提高吞吐量 |

### Version 1 — 最小面積（1 MUL + 1 ADD）

`lab1_version1/`

全部 9 次乘法與 8 次加法都分時共用同一個乘法器與加法器。`Controller` 是 12 個 state（`S0`–`S11`）的 FSM，每個 state 輸出一組 22-bit 控制字，用來控制暫存器的 load、MUX 的選擇訊號，以及當下要讀取的 ROM 係數位址。`Datapath` 依照課程講義的 FSM + Datapath 架構設計，包含 6 個 9-bit 暫存器（`r1`–`r6`）、MUX2/MUX3/MUX4 運算元選擇與寫回 MUX，以及存放 Q8 係數的 8 筆 `ROM`。

### Version 2 — 平行運算單元（3 MUL + 3 ADD）

`lab1_version2/`

有了 3 個乘法器與 3 個加法器，資料流圖可以排進 5 個控制步驟：

| State | 乘法器 | 加法器 |
|---|---|---|
| S1 | t1、t2、t3 | — |
| S2 | t6、t7、t8 | t4 |
| S3 | t12、t13、t14 | Y、t9、t10 |
| S4 | — | U、t15、t16 |
| S5 | — | V |

Controller 依序走 `IDLE → S1 → … → S5 → IDLE`，在 S5 之後拉起 `done`。Testbench 採用「送 `start` 脈衝、等待 `done`」的流程，因此不依賴寫死的延遲數。

### Version 3 — Pipeline，II = 3

`lab1_version3/`

維持與 Version 2 相同的 3 MUL + 3 ADD，但讓相鄰的像素重疊執行。以一個 3 相位的計數器驅動排程，每 3 個 cycle 就能送入一筆新像素：

| 相位 | 工作內容 |
|---|---|
| 0 | 送入新像素（計算 Y 的乘積）· 較舊像素的第 4 階段 |
| 1 | 較新像素的第 2 階段 · 較舊像素的第 5 階段（算出 V、拉起 `done`） |
| 2 | 較新像素的第 3 階段 |

由於延遲為 5 cycles、II 為 3，同一時間最多只有兩筆像素在電路中，所以資料路徑保留兩組像素 context（`*0` / `*1` 暫存器），各自用 `valid` 與 `age` 追蹤進度。`start` 只在相位 0 取樣；附帶的 testbench 會把 `start` 拉高 3 個 cycle，確保每筆像素剛好被接收一次。

## 目錄結構

```
RTL-Design-LAB/
├── lab1_version1/          # 1 MUL + 1 ADD
│   ├── RGB2YUV.v           # 頂層模組
│   ├── Controller.v        # 12 個 state 的 FSM，22-bit 控制字
│   ├── Datapath.v
│   ├── Add.v  Mul.v  ROM.v  Register.v
│   ├── MUX2.v  MUX3.v  MUX4.v
│   ├── testbench.v
│   ├── constraints1.xdc    # 100 MHz 時脈約束
│   └── mountain256.bmp     # 測試影像
├── lab1_version2/          # 3 MUL + 3 ADD
│   ├── RGB2YUV.v  Controller.v  Datapath.v  Add.v  Mul.v
│   ├── testbench.v  constraints1.xdc  mountain256.bmp
└── lab1_version3/          # 3 MUL + 3 ADD，II = 3
    ├── RGB2YUV.v  Controller.v  Datapath.v  Add.v  Mul.v
    ├── testbench.v  constraints1.xdc  mountain256.bmp
```

## 介面

```verilog
module RGB2YUV(
    input        start,
    input        clk,
    input        rst_n,      // active-low 非同步 reset
    input  [8:0] inportR,
    input  [8:0] inportG,
    input  [8:0] inportB,
    output       done,
    output [8:0] outportY,
    output [8:0] outportU,
    output [8:0] outportV
);
```

## 模擬方式

Testbench 會從工作目錄讀取 `mountain256.bmp`（256×256、24-bit），逐像素送入 `RGB2YUV`，並輸出三張灰階影像：`mountain256Y.bmp`、`mountain256U.bmp`、`mountain256V.bmp`。

**Icarus Verilog**

```bash
cd lab1_version2
iverilog -o sim *.v
vvp sim
```

**Vivado**

將同一版本的所有 `.v` 檔加入 design sources，把 `testbench.v` 設為 simulation top，並將 `mountain256.bmp` 複製到模擬工作目錄（`<project>.sim/sim_1/behav/xsim/`），再執行 behavioral simulation。

## 驗證

Version 2 與 Version 3 已和 bit-accurate 的 Python 參考模型比對（使用相同的 Q8 定點運算）：65,536 個像素在三個通道上全部完全相符，且兩個版本的輸出完全一致。與浮點數參考值相比，因係數量化與捨去造成的最大誤差為 2 LSB。

## 實作結果

以下為 Vivado post-implementation 結果，時脈約束為 10 ns（100 MHz）。Fmax 由 worst negative slack 估算：1 / (10 ns − WNS)。

| | DSP | LUT | FF | WNS | Fmax | 延遲 | 每筆像素間隔 | 峰值吞吐量 |
|---|---|---|---|---|---|---|---|---|
| Version 1 | 0 | 200 | 94 | 0.556 ns | 105.9 MHz | 11 cycles | 12 | 8.8 Mpixel/s |
| Version 2 | 0 | 303 | 188 | 2.674 ns | 136.5 MHz | 5 cycles | 6 | 22.8 Mpixel/s |
| Version 3 | 0 | 500 | 381 | 0.680 ns | 107.3 MHz | 5 cycles | 3（II = 3） | 35.8 Mpixel/s |

延遲只計算運算用的 state；Version 1 與 Version 2 的「每筆像素間隔」另外包含 idle/load state。峰值吞吐量 = Fmax ÷ 每筆像素間隔。三個版本的總功耗都約為 0.115–0.117 W，主要為靜態功耗。

### 分析

- **沒有使用 DSP。** 9×9-bit 的乘法器規模很小，Vivado 將它們實現在一般 LUT 邏輯中，而不是 DSP48。
- **Version 1 → 2：** 運算單元變為 3 倍，LUT 約增加 1.5 倍、FF 約增加 2 倍，但延遲從 11 cycles 降到 5 cycles。Fmax 也同時提高，推測是因為 Version 1 的關鍵路徑經過共用乘法器與加法器前面的運算元 MUX，而 Version 2 的運算元選擇較簡單（尚未對照 timing report 確認）。
- **Version 2 → 3：** 同時保留兩組像素 context，使 FF 約增加一倍、LUT 約增加 65%，用於額外的暫存器與 context 選擇邏輯。多出來的選擇邏輯讓 Fmax 降到 107.3 MHz，但由於每 3 個 cycle 就能送入一筆新像素，Version 3 的吞吐量仍然最高，約為 Version 2 的 1.6 倍、Version 1 的 4 倍。
- 結論是「最好的設計」取決於評估指標：Version 1 面積最小，Version 2 單筆延遲最短且時脈最高，Version 3 吞吐量最大。

## 已知問題

- **Version 1：** Testbench 以固定 12 cycles 取一次輸出，導致輸出影像整體錯位一個像素（第一個像素為 reset 值）。除此之外 Y、U 通道正確，但 V 通道與參考值有落差（平均誤差約 −15），問題應出在控制字中 V 路徑的排程。

## 使用工具

Verilog HDL · Xilinx Vivado · Icarus Verilog
