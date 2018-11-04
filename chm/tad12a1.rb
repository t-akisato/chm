# -*- coding: utf-8 -*-

# 壁に当たるとorランダムで空いてる方に曲がる
# 敵が周りにいたらput

require_relative 'CHaserConnect.rb' # CHaserConnect.rbを読み込む Windows
#require_relative 'CHaserConnect2009.rb' # CHaserConnect.rbを読み込む Windows

# 定数 -------------------------------------------------------
# 方向
D_UP = 2
D_LEFT = 4
D_RIGHT = 6
D_DOWN = 8

D_C = [["U",D_UP],["L",D_LEFT],["R",D_RIGHT],["D",D_DOWN]]
Directions=[D_UP, D_LEFT, D_RIGHT, D_DOWN]

# マップ
M_FLOOR = 0
M_CHARA = 1
M_BLOCK = 2
M_ITEM = 3
M_UNKNOWN = 6
M_OUTSIDE = 7

M_C = [["F",M_FLOOR],["C",M_CHARA],["B",M_BLOCK],["I",M_ITEM]]

# アクション
A_NULL = 0
A_PUT = 1
A_WALK= 2
A_LOOK = 3
A_SEARCH = 4
A_SLIDE = 5
A_GLANCE = 6
A_SAVE = 7
A_GETREADY = 9

A_C = [["N",A_NULL],["P",A_PUT],["W",A_WALK],["L",A_LOOK],["S",A_SEARCH],["D",A_SLIDE],["G",A_GLANCE],["V",A_SAVE]]

# 変数宣言とか
values = Array.new(10) # 書き換えない
last_values = Array.new(10)
r_mode = mode = Directions.sample #D_RIGHT # 現在の向き
pre_mode = mode
step = 0
queue = []
last_act = A_NULL
act_mode = 0
ActCycle = 10 # パターン切り替えターン数
action = A_NULL

@chara=[". ","X ","# ","$ ", "C ", "H ", "? ", "O ", "8 "] # 表示用キャラセット
@ch_color=[7,7,7,3,6,5,4,0] # 表示色コード

# マップの大きさ
@map_x = 15
@map_y = 17

@mapsize_x = @map_x * 2 + 1
@mapsize_y = @map_y * 2 + 1

# マップでの初期位置
x = @map_x
y = @map_y

#マップを0で初期化
chmap = Array.new( @mapsize_y).map{Array.new(( @mapsize_x),0)}

#記憶用マップ
@mymap = Array.new( @mapsize_y).map{Array.new((@mapsize_x),M_UNKNOWN)}

# 正規表現とアクションシーケンス

