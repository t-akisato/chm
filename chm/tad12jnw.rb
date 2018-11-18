# -*- coding: utf-8 -*-

#require_relative 'CHaserConnect.rb' # CHaserConnect.rbを読み込む Windows
require_relative 'CHaserConnect2009.rb' # CHaserConnect.rbを読み込む Windows
require 'pp'

# 定数 -------------------------------------------------------
# 方向
D_UP = 2
D_LEFT = 4
D_RIGHT = 6
D_DOWN = 8
D_NULL = 0

D_C = [["U",D_UP],["L",D_LEFT],["R",D_RIGHT],["D",D_DOWN]]
Directions=[D_UP, D_LEFT, D_RIGHT, D_DOWN]

S_Dirs = [[],[],[D_UP, D_LEFT, D_RIGHT, D_DOWN],
    [],[D_LEFT, D_RIGHT, D_DOWN, D_UP, ],
    [],[D_RIGHT, D_DOWN,D_UP, D_LEFT, ],
    [],[ D_DOWN, D_UP, D_LEFT, D_RIGHT],[]]

# マップ
M_FLOOR = 0
M_CHARA = 1
M_BLOCK = 2
M_ITEM = 3
M_UNKNOWN = 6
M_OUTSIDE = 7
M_SAVE = 8
M_SAFE = 9
M_DANGER = 10
M_NEWDANGER = 11

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
name = "T12j" # 名前

values = Array.new(10) # 書き換えない
@last_values = Array.new(10)
@r_mode = mode = Directions.sample #D_RIGHT # 現在の向き
pre_mode = mode
@step = 0
queue = []
@last_act = A_NULL
@act_mode = 0
action = A_NULL
LookInt = 3 # Lookの間隔
look_cnt = 5 # LookInt

MessageSize = 19
@message_buffer = Array.new(MessageSize)

@chara=[". ","X ","# ","$ ", "C ", "H ", "? ", "O ", "D "] # 表示用キャラセット
@ch_color=[7,7,7,3,6,5,4,0,1] # 表示色コード

# マップの大きさ
@map_x = 15
@map_y = 17

@mapsize_x = @map_x * 2 + 1
@mapsize_y = @map_y * 2 + 1

# マップでの初期位置
x = @map_x
y = @map_y

#記憶用マップ
@mymap = Array.new( @mapsize_y).map{Array.new((@mapsize_x),M_UNKNOWN)}

# 敵位置マップ
@enemymap = Array.new(@mapsize_y).map{Array.new((@mapsize_x),M_SAFE)}

#背景色描画用マップ
@bgmap = Array.new( @mapsize_y).map{Array.new((@mapsize_x),0)}
@rx = -1
@ry = -1

#アイテム発見フラグ
@new_item = false

# 正規表現とアクションシーケンス

