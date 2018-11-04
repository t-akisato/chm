# -*- coding: utf-8 -*-
#

require_relative 'CHaserConnect.rb' # CHaserConnect.rbを読み込む Windows

# サーバに接続
@target = CHaserConnect.new("c-01") # この名前を4文字までで変更する

values = Array.new(10) # 書き換えない
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

A_C = [["N",A_NULL],["P",A_PUT],["W",A_WALK],["L",A_LOOK],["S",A_SEARCH],["D",A_SLIDE],["G",A_GLANCE],["V",A_SAVE]]

def myGetReady
  l_values = Array.new(10)
  l_values = @target.getReady


  return l_values
end



loop do # 無限ループ
  #----- ここから -----

  values = myGetReady
  if values[0] == 0 # 先頭が0になったら終了
    break
  end
  values = @target.searchUp
  if values[0] == 0
    break
  end
  values = myGetReady
  if values[0] == 0
    break
  end
  values = @target.searchRight
  if values[0] == 0
    break
  end
  values = myGetReady
  if values[0] == 0
    break
  end
  values = @target.searchDown
  if values[0] == 0
    break
  end
  values = myGetReady
  if values[0] == 0
    break
  end
  values = @target.searchLeft
  if values[0] == 0
    break
  end

  #----- ここまで -----
end

@target.close # ソケットを閉じる