# 敵がいた時の対処
ActSeq4E= [
    ["..@...#...#...#.C.#...",[[D_UP,A_SEARCH]]],
    ["..@...#...#.C.#...#...",[[D_UP,A_WALK]]],   # 敵が前後左右にいたらPUT
    ["..@...#...#...#C..#...",[[D_LEFT,A_WALK]]],
    ["..@...#...#...#..C#...",[[D_RIGHT,A_WALK]]],
    ["..@...#...#...#...#.C.",[[D_DOWN,A_WALK]]],

    ["..@...#...#CB.#B..#.[^B].",[[D_DOWN,A_LOOK]]],
    ["..@...#...#.BC#..B#.[^B].",[[D_DOWN,A_LOOK]]],
    ["..@...#...#CB.#B.[^B]#...",[[D_RIGHT,A_LOOK]]],
    ["..@...#...#.BC#[^B].B#...",[[D_LEFT,A_LOOK]]],

    [".L@...#...#.[^BI].#..B#.BC",[[D_UP,A_WALK]]],
    [".L@...#...#.[^BI].#B..#CB.",[[D_UP,A_WALK]]],
    [".L@...#.[^B].#.I.#..B#.BC",[[D_UP,A_WALK]]],
    [".L@...#.[^B].#.I.#B..#CB.",[[D_UP,A_WALK]]],
    [".L@...#...#.I[^B]#..B#.BC",[[D_UP,A_WALK]]],
    [".L@...#...#.I[^B]#B..#CB.",[[D_UP,A_WALK]]],
    [".L@...#...#[^B]I.#..B#.BC",[[D_UP,A_WALK]]],
    [".L@...#...#[^B]I.#B..#CB.",[[D_UP,A_WALK]]],

    ["..@...#B..#C..#B.[^B]#...",[[D_UP,A_PUT]]], # 敵をブロックで囲めるかも？
    ["..@...#B..#C..#B..#.[^B].",[[D_UP,A_PUT]]],
    ["..@...#B..#CB.#..[^B]#...",[[D_UP,A_PUT]]],
    ["..@...#B..#CB.#...#.[^B].",[[D_LEFT,A_PUT]]],
    ["..@...#..B#..C#[^B].B#...",[[D_LEFT,A_PUT]]],
    ["..@...#..B#..C#..B#.[^B].",[[D_UP,A_PUT]]],
    ["..@...#..B#.BC#[^B]..#...",[[D_RIGHT,A_PUT]]],
    ["..@...#..B#.BC#...#.[^B].",[[D_RIGHT,A_PUT]]],

    ["..@...#...#C..#...#BIB",[[D_DOWN,A_LOOK]]], # 敵がななめにいて反対にアイテムなら、LOOK
    ["..@...#...#..C#...#BIB",[[D_DOWN,A_LOOK]]],
    ["..@...#...#BIB#...#C..",[[D_UP,A_LOOK]]],
    ["..@...#...#BIB#...#..C",[[D_UP,A_LOOK]]],
    ["..@...#...#C.B#..I#..B",[[D_RIGHT,A_LOOK]]],
    ["..@...#...#B.C#I..#B..",[[D_LEFT,A_LOOK]]],
    ["..@...#...#..B#..I#C.B",[[D_RIGHT,A_LOOK]]],
    ["..@...#...#B..#I..#B.C",[[D_LEFT,A_LOOK]]],

    ["..@...#...#C..#[^B]..#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]],[[D_LEFT,A_PUT]]], # 敵がななめにいたら、LOOK か逃げるかPUT
    ["..@...#...#..C#..[^B]#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]],[[D_RIGHT,A_PUT]]],
    ["..@...#...#.[^B].#[^B]..#C..",[[D_DOWN,A_LOOK]],[[D_UP,A_WALK]],[[D_LEFT,A_PUT]]],
    ["..@...#...#.[^B].#..[^B]#..C",[[D_DOWN,A_LOOK]],[[D_UP,A_WALK]],[[D_RIGHT,A_PUT]]],
    ["..@...#...#C[^B].#..[^B]#...",[[D_UP,A_LOOK]],[[D_RIGHT,A_WALK]],[[D_UP,A_PUT]]],
    ["..@...#...#.[^B]C#[^B]..#...",[[D_UP,A_LOOK]],[[D_LEFT,A_WALK]],[[D_UP,A_PUT]]],
    ["..@...#...#...#..[^B]#C[^B].",[[D_DOWN,A_LOOK]],[[D_RIGHT,A_WALK]],[[D_DOWN,A_PUT]]],
    ["..@...#...#...#[^B]..#.[^B]C",[[D_DOWN,A_LOOK]],[[D_LEFT,A_WALK]],[[D_DOWN,A_PUT]]],

    ["..@...#...#C..#...#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]]], # 敵がななめにいたら、LOOK か逃げる
    ["..@...#...#..C#...#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]]],
    ["..@...#...#.[^B].#...#C..",[[D_DOWN,A_LOOK]],[[D_UP,A_WALK]]],
    ["..@...#...#.[^B].#...#..C",[[D_DOWN,A_LOOK]],[[D_UP,A_WALK]]],
    ["..@...#...#C..#..[^B]#...",[[D_UP,A_LOOK]],[[D_RIGHT,A_WALK]]],
    ["..@...#...#..C#[^B]..#...",[[D_UP,A_LOOK]],[[D_LEFT,A_WALK]]],   #10
    ["..@...#...#...#..[^B]#C..",[[D_DOWN,A_LOOK]],[[D_RIGHT,A_WALK]]],
    ["..@...#...#...#[^B]..#..C",[[D_DOWN,A_LOOK]],[[D_LEFT,A_WALK]]],
    ["..@...#...#C..#..B#.B.",[[D_UP,A_LOOK]]],
    ["..@...#...#..C#B..#.B.",[[D_UP,A_LOOK]]],
    ["..@...#...#.B.#..B#C..",[[D_DOWN,A_LOOK]]],
    ["..@...#...#.B.#B..#..C",[[D_DOWN,A_LOOK]]],

    ["RG@C..#...",[[D_RIGHT,A_LOOK]]], # 敵が右にいたら
    ["RG@.C.#...",[[D_RIGHT,A_LOOK]]],
    ["RG@..C#...",[[D_RIGHT,A_LOOK]]],
    ["RG@...#C..",[[D_RIGHT,A_LOOK]]],
    ["RG@...#.C.",[[D_RIGHT,A_LOOK]]],
    ["RG@...#..C",[[D_RIGHT,A_LOOK]]],

    ["..@C..#...#.F.#...#.[^B].",[[D_UP,A_WALK]]],
    ["..@.C.#...#.F.#...#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]]],
    ["..@..C#...#.F.#...#.[^B].",[[D_UP,A_WALK]]],
    ["..@...#C..#.F.#...#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]]],
    ["..@...#.C.#...#...#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]]],
    ["..@...#..C#.F.#...#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]]],
    ["..@C",[[D_UP,A_LOOK]]],
    ["..@.C",[[D_UP,A_LOOK]]],
    ["..@..C",[[D_UP,A_LOOK]]],
    ["..@...#C",[[D_UP,A_LOOK]]],
    ["..@...#.C",[[D_UP,A_LOOK]]],
    ["..@...#..C",[[D_UP,A_LOOK]]]
]

# アイテムあったら
ActSeq4I = [
    [".L@...#.B.#BIB#B.B#.B.",[[D_UP,A_SEARCH]]], #はまった
    [".L@...#.B.#BIB#...#.B.",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]], #はまるパターンなのでSAVE
    [".L@...#.B.#BIB#...#.[^B].",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]],#取ったらアウト
    #  ["DL@...#...#.[^B].#...#.I.",[[D_UP,A_WALK]]],

    # トラップ仕掛ける
    [".L@.FF#.FF#BIF#..F#...",[[D_UP,A_SAVE],[D_RIGHT,A_WALK],[D_LEFT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_RIGHT,A_PUT],[D_RIGHT,A_LOOK]],#[[D_UP,A_WALK]],
    [[D_UP,A_SAVE],[D_RIGHT,A_SLIDE],[D_LEFT,A_PUT],[D_RIGHT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@FF.#FF.#FIB#F..#...",[[D_UP,A_SAVE],[D_LEFT,A_WALK],[D_RIGHT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_LEFT,A_PUT],[D_LEFT,A_LOOK]],#[[D_UP,A_WALK]],
    [[D_UP,A_SAVE],[D_LEFT,A_SLIDE],[D_RIGHT,A_PUT],[D_LEFT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@...#.B.#[^BI]I[^B]#[^B]..#[^B][^B].",[[D_UP,A_SAVE],[D_LEFT,A_SLIDE],[D_UP,A_PUT],[D_RIGHT,A_PUT],[D_RIGHT,A_LOOK]] ],
    [".L@...#.B.#[^B]I[^BI]#..[^B]#.[^B][^B]",[[D_UP,A_SAVE],[D_RIGHT,A_SLIDE],[D_UP,A_PUT],[D_LEFT,A_PUT],[D_LEFT,A_LOOK]] ],
    [".L@...#.B.#BIF#..F#...",[[D_UP,A_SAVE],[D_RIGHT,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@...#.B.#FIB#F..#...",[[D_UP,A_SAVE],[D_LEFT,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@...#.F.#BIB#...#FFF",[[D_UP,A_SAVE],[D_DOWN,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],

    ## アイテムをLOOKしてから取る
    #まとめてとれる？
    ["..@...#...#[^B]I[^B]#I..#...",[[D_LEFT,A_LOOK],[D_UP,A_WALK],[D_RIGHT,A_WALK],[D_RIGHT,A_LOOK]]],
    ["..@...#...#[^B]I[^B]#..I#...",[[D_RIGHT,A_LOOK],[D_UP,A_WALK],[D_LEFT,A_WALK],[D_LEFT,A_LOOK]]],
    ["..@...#I[^B][^B]#[^B]II#..[^B]#...",[[D_RIGHT,A_WALK],[D_LEFT,A_WALK],[D_LEFT,A_WALK],[D_UP,A_WALK],[D_RIGHT,A_WALK]]],
    ["..@...#[^B][^B]I#II[B]#[^B]..#...",[[D_LEFT,A_WALK],[D_RIGHT,A_WALK],[D_RIGHT,A_WALK],[D_UP,A_WALK],[D_LEFT,A_WALK]]],  #40
    [".L@...#..[^B]#III#[^B]..#...",[[D_LEFT,A_WALK],[D_RIGHT,A_WALK],[D_RIGHT,A_WALK],[D_UP,A_WALK],[D_LEFT,A_LOOK]]],
    [".L@...#[^B]..#III#..[^B]#...",[[D_RIGHT,A_WALK],[D_LEFT,A_WALK],[D_LEFT,A_WALK],[D_UP,A_WALK],[D_RIGHT,A_LOOK]]],
    [".L@...#I[^B][^BI]#.I[^B]#...#...",[[D_UP,A_WALK],[D_LEFT,A_LOOK],[D_UP,A_WALK],[D_RIGHT,A_WALK]]],
    [".L@...#[^BI][^B]I#[^B]I.#...#...",[[D_UP,A_WALK],[D_RIGHT,A_LOOK],[D_UP,A_WALK],[D_LEFT,A_WALK]]],
    [".L@...#I[^B][^B]#[^B][^B]I#..[^B]#...",[[D_RIGHT,A_WALK],[D_LEFT,A_WALK],[D_LEFT,A_WALK]]],
    [".L@...#[^B][^B]I#I[^B][^B]#[^B]..#...",[[D_LEFT,A_WALK],[D_RIGHT,A_WALK],[D_RIGHT,A_WALK]]],
    [".L@...#I..#II.#...#...",[[D_UP,A_WALK],[D_LEFT,A_LOOK],[D_UP,A_WALK],[D_RIGHT,A_LOOK],[D_UP,A_WALK]]],
    [".L@...#..I#.II#...#...",[[D_UP,A_WALK],[D_RIGHT,A_LOOK],[D_UP,A_WALK],[D_LEFT,A_LOOK],[D_UP,A_WALK]]],
    [".L@...#.II#.I.#...#...",[[D_UP,A_WALK],[D_UP,A_WALK],[D_RIGHT,A_LOOK],[D_UP,A_WALK]]],
    [".L@...#II.#.I.#...#...",[[D_UP,A_WALK],[D_UP,A_WALK],[D_LEFT,A_LOOK],[D_UP,A_WALK]]],
    [".L@I..#F..#FI.#...#...",[[D_UP,A_WALK],[D_LEFT,A_SLIDE],[D_UP,A_LOOK],[D_UP,A_WALK],[D_UP,A_LOOK]]],
    [".L@..I#..F#.IF#...#...",[[D_UP,A_WALK],[D_RIGHT,A_SLIDE],[D_UP,A_LOOK],[D_UP,A_WALK],[D_UP,A_LOOK]]],

    [".L@...#...#.I.#...#...",[[D_UP,A_WALK]]],
    ["..@...#...#.I.#...#...",[[D_UP,A_LOOK]]],
    ["..@...#...#...#I..#...",[[D_LEFT,A_LOOK]]],
    ["..@...#...#...#..I#...",[[D_RIGHT,A_LOOK]]],#50

    ["..@...#...#I..#[^B]..#...",[[D_LEFT,A_SLIDE]]],
    ["..@...#...#..I#..[^B]#...",[[D_RIGHT,A_SLIDE]]],

    ["..@...#...#I[^B].#...#...",[[D_UP,A_WALK]]],
    ["..@...#...#.[^B]I#...#...",[[D_UP,A_WALK]]],
    ["..@...#...#...#[^B]..#I[^B].",[[D_DOWN,A_WALK]]],
    ["..@...#...#...#..[^B]#.[^B]I",[[D_DOWN,A_WALK]]],
    ["..@...#...#I..#[^B]..#...",[[D_LEFT,A_SLIDE]]],
    ["..@...#...#..I#..[^B]#...",[[D_RIGHT,A_SLIDE]]],
    ["..@...#...#...#[^B]..#I..",[[D_LEFT,A_LOOK]]],
    ["..@...#...#...#..[^B]#..I",[[D_RIGHT,A_LOOK]]],

]

ActSeq4I2 = [
    [".L@...#.B.#BIB#B.B#.B.",[[D_UP,A_SEARCH]]], #はまった
    [".L@...#.B.#BIB#...#.B.",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]], #はまるパターンなのでSAVE
    [".L@...#.B.#BIB#...#.[^B].",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]],#取ったらアウト

    ## アイテムをLOOKしてから取る
    [".L@...#...#.I.#...#...",[[D_UP,A_WALK]]],
    ["..@...#...#.I.#...#...",[[D_UP,A_LOOK]]],
]

# くねくね
ActSeq0 = ActSeq4E + ActSeq4I + [
    ["[014589]UW@...#...#...#..[^B]#...",[[D_RIGHT,A_GLANCE],[D_RIGHT,A_SLIDE]]],
    ["[014589]RS@...#...#.[^B].#...#...",[[D_UP,A_LOOK],[D_UP,A_WALK]]],#60
    ["UW@...#...#...#..[^B]#...",[[D_RIGHT,A_SLIDE]]],
    ["RS@...#...#.[^B].#...#...",[[D_UP,A_WALK]]],
    ["UW@...#...#..B#[^B].B#..B",[[D_LEFT,A_WALK]]],

    [".L@...#.B.#BFB#...#...",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]],
    [".L@.B.#BFB#BFB#...#...",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]],

    ["..@...#...#.[^B][^B]#..[^B]#...",[[D_UP,A_WALK]],[[D_UP,A_WALK]],[[D_RIGHT,A_SLIDE]]],
    ["..@...#...#.B[^B]#B.[^B]#...",[[D_RIGHT,A_SLIDE]]],
    ["..@...#...#[^B]B.#[^B].B#...",[[D_LEFT,A_SLIDE]]],
    ["..@...#...#.B.#B.[^B]#...",[[D_RIGHT,A_WALK]]],
    ["..@...#...#.B.#[^B].B#...",[[D_LEFT,A_WALK]]],
    ["..@...#...#.B.#B.B#.[^B].",[[D_DOWN,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_SAVE],[D_DOWN,A_LOOK]]],
    ["..@...#...#.B[^B]#..[^B]#...",[[D_RIGHT,A_SLIDE]]],
    ["..@...#...#[^B]B.#[^B]..#...",[[D_LEFT,A_SLIDE]]],
    ["..@...#...#.B.#[^B].[^B]#...",[[D_RIGHT,A_WALK]],[[D_LEFT,A_WALK]]],

    ["..@...#...#.[^B].#...#...",[[D_UP,A_WALK]]],

    ["..@...#...#...#...#...",[[D_UP,A_SEARCH]]]
]

# わりと直進
ActSeq1 = ActSeq4E + ActSeq4I + [

    #  ["..@...#...#.[^B].#..[^B]#..B",[[D_RIGHT,A_WALK]],[[D_RIGHT,A_WALK]],[[D_RIGHT,A_WALK]],[[D_UP,A_WALK]]],
    #  ["..@...#...#...#..[^B]#..B",[[D_RIGHT,A_WALK]]],
    ["[036].[^L]@", [[D_UP,A_LOOK]]],
    ["..@...#...#.B.#[^B].B#...",[[D_LEFT,A_LOOK]]],
    ["..@...#...#.B.#B.[^B]#...",[[D_RIGHT,A_LOOK]]],
    ["..@...#...#[^B]B.#[^B].B#...",[[D_LEFT,A_SLIDE]]],
    ["..@...#...#.B[^B]#B.[^B]#...",[[D_RIGHT,A_SLIDE]]],
    ["..@...#...#[^B]B[^B]#[^B].[^B]#...",[[D_RIGHT,A_SLIDE]],[[D_LEFT,A_SLIDE]]],
    ["..@...#...#.B.#[^B].[^B]#...",[[D_RIGHT,A_LOOK]],[[D_LEFT,A_LOOK]]],

    ["..@...#...#.B.#B.B#.[^B].",[[D_DOWN,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_SAVE],[D_DOWN,A_LOOK]]],
    [".L@...#...#.[^B].#...#...",[[D_UP,A_WALK]]],

    ["..@...#...#.[^B].#...#...",[[D_UP,A_WALK]],[[D_UP,A_WALK]],[[D_UP,A_LOOK]]],

    ["..@...#...#...#...#...",[[D_UP,A_SEARCH]]]
]

# まっすぐ
ActSeq2 = ActSeq4E + ActSeq4I2 + [

    #  ["..@...#...#.[^B].#..[^B]#..B",[[D_RIGHT,A_WALK]],[[D_RIGHT,A_WALK]],[[D_RIGHT,A_WALK]],[[D_UP,A_WALK]]],
    #  ["..@...#...#...#..[^B]#..B",[[D_RIGHT,A_WALK]]],
    ["[036].[^L]@", [[D_UP,A_LOOK]]],
    ["..@...#...#.B.#[^B].B#...",[[D_LEFT,A_LOOK]]],
    ["..@...#...#.B.#B.[^B]#...",[[D_RIGHT,A_LOOK]]],
    ["..@...#...#[^B]B.#[^B].B#...",[[D_LEFT,A_SLIDE]]],
    ["..@...#...#.B[^B]#B.[^B]#...",[[D_RIGHT,A_SLIDE]]],
    ["..@...#...#[^B]B[^B]#[^B].[^B]#...",[[D_RIGHT,A_SLIDE]],[[D_LEFT,A_SLIDE]]],
    ["..@...#...#.B.#[^B].[^B]#...",[[D_RIGHT,A_LOOK]],[[D_LEFT,A_LOOK]]],

    ["..@...#...#.B.#B.B#.[^B].",[[D_DOWN,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_SAVE],[D_DOWN,A_LOOK]]],
    [".L@...#...#.[^B].#...#...",[[D_UP,A_WALK]]],

    ["..@...#...#.[^B].#...#...",[[D_UP,A_WALK]],[[D_UP,A_WALK]],[[D_UP,A_LOOK]]],

    ["..@...#...#...#...#...",[[D_UP,A_SEARCH]]]
]
ActSeq = [ActSeq0 ,ActSeq1, ActSeq2]

#ActSeq = [ActSeq2]

# 回転のための配列
Rot = [[],[],[0,1,2,3,4,5,6,7,8,9],
    [],[0,7,4,1,8,5,2,9,6,3],
    [],[0,3,6,9,2,5,8,1,4,7],
    [],[0,9,8,7,6,5,4,3,2,1],[]]

MapXY = [[],[-1,-1],[-1,0],[-1,1],[0,-1],[0,0],[0,1],[1,-1],[1,0],[1,1]]

# 関数 ------------------------------------------------------------------------

# 表示用
def es_clear()
    printf("\e[2J\e[0;0H")
end

def es_locate(x,y)
    printf("\e[%d;%dH",x,y)
end

def es_color(c)
    printf("\e[3%dm",c)
end

def es_reset()
    printf("\e[0m")
end

# mymap更新
def set_mymap(x, y, val, act, dir)
    # 壁の処理
    if x - @map_x >= 0 then
        @mapsize_y.times do | y1 |
            @mymap[y1][x-@map_x] = M_OUTSIDE
        end
    end
    if x + @map_x < @mapsize_x then
        @mapsize_y.times do | y1 |
            @mymap[y1][x+@map_x] = M_OUTSIDE
        end
    end
    if y - @map_y >= 0 then
        @mapsize_x.times do | x1 |
            @mymap[y-@map_y][x1] = M_OUTSIDE
        end
    end
    if y + @map_y < @mapsize_y then
        @mapsize_x.times do | x1 |
            @mymap[y+@map_y][x1] = M_OUTSIDE
        end
    end

    # 相手キャラの位置は床にしておく
    (1..9).each do | i |
        if val[i] == M_CHARA
            val[i] = M_FLOOR
        end
    end

    case act
    when A_GETREADY
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            @mymap[y1][x1] = val[i]
        end
    when A_PUT
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            @mymap[y1][x1] = val[i]
        end
    when A_WALK
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            @mymap[y1][x1] = val[i]
        end
    when A_LOOK
        x += MapXY[dir][1] * 2
        y += MapXY[dir][0] * 2
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            @mymap[y1][x1] = val[i]
        end
    when A_SEARCH
    end


end

# mymap 表示
def disp_mymap()
    @mapsize_y.times do |my|
        @mapsize_x.times do |mx|
            es_color(@ch_color[@mymap[my][mx].to_i])
            printf("%2s", @chara[@mymap[my][mx].to_i])
        end
        es_reset
        printf("\n")
    end
end

# 周囲情報を回転して返す-----------------
def rotate(val, di)
    retv = Array.new(10)
    (1..9).each do |i|
        retv[i] = val[Rot[di][i]]
    end
    retv[0] = val[0]
    return retv
end

# 相対的な方向を絶対向きに変換----------------
def rm2am(r,a)
    return Rot[r][a]
end

# ログ出力----------------------------------
def putlog(str)
    new_str = str.dup
    $file.printf("%s",new_str[0,4])

    M_C.each do |mc|
        new_str.gsub!(mc[1].to_s,mc[0])
    end
    $file.printf("%s#%s#%s#%s#%s\n",new_str[4,3],new_str[7,3],new_str[10,3],new_str[13,3],new_str[16,3])
end

# メイン ##########################################################################

# サーバに接続
target = CHaserConnect.new("T-12") # この名前を4文字までで変更する

# 正規表現の処理
ActSeq.length.times do | am |
    ActSeq[am].each do |as|
        #        printf("%d::",ActSeq[am].index(as))
        as[0] = as[0].delete("#")  # "#"を取り除く
        #    p as
    end
end
#$file = File.open("looklog.txt","w")

es_clear

loop do # 無限ループ
    #----- ここから ---------------------------------------------------------------------------------------
    #    printf("step:%d\nx:%2d  y:%2d\n",step,x,y);

    values = target.getReady # 準備信号を送り制御情報と周囲情報を取得
    if values[0] == 0        # 制御情報が0なら終了
        break
    end

    set_mymap(x, y, values, A_GETREADY, mode)
    es_locate(0,0)
    disp_mymap()
    # --------------------------------------------------------------------

    r_values = rotate(values,mode) # 周囲情報を相対位置に

    rstr = (r_values.join)[1,9] # 周辺情報を文字列に

    if  rstr.index(M_CHARA.to_s) then # 敵がいる！
        queue.clear
        #        puts "Enemy !!"
    else

        # 敵がいなかったらchmap見てsaveしてあるところをブロックにする処理
        (1..9).each do |i|
            if chmap[y+MapXY[i][0]][x+MapXY[i][1]] < 0
                values[i] = M_BLOCK
            end
        end

        direc = []
        Directions.each do |di|
            if values[di] == M_FLOOR then
                direc += [chmap[y+MapXY[di][0]][x+MapXY[di][1]]*10 + di]
            end
        end
        #        p direc

        if direc.length > 1 then
            direc.sort {|a, b| b <=> a } #　降順でソート
            if (direc[0]/10).to_i > (direc[1]/10).to_i+1 then
                values[direc[0]%10] = M_BLOCK
            end
        else
        end

    end

    r_values = rotate(values,mode) # 周囲情報を相対位置に

    rstr = (r_values.join)[1,9] # 周辺情報を文字列に

    if last_act == A_LOOK then
        lrstr = (rotate(last_values,mode).join)[1,6]
    else
        lrstr = "999999"
    end
    rstr = lrstr + rstr

    M_C.each do |mc|
        rstr.gsub!(mc[1].to_s,mc[0])
    end

    estr = (step % 10).to_s + r_mode.to_s + last_act.to_s + "@" +  rstr

    D_C.each do |md|
        if estr[1] == md[1].to_s then
            estr[1] = md[0]
        end
    end
    A_C.each do |ma|
        if estr[2] == ma[1].to_s then
            estr[2] = ma[0]
        end
    end
    #    p estr

    if queue.length == 0 then  #アクションキューが空なら
        ActSeq[act_mode].each do | as |
            if estr.match(as[0]) then
                act_r = rand(as.length - 1)+1
                as[act_r].each do |as1|
                    queue << as1
                end
                #                printf("%d\n###%s\n###%s\n",ActSeq[act_mode].index(as),as[0],estr)
                #       p queue
                break
            end
        end
    end

    loop do
        #        p queue
        r_mode = queue[0][0]
        action = queue[0][1]
        queue.shift
        pre_mode = mode
        mode = rm2am(r_mode,mode) #相対向きを絶対向きに

        if action == A_SAVE then
            #save
            case mode # modeの方向をセーブ
            when D_UP
                chmap[y-1][x] = -100
            when D_RIGHT
                chmap[y][x+1] = -100
            when D_LEFT
                chmap[y][x-1] = -100
            else # when D_DOWN
                chmap[y+1][x] = -100
            end # case
        end

        if action != A_SAVE then
            break
        end
    end

    #   printf("mode:%d   action:%d\n",mode,action)

    if values[mode] == M_BLOCK && action == A_WALK then # ブロックに突っ込みそうなら
        action = A_LOOK              # とりあえずLOOK
        queue.clear
    end

    # ----------------------------------------------------------------------
    last_act = action
    case action
    when A_WALK
        case mode   # modeの方向に移動
        when D_UP
            values=target.walkUp
            y = y - 1
        when D_LEFT
            values=target.walkLeft
            x = x - 1
        when D_RIGHT
            values=target.walkRight
            x = x + 1
        else # when D_DOWN
            values=target.walkDown
            y = y + 1
        end
        chmap[y][x] += 1
        set_mymap(x, y, values, A_WALK, mode)
    when A_PUT
        case mode   # modeの方向にput
        when D_UP
            values=target.putUp
        when D_LEFT
            values=target.putLeft
        when D_RIGHT
            values=target.putRight
        else # when D_DOWN
            values=target.putDown
        end
        set_mymap(x, y, values, A_PUT, mode)

    when A_LOOK
        case mode   # modeの方向をlook
        when D_UP
            values=target.lookUp
        when D_LEFT
            values=target.lookLeft
        when D_RIGHT
            values=target.lookRight
        else # when D_DOWN
            values=target.lookDown
        end
        #        printf("#%s#%s#\n",values[1..9].join,M_CHARA.to_s)
        if ((values[1..9]).join).index(M_CHARA.to_s) then # 敵がいる！
            queue.clear
            #            puts "LOOK:Enemy !!"
        end
        set_mymap(x, y, values, A_LOOK, mode)

    when A_SLIDE
        case mode   # modeの方向に移動
        when D_UP
            values=target.walkUp
            y = y - 1
        when D_LEFT
            values=target.walkLeft
            x = x - 1
        when D_RIGHT
            values=target.walkRight
            x = x + 1
        else # when D_DOWN
            values=target.walkDown
            y = y + 1
        end
        set_mymap(x, y, values, A_WALK, mode)

        mode = pre_mode
        chmap[y][x] += 1

    when A_GLANCE
        case mode   # modeの方向を横目でlook
        when D_UP
            values=target.lookUp
        when D_LEFT
            values=target.lookLeft
        when D_RIGHT
            values=target.lookRight
        else # when D_DOWN
            values=target.lookDown
        end
        set_mymap(x, y, values, A_LOOK, mode)

        mode = pre_mode
        #       printf("#%s#%s#\n",values[1..9].join,M_CHARA.to_s)
        if ((values[1..9]).join).index(M_CHARA.to_s) then # 敵がいる！
            queue.clear
            #           puts "GLANCE:Enemy !!"
        end

    else #たぶんsearch
        case mode   # modeの方向をsearch
        when D_UP
            values=target.searchUp
        when D_LEFT
            values=target.searchLeft
        when D_RIGHT
            values=target.searchRight
        else # when D_DOWN
            values=target.searchDown
        end

    end # case action
    last_values = values.dup
    step = step + 1

    if (step % ActCycle == 0) then
        act_mode = rand(ActSeq.length)
    end
    #  act_mode = (step / ActCycle ) % ActSeq.length
    #p step,step/ActCycle, act_mode
    if values[0] == 0        # 制御情報が0なら終了
        break
    end

    es_locate(0,0)
    disp_mymap()

    #----- ここまで -----
end #loop

target.close # ソケットを閉じる