# 敵がいた時の対処
ActSeq4E= [
    ["..@...#...#...#.C.#...",[[D_NULL,"ふふっ。"],[D_UP,A_SEARCH]]],
    ["..@...#...#.C.#...#...",[[D_NULL,"とおっ！"],[D_UP,A_PUT]]],   # 敵が前後左右にいたらPUT
    ["..@...#...#...#C..#...",[[D_NULL,"うりゃっ！"],[D_LEFT,A_PUT]]],
    ["..@...#...#...#..C#...",[[D_NULL,"くらえっ！"],[D_RIGHT,A_PUT]]],
    ["..@...#...#...#...#.C.",[[D_NULL,"よっ！"],[D_DOWN,A_PUT]]],

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

    ["..@...#...#C..#..[^B]#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]],[[D_RIGHT,A_WALK]]], # 敵がななめにいたら、LOOK か逃げる
    ["..@...#...#..C#[^B]..#.[^B].",[[D_UP,A_LOOK]],[[D_DOWN,A_WALK]],[[D_LEFT,A_WALK]]],
    ["..@...#...#.[^B].#..[^B]#C..",[[D_DOWN,A_LOOK]],[[D_UP,A_WALK]],[[D_RIGHT,A_WALK]]],
    ["..@...#...#.[^B].#[^B]..#..C",[[D_DOWN,A_LOOK]],[[D_UP,A_WALK]],[[D_LEFT,A_WALK]]],
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

    ["..@C..#[FI]..#[FI]..#F..#...",[[D_LEFT,A_SLIDE]]],
    ["..@..C#..[FI]#..[FI]#..F#...",[[D_RIGHT,A_SLIDE]]],
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
    [".L@.FF#.FF#BIF#..F#...",[[D_NULL,"トラップ設置します。"],[D_RIGHT,A_WALK],[D_LEFT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_RIGHT,A_PUT],[D_RIGHT,A_LOOK]],[[D_UP,A_WALK]],
    [[D_NULL,"トラップ設置します。"],[D_RIGHT,A_SLIDE],[D_LEFT,A_PUT],[D_RIGHT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@FF.#FF.#FIB#F..#...",[[D_NULL,"トラップ設置します。"],[D_LEFT,A_WALK],[D_RIGHT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_LEFT,A_PUT],[D_LEFT,A_LOOK]],[[D_UP,A_WALK]],
    [[D_NULL,"トラップ設置します。"],[D_LEFT,A_SLIDE],[D_RIGHT,A_PUT],[D_LEFT,A_WALK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@...#.B.#[^BI]I[^B]#[^B]..#[^B][^B].",[[D_NULL,"トラップ設置します。"],[D_LEFT,A_SLIDE],[D_UP,A_PUT],[D_RIGHT,A_PUT],[D_RIGHT,A_LOOK]] ],
    [".L@...#.B.#[^B]I[^BI]#..[^B]#.[^B][^B]",[[D_NULL,"トラップ設置します。"],[D_RIGHT,A_SLIDE],[D_UP,A_PUT],[D_LEFT,A_PUT],[D_LEFT,A_LOOK]] ],
    [".L@...#.B.#BIF#..F#...",[[D_NULL,"トラップ設置します。"],[D_RIGHT,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@...#.B.#FIB#F..#...",[[D_NULL,"トラップ設置します。"],[D_LEFT,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],
    [".L@...#.F.#BIB#...#FFF",[[D_NULL,"トラップ設置します。"],[D_DOWN,A_LOOK],[D_UP,A_WALK],[D_DOWN,A_PUT],[D_DOWN,A_LOOK]]],

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
    ["..@...#...#.I.#...#...",[[D_NULL,"アイテム周辺を確認。"],[D_UP,A_LOOK]]],
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
    [".L@.B.#B.B#BIB#...#...",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]], #はまるパターンなのでSAVE
    [".L@...#.B.#BIB#...#.[^B].",[[D_UP,A_SAVE],[D_DOWN,A_LOOK]]],#取ったらアウト

    ## アイテムをLOOKしてから取る
    [".L@...#...#.I.#...#...",[[D_UP,A_WALK]]],
    ["..@...#...#.I.#...#...",[[D_UP,A_LOOK]]],

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
    [".L@...#...#.[^B].#...#...",[[D_UP,A_WALK]]],

    ["..@...#...#.[^B].#...#...",[[D_UP,A_LOOK]],[[D_DOWN,A_LOOK]],[[D_RIGHT,A_LOOK]],[[D_LEFT,A_LOOK]]],
    ["..@...#...#...#...#...",[[D_UP,A_SEARCH]]]
]

# わりと直進
ActSeq1 = ActSeq4E + ActSeq4I2 + [

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

    ["..@...#...#.[^B].#...#...",[[D_UP,A_LOOK]],[[D_DOWN,A_LOOK]],[[D_RIGHT,A_LOOK]],[[D_LEFT,A_LOOK]]],

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
#ActSeq = [ActSeq0 ,ActSeq1, ActSeq2]

ActSeq = [ActSeq1,ActSeq1,ActSeq1,ActSeq0,ActSeq1]
ActCycle = 10 # パターン切り替えターン数

# 回転のための配列
Rot = [[0,0,0,0,0,0,0,0,0,0],[],[0,1,2,3,4,5,6,7,8,9],
    [],[0,7,4,1,8,5,2,9,6,3],
    [],[0,3,6,9,2,5,8,1,4,7],
    [],[0,9,8,7,6,5,4,3,2,1],[]]
RRot = [[0,0,0,0,0,0,0,0,0,0],[],[0,1,2,3,4,5,6,7,8,9],
    [],[0,3,6,9,2,5,8,1,4,7],
    [],[0,7,4,1,8,5,2,9,6,3],
    [],[0,9,8,7,6,5,4,3,2,1],[]]

MapXY = [[],[-1,-1],[-1,0],[-1,1],[0,-1],[0,0],[0,1],[1,-1],[1,0],[1,1]]

# 関数 ------------------------------------------------------------------------

# Safe?
def isSafe?(q1,x,y)
    if q1[1] == A_WALK || q1[1] == A_SLIDE then
        x = x + MapXY[q1[0]][1]
        y = y + MapXY[q1[0]][0]
        for i in 1..9 do
            if @enemymap[y + MapXY[i][0]][x + MapXY[i][1]] == M_DANGER then
                return false
            end
        end
    end
    return true
end

#
def set_enemy(ex,ey)
    for lx in 0..(@mapsize_x-1) do
        for ly in 0..(@mapsize_y-1) do
            if @enemymap[ly][lx] != M_BLOCK then
                @enemymap[ly][lx] = M_SAFE
            end
        end
    end
    @enemymap[ey][ex] = M_DANGER
end

def expand_enemymap_1(lx,ly)
    if lx >=@rx && lx < @rx + @map_x && ly >= @ry && ly < @ry + @map_y then
        if @enemymap[ly][lx] == M_SAFE then
            @enemymap[ly][lx] = M_NEWDANGER
        end
    end
end

def expand_enemymap()
    @mapsize_x.times do | lx |
        @mapsize_y.times do | ly |
            if @enemymap[ly][lx] == M_DANGER then
                expand_enemymap_1(lx - 1, ly)
                expand_enemymap_1(lx + 1, ly)
                expand_enemymap_1(lx, ly - 1)
                expand_enemymap_1(lx, ly + 1)
            end
        end
    end

    @mapsize_x.times do | lx |
        @mapsize_y.times do | ly |
            if @enemymap[ly][lx] == M_NEWDANGER then
                @enemymap[ly][lx] = M_DANGER
            end
        end
    end

end

# enemymap初期化
def start_enemymap(x,y)
    my_x = x-@rx
    my_y = y-@ry
    enemy_x = @rx + @map_x - my_x-1
    enemy_y = @ry + @map_y - my_y-1
    set_enemy(enemy_x,enemy_y)

end

# 表示用
def es_clear()
    printf("\e[2J\e[0;0H")
end

def es_locate(x,y)
    printf("\e[%d;%dH",y,x)
end

def es_color(c)
    printf("\e[3%dm",c)
end

def es_backcolor(c)
    printf("\e[4%dm",c)
end

def es_reset()
    printf("\e[0m")
end

def set_mymap_1(x,y,v)
    if x >= 0 && x < @mapsize_x && y >= 0 && y < @mapsize_y then
        case v
        when M_BLOCK
            @enemymap[y][x] = v
        when M_CHARA
            set_enemy(x,y)
            @new_item = true
            v = M_FLOOR
        else
            @enemymap[y][x] = M_SAFE
        end

        if @mymap[y][x] != M_ITEM && v == M_ITEM then
            @new_item = true
            add_message("ニューアイテム！")
        end
        #    if @mymap[y][x] != M_UNKNOWN && @mymap[y][x] != v then
        #      @new_item = true
        #      add_message("マップが変わってますね…")
        #    end

        if @mymap[y][x] == M_SAVE && (v == M_FLOOR || v == M_ITEM) then
        else
            @mymap[y][x] = v
            if @rx > 0 then
                x1 = @rx + @map_x - 1 - (x - @rx)
                y1 = @ry + @map_y - 1 - (y - @ry)
                if x1 >= 0 && x1 < @mapsize_x && y1 >= 0 && y1 < @mapsize_y then
                    if @mymap[y1][x1] == M_UNKNOWN then
                        @mymap[y1][x1] = v
                    end
                end
            end
        end
    end
end

def mirroring_map()
    @map_y.times do | y1 |
        @map_x.times do | x1 |
            set_mymap_1(@rx + x1, @ry + y1, @mymap[@ry + y1][@rx + x1])
        end
    end
end

# mymap更新
def set_mymap(x, y, val2, act, dir)
    val = val2.dup
    # 壁の処理
    if x - @map_x >= 0 then
        @mapsize_y.times do | y1 |
            set_mymap_1(x-@map_x, y1, M_OUTSIDE)
        end
    end
    if x + @map_x < @mapsize_x then
        @mapsize_y.times do | y1 |
            set_mymap_1(x+@map_x, y1, M_OUTSIDE)
        end
    end
    if y - @map_y >= 0 then
        @mapsize_x.times do | x1 |
            set_mymap_1(x1, y-@map_y, M_OUTSIDE)
        end
    end
    if y + @map_y < @mapsize_y then
        @mapsize_x.times do | x1 |
            set_mymap_1(x1, y+@map_y, M_OUTSIDE)
        end
    end

    # 相手キャラの位置は床にしておく
    #  (1..9).each do | i |
    #    if val[i] == M_CHARA
    #      val[i] = M_FLOOR
    #    end
    #  end
    #
    case act
    when A_GETREADY
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            set_mymap_1(x1, y1, val[i])
        end
    when A_PUT
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            set_mymap_1(x1, y1, val[i])
        end
    when A_WALK
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            set_mymap_1(x1, y1, val[i])
        end
    when A_LOOK
        x += MapXY[dir][1] * 2
        y += MapXY[dir][0] * 2
        (1..9).each do | i |
            x1 = x + MapXY[i][1]
            y1 = y + MapXY[i][0]
            set_mymap_1(x1, y1, val[i])
        end
    when A_SEARCH
        (1..9).each do | i |
            x1 = x + MapXY[dir][1] * i
            y1 = y + MapXY[dir][0] * i
            set_mymap_1(x1,y1,val[i])
        end
    end # case act

    #袋小路をSAVE
    loop do
        change_cnt = 0

        (@ry..(@ry + @map_y - 1)).each do | y2 |
            (@rx..(@rx + @map_x - 1)).each do    | x2 |
                if (@mymap[y2][x2] == M_FLOOR || @mymap[y2][x2] == M_ITEM) && x2 != x && y2 != y then
                    block_cnt = 0
                    Directions.each do | dir |
                        ch = @mymap[y2 + MapXY[dir][1]][x2 + MapXY[dir][0]]
                        if  ch == M_BLOCK then # || ch == M_SAVE then
                            block_cnt += 1
                        end
                    end
                    if block_cnt == 3 then
                        @mymap[y2][x2] = M_SAVE
                        change_cnt += 1
                    end
                end
            end
        end

        if change_cnt == 0 then
            break
        end
    end
end

# mymap 表示
def disp_mymap(x,y,mode, queue)

    #    if @rx < 0 then
    #        return
    #    end

    # queue描く
    fill2d(@bgmap,0) # 消去

    @mapsize_x.times do | lx |
        @mapsize_y.times do | ly |
            if @enemymap[ly][lx] == M_DANGER then
                @bgmap[ly][lx] = 5
            end
        end
    end

    @bgmap[y][x] = 4
    if queue.length > 0 then
        queue.each do |que|
            @r_mode = que[0]
            action = que[1]
            pre_mode = mode
            mode = rm2am(@r_mode,mode) #相対向きを絶対向きに

            case action # アクションによって
            when A_WALK
                x += MapXY[mode][1]
                y += MapXY[mode][0]
                @bgmap[y][x] = 1
            when A_SLIDE
                x += MapXY[mode][1]
                y += MapXY[mode][0]
                @bgmap[y][x] = 1
                mode = pre_mode
            when A_LOOK
                @bgmap[y][x] = 3
            end
        end
    end
    msg_cnt = 0
    ((@ry-1)..(@ry+@map_y)).each do |my|
        ((@rx-1)..(@rx+@map_x)).each do |mx|
            es_color(@ch_color[@mymap[my][mx].to_i])
            if(@bgmap[my][mx]!= 0)
                es_backcolor(@bgmap[my][mx])
            end
            if(@rx < 0) then
                printf("  ")
            else
                printf("%1s " , @chara[@mymap[my][mx].to_i][0])
            end
            es_backcolor(0)
        end
        es_reset

        #        printf(" %-20s\e[0K\n", @message_buffer[msg_cnt])
        printf("\n")
        msg_cnt += 1
    end
    #    printf("\e[0J")
end

def show_message()
    line = 0
    @message_buffer.each do |mes|
        es_locate((@map_x +2)*2+ 2,line)
        printf("%s\e[0K",mes)
        line += 1
    end
#    sleep(0.01)
end

def add_message(str)
    @message_buffer = @message_buffer[1,MessageSize-1] + [str]
    show_message()
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

# 2次元配列の複製を返す
def dup2d(m)
    m2 = Array.new(m.length)
    m.length.times do | i |
        m2[i] = m[i].dup
    end
    return m2
end

def fill2d(m,v)
    m.length.times do | i |
        m[i].length.times do | j |
            m[i][j] = v
        end
    end
end

def dir2act(ds,mode)
    md = mode
    as = []
    ds.each do | d |
        as << [RRot[md][d], A_WALK]
        md = d
    end
    return as
end

def countUnknown(y,x)
    count = 0
    (1..9).each do | i |
        y1 = y + MapXY[i][0]
        x1 = x + MapXY[i][1]
        if y1 >= 0 && y1 < @mapsize_y && x1 >= 0 && x1 < @mapsize_x then
            if @mymap[y1][x1] == M_UNKNOWN then
                count += 1
            end
        end
    end
    return count
end

def countUnknownS(y,x,mode)
    count = 0
    (1..9).each do | i |
        y1 = y + MapXY[mode][0] * i
        x1 = x + MapXY[mode][1] * i
        if y1 >= 0 && y1 < @mapsize_y && x1 >= 0 && x1 < @mapsize_x then
            if @mymap[y1][x1] == M_UNKNOWN then
                count += 1
            end
        end
    end
    return count
end

def checkOutside()
    rx0 = @map_x - 9
    while @mymap[@map_y][rx0] == M_BLOCK
        rx0 += 1
    end
    rx1 = @map_x + 9
    while @mymap[@map_y][rx1] == M_BLOCK
        rx1 -= 1
    end
    if rx0 > @map_x - 9 then
        rx1 = rx0 + @map_x - 1
    else
        rx0 = rx1 - @map_x + 1
    end

    ry0 = @map_y - 9
    while @mymap[ry0][@map_x] == M_BLOCK
        ry0 += 1
    end
    ry1 = @map_y + 9
    while @mymap[ry1][@map_x] == M_BLOCK
        ry1 -= 1
    end
    if ry0 > @map_y - 9 then
        ry1 = ry0 + @map_y - 1
    else
        ry0 = ry1 - @map_y + 1
    end
    printf("rxry: %d,%d,%d,%d\n", rx0,ry0,rx1,ry1)
    # 外側をM_OUTSIDEに
    @mapsize_y.times do | y |
        (0..rx0-1).each do | x |
            @mymap[y][x] = M_OUTSIDE
        end
        ((rx1+1)..(@mapsize_x - 1)).each do | x |
            @mymap[y][x] = M_OUTSIDE
        end
    end
    @mapsize_x.times do | x |
        (0..ry0-1).each do | y |
            @mymap[y][x] = M_OUTSIDE
        end
        ((ry1+1)..(@mapsize_y - 1)).each do | y |
            @mymap[y][x] = M_OUTSIDE
        end
    end
    @rx = rx0
    @ry = ry0
end

# 進路決定 -----------------------------------
def find_route(x, y, g, mode)
    route = []
    smap = dup2d(@mymap)
    fill2d(smap,0)
    smap[y][x] = 1
    squeue = [[x,y,[]]]

    loop do
        elm = squeue.shift
        S_Dirs[mode].each do | dir |
            x1 = elm[0] + MapXY[dir][1]
            y1 = elm[1] + MapXY[dir][0]

            if @mymap[y1][x1] == g then
                return dir2act(elm[2] << dir,mode)
            elsif @mymap[y1][x1] == M_FLOOR && smap[y1][x1] == 0 then
                squeue << [x1, y1, elm[2] + [dir]]
                smap[y1][x1] = smap[elm[1]][elm[0]] + 1
            end
        end

        if squeue.length == 0 then
            break
        end
    end

    return []
end

# パターンマッチング用文字列を返す
def make_status_string(values, mode)
    r_values = rotate(values,mode) # 周囲情報を相対位置に
    rstr = (r_values.join)[1,9] # 周辺情報を文字列に

    # 前回 LOOK してたらその情報を付け加える
    if @last_act == A_LOOK then
        lrstr = (rotate(@last_values,mode).join)[1,6]
    else
        lrstr = "999999"
    end
    rstr = lrstr + rstr

    # 数字を文字に
    M_C.each do |mc|
        rstr.gsub!(mc[1].to_s,mc[0])
    end

    estr = (@step % 10).to_s + @r_mode.to_s + @last_act.to_s + "@" +  rstr

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
    return estr
end

#アクションキューが空ならパターンマッチング
def search_queue(estr)
    queue = []
    ActSeq[@act_mode].each do | as |
        if estr.match(as[0]) then
            add_message(as[0]+" がマッチしました。")

            act_r = rand(as.length - 1) + 1
            as[act_r].each do |as1|
                queue << as1
            end
            break
        end
    end
    return queue
end

# values に敵がいる？（ブロックの向こうは無視）
def enemy_in_values?(v)
    if v[2] == M_CHARA || v[4] == M_CHARA || v[6] == M_CHARA || v[8] == M_CHARA then
        return true
    elsif v[1] == M_CHARA && (v[2] != M_BLOCK || v[4] != M_BLOCK) ||
    v[3]== M_CHARA && (v[2] != M_BLOCK || v[6] != M_BLOCK) ||
    v[7]== M_CHARA && (v[4] != M_BLOCK || v[8] != M_BLOCK) ||
    v[9]== M_CHARA && (v[6] != M_BLOCK || v[8] != M_BLOCK) then
        return true
    end
    return false
end

def enemy_in_3x5?(estr)
    area = estr[4,15]
    if !area.include?(M_C[M_CHARA][0]) then
        add_message("敵はいません。")
        return false
    end
    q = [[1,3]] #スタート
    loop do
        p = q.shift
        if area[p[0]+p[1]*3] == M_C[M_CHARA][0] then
            add_message("敵がいます。")
            return true
        end
        area[p[0]+p[1]*3] = M_C[M_BLOCK][0]
        if p[0] > 0 && area[p[0]-1+p[1]*3] != M_C[M_BLOCK][0] then
            q << [p[0]-1,p[1]]
        end
        if p[0] < 2 && area[p[0]+1+p[1]*3] != M_C[M_BLOCK][0] then
            q << [p[0]+1,p[1]]
        end
        if p[1] > 0 && area[p[0]+(p[1]-1)*3] != M_C[M_BLOCK][0] then
            q << [p[0],p[1]-1]
        end
        if p[1] < 4 && area[p[0]+(p[1]+1)*3] != M_C[M_BLOCK][0] then
            q << [p[0],p[1]+1]
        end
        if q.empty?  then
            break
        end
    end
    add_message("敵は見えません。")
    return false
end

# main ##########################################################################

# サーバに接続
target = CHaserConnect.new(name) # この名前を4文字までで変更する

# 正規表現の前処理
ActSeq.length.times do | am |
    ActSeq[am].each do |as|
        as[0] = as[0].delete("#")  # "#"を取り除く
    end
end

es_clear
queue = [[D_NULL,"位置計測その１"],[D_RIGHT,A_SEARCH],
    [D_NULL,"位置計測その2"],[D_LEFT,A_SEARCH],
    [D_NULL,"位置計測その3"],[D_UP,A_SEARCH],
    [D_NULL,"位置計測完了。"],[D_DOWN,A_SEARCH]]

add_message(name + " いきまーす！")

loop do # 無限ループ
    #----- ここから ---------------------------------------------------------------------------------------
    add_message("step "+@step.to_s)
    @new_item = false
    es_locate(0,@map_y+3)
    values = target.getReady # 準備信号を送り制御情報と周囲情報を取得
    if values[0] == 0        # 制御情報が0なら終了
        break
    end
    # getReadyの戻り値をマップに書き込む
    set_mymap(x, y, values, A_GETREADY, mode)

    #新しいアイテム見つけたらキューをクリア
    if @step > 4 && @new_item then

        queue.clear
        add_message("アイテム見つけたのでキュークリア。")
    end

    # マップ表示
    es_locate(0,0)
    disp_mymap(x,y,mode,queue)
    # --------------------------------------------------------------------

    #    r_values = rotate(values,mode) # 周囲情報を相対位置に
    #    rstr = (r_values.join)[1,9] # 周辺情報を文字列に

    # 敵がいなかったら@mymap見てsaveしてあるところをブロックにする処理
    if  !enemy_in_values?(values) then
        (1..9).each do |i|
            if @mymap[y+MapXY[i][0]][x+MapXY[i][1]] == M_SAVE
                values[i] = M_BLOCK
            end
        end
    else
        queue.clear
        add_message("敵発見！")
    end

    #パターンマッチング用文字列を作る
    estr = make_status_string(values, mode)

    if enemy_in_3x5?(estr) then # 敵がいる
        queue = search_queue(estr)
    elsif queue.empty? then # キューが空
        add_message("キューが空です。")
        if estr.include?(M_C[M_ITEM][0]) then # アイテムある
            add_message("アイテムあるのでパターンマッチング。")
            queue = search_queue(estr)
        else
            add_message("アイテム無いのでルート検索。")
            queue = find_route(x,y, M_UNKNOWN, mode)
            item_queue = find_route(x,y, M_ITEM, mode)
            if (item_queue.length > 0 && item_queue.length < queue.length * 2) || queue.length == 0 then
                if !item_queue.empty? then
                    add_message("アイテムへのルート見つけました。")
                end
                queue = item_queue
            else
                add_message("アイテム無いので未探索域行き。")
            end
            if queue.length > 1 then
                queue[queue.length-1][1] = A_LOOK #最後はLOOK
                #    queue = [queue[0][0],A_GLANCE] + queue
                if @last_act != A_LOOK && @last_act != A_GLANCE && @last_act != A_SEARCH then
                    queue = [[queue[0][0],A_LOOK]] + queue
                    queue[1][0] = D_UP
                end

            else
                add_message("ルート無いのでパターンマッチング。")
                queue = search_queue(estr)
            end
        end
    else
        # 敵がいなくてWALKならLOOKやSEARCH入れる
        if queue[0][1] == A_WALK && !estr.include?(M_C[M_CHARA][0]) then
            lqueue = []
            Directions.each do | rdir |
                dir = rm2am(rdir,mode)
                if countUnknown(y+MapXY[dir][0]*2,x+MapXY[dir][1]*2) >= 5 then
                    lqueue = [[rdir, A_GLANCE]] + lqueue
                end
                if countUnknownS(y,x,dir) >= 6 then
                    lqueue = [[rdir, A_SEARCH]] + lqueue
                end
            end
            if !lqueue.empty? then
                queue = [lqueue.sample] + queue
            end
        end
    end

    # LOOKカウンターの処理
    if queue[0][1] == A_LOOK || queue[0][1] == A_GLANCE || isSafe?(queue[0],x,y) then
        look_cnt = LookInt
    else
        look_cnt -= 1
    end
    if look_cnt <= 0 && queue[0][1] != A_PUT then     #lookカウンターが0以下ならQ先頭にLOOKを追加
        look_cnt = LookInt
        queue = [[queue[0][0],A_LOOK]] + queue
        queue[1][0] = D_UP
    end

    # SAVE と NULL の処理
    loop do
        @r_mode = queue[0][0]
        action = queue[0][1]
        queue.shift
        pre_mode = mode
        if @r_mode == D_NULL
            add_message(action)
        else
            mode = rm2am(@r_mode,mode) #相対向きを絶対向きに

            if action == A_SAVE then
                #save
                case mode # modeの方向をセーブ
                when D_UP
                    @mymap[y-1][x] = M_SAVE
                when D_RIGHT
                    @mymap[y][x+1] = M_SAVE
                when D_LEFT
                    @mymap[y][x-1] = M_SAVE
                else # when D_DOWN
                    @mymap[y+1][x] = M_SAVE
                end # case
            end

        end
        if action != A_SAVE && @r_mode != D_NULL then
            break
        end
    end

    if values[mode] == M_BLOCK && (action == A_WALK || action == A_SLIDE) then # ブロックに突っ込みそうなら
        action = A_SEARCH            # とりあえずSEARCH
        queue.clear
    end
    #    es_locate(0,0)
    #    disp_mymap(x,y,mode,queue)

    # ----------------------------------------------------------------------
    @last_act = action

    ms = ["NULL","put","walk","look","search","slide","glance","save"][action] +" " + ["","","Up","","Left","","Right","","Down"][mode]
    add_message(ms+" します。")
    es_locate(0,@map_y+5)
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
        if ((values[1..9]).join).index(M_CHARA.to_s) then # 敵がいる！
            queue.clear
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
        set_mymap(x, y, values, A_SEARCH, mode)

        mode = pre_mode

    end # case action

    #新しいアイテム見つけたらキューをクリア
    if @step > 4 && @new_item then
        queue.clear
        add_message("アイテム見つけたのでキュークリア。")

    end

    @last_values = values.dup
    @step = @step + 1

    if @step == 4 then
        checkOutside()
        mirroring_map()
        start_enemymap(x,y)
        expand_enemymap()
        expand_enemymap()
        expand_enemymap()
        expand_enemymap()
    else
        expand_enemymap()
    end

    @act_mode = (@step / ActCycle ) % ActSeq.length
    if values[0] == 0        # 制御情報が0なら終了
        break
    end

    es_locate(0,0)
    disp_mymap(x,y,mode,queue)
    #----- ここまで -----
end #loop

target.close # ソケットを閉じる
