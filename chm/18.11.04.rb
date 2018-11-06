# -*- coding: utf-8 -*-
# Test用プログラム 壁にそって進む

require_relative 'CHaserConnect.rb' # CHaserConnect.rbを読み込む Windows
#斜めに敵がいたときの処理をlookあり
# サーバに接続
target = CHaserConnect.new("kuru") # この名前を4文字までで変更する

values = Array.new(10) # 書き換えない
values2 = Array.new(10)
v = Array.new(5)
v2 = Array.new(5)
mode = 1
turn = 0
look = 0
map = Array.new(36).map{Array.new(32,0)}
   y = 18
   x = 16
loop do # 無限ループ
  #----- ここから -----
  turn = turn +1
  puts 0, mode, turn
  values = target.getReady # 準備信号を送り制御情報と周囲情報を取得
  if values[0] == 0        # 制御情報が0なら終了
    break
  end
  look = 0
  puts mode
      v[0] = -1#0でエラーが出ないようにする
      v[1] = values[2] == 2 ? 300 : map[y-1][x]
      v[2] = values[4] == 2 ? 300 : map[y][x-1]
      v[3] = values[6] == 2 ? 300 : map[y][x+1]
      v[4] = values[8] == 2 ? 300 : map[y+1][x]

      v2 = v.sort

    #  if v[mode] >= v2[4]  && v2[2] < v2[4]#
        mode = v.find_index(v2[1])
     # end

  puts 1,mode
if values[1] == 2 && values[2] == 3 && values[3] == 2 && values[8] == 0
        values = target.walkDown
        values = target.getReady
        if rand(2) ==  0
        values = target.putUp
        values = target.getReady
        else mode = 4
        end
      end
      if values[1] == 2 && values[4] == 3 && values[7] == 2 && values[6] == 0
        values = target.walkRight
        values = target.getReady
        if rand(2) == 0
        values = target.putLeft
        values = target.getReady
      else mode = 3
        end
      end
      if values[3] == 2 && values[6] == 3 && values[9] == 2 && values[4] == 0
        values = target.walkLeft
        values = target.getReady
        if rand(2) == 0
        values = target.putRight
        values = target.getReady
      else mode = 2
        end
      end
      if values[7] == 2 && values[8] == 3 && values[9] == 2 && values[2] == 0
        values = target.walkUp
        values = target.getReady
        if rand(2) == 0
        values = target.putDown
        values = target.getReady
      else mode = 1
        end
      end
  # 敵がいたらPUT
  if values[2] == 1
    values = target.putUp
  end
  if values[4] == 1
    values = target.putLeft
  end
  if values[6] == 1
    values = target.putRight
  end
  if values[8] == 1
    values = target.putDown
  end
turn = 3
      while values[1] == 1 && (turn > 0 || values[6] == 2 && values[8] == 2)
        turn -= 1
        values = target.lookUp
        values = target.getReady
        if turn == 0
          mode = 3
          if values[0] == 0
            break
          end
        end
      end
      while values[3] == 1 && (turn > 0 || values[4] == 2 && values[8] == 2)
        turn -= 1
        values = target.lookUp
        values = target.getReady
        if turn == 0
          mode = 2
          if values[0] == 0
            break
          end
        end
      end
      while values[7] == 1 && (turn > 0 || values[2] == 2 && values[6] == 2)
        turn -= 1
        values = target.lookDown
        values = target.getReady
        if turn == 0
          mode = 3
          if values[0] == 0
            break
          end
        end
      end
      while values[9] == 1 && (turn > 0 || values[2] == 2 && values[4] == 2)
        turn -= 1
        values = target.lookDown
        values = target.getReady
        if turn == 0
          mode = 2
          if values[0] == 0
            break
          end
        end
      end


    if values[2] == 1
          values = target.putUp
      elsif values[4] == 1
        values = target.putLeft
      elsif values[6] == 1
        values = target.putRight
      elsif values[8] == 1
        values = target.putDown
    end


  if turn % 5 == 0
    look =1
    if mode == 1

      p values = target.lookUp
      if values[1] == 1 || values[2] == 1 || values[3] == 1 || values[5] == 1 || values[8] == 1#ここに敵がいた時やアイテムがあった時のプログラムを書く
        mode = 4
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putUp
      elsif values[4] == 1 || values[7] == 1
        mode = 3
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putLeft
      elsif values[6] == 1 || values[9] == 1
        mode = 2
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putRight
        #      elsif values[1] == 3 || values[2] == 3 || values[3] == 3 || values[4] == 3 || values[5] == 3 || values[6] == 3 || values[7] == 3 || values[8] == 3 || values[9] == 3
        #        mode = 2
      end

    elsif mode == 2

      p values = target.lookLeft
      if values[1] == 1 || values[2] == 1 || values[3] == 1
        mode = 3
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putUp
      end
      if values[4] == 1 || values[5] == 1 || values[6] == 1
        mode = 3
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putLeft
      end
      if values[7] == 1 || values[8] == 1 || values[9] == 1
        mode = 3
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values= target.putDown
      end
      #      if values[1] == 3 || values[2] == 3 || values[3] == 3 || values[4] == 3 || values[5] == 3 || values[6] == 3 || values[7] == 3 || values[8] == 3 || values[9] == 3
      #        mode = 2
      #      end
    elsif mode == 3

      p values = target.lookRight
      if values[1] == 1 || values[2] == 1 || values[3] == 1
        mode = 2
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putUp
      end
      if values[4] == 1 || values[5] == 1 || values[6] == 1
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putLeft
        mode = 2
      end
      if values[7] == 1 || values[8] == 1 || values[9] == 1
        mode = 2
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putDown
      end
      #      if values[1] == 3 || values[2] == 3 || values[3] == 3 || values[4] == 3 || values[5] == 3 || values[6] == 3 || values[7] == 3 || values[8] == 3 || values[9] == 3
      #        mode = 2
      #      end
      look = 1
    elsif mode == 4

      p values = target.lookDown
      if values[2] == 1 || values[5] == 1 || values[8] == 1
        mode = 1
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putDown
      end
      if values[3] == 1 || values[6] == 1 || values[9] == 1
        mode = 1
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putRight
      end
      if values[1] == 1 || values[4] == 1 || values[7] == 1
        mode = 1
        values2 = target.getReady
        if values2[0] == 0        # 制御情報が0なら終了
          break
        end
        values = target.putLeft
      end
      #      if values[1] == 3 || values[2] == 3 || values[3] == 3 || values[4] == 3 || values[5] == 3 || values[6] == 3 || values[7] == 3 || values[8] == 3 || values[9] == 3
      #        mode = 2
      #      end
      #look = 1
    end
  end #turn % 3 == 0

  if look == 0

    #アイテムあれば取りに行く
    if values[2] == 3
      mode = 1
    elsif values[4] == 3
      mode = 2
    elsif values[6] == 3
      mode = 3
    elsif values[8] == 3
      mode = 4
    end
    puts 2,mode

if (turn % 20 == 0) && (values[1] != 3 && values[2] != 3 && values[3] != 3 && values[4] != 3 && values[6] != 3 && values[7] != 3 && values[8] != 3 && values[9] != 3 )
    if rand(3) == 0
      mode = 1
    elsif rand(3) == 1
      mode = 2
    elsif rand(3) == 2
      mode = 3
    elsif rand(3) == 3
      mode = 4
    end
end
    #-------------------------------------------上に進んだときーーーーーーーーーーーーーーーーーーーーーーーーーー
    if mode == 1
      if values[2] != 2
        values = target.walkUp
        mode = 1
      elsif values[4] != 2
        values = target.walkLeft
        mode = 2
      elsif values[8] != 2
        values = target.walkDown
        mode = 4
      elsif values[6] != 2
        values = target.walkRight
        mode = 3
      end
      #--------------------------------------------左に進んだとき-----------------------------------------------------
    elsif mode == 2
      if values[4] != 2
        values = target.walkLeft
        mode = 2
      elsif values[8] != 2
        values = target.walkDown
        mode = 4
      elsif values[2] != 2
        values = target.walkUp
        mode = 1
      elsif values[6] != 2
        values = target.walkRight
        mode = 3
      end
      #------------------------------------------右に進んだとき-------------------------------------------------------------------
    elsif mode == 3
      if values[6] != 2
        values = target.walkRight
        mode = 3
      elsif values[2] != 2
        values = target.walkUp
        mode = 1
      elsif values[8] != 2
        values = target.walkDown
        mode = 4
      elsif values[4] != 2
        values = target.walkLeft
        mode = 2
      end
      #-------------------------------------------下に進んだときーーーーーーーーーーーーーーーーーーーーーーーーーーー
    elsif mode == 4
      if values[8] != 2
        values = target.walkDown
        mode = 4
      elsif values[6] != 2
        values = target.walkRight
        mode = 3
      elsif values[4] != 2
        values = target.walkLeft
        mode = 2

      elsif values[2] != 2
        values = target.walkUp
        mode = 1
      end
      puts "***"
    end
    if mode == 1
      y = y-1
    elsif mode == 2
      x = x-1
    elsif mode == 3
      x = x+1
    elsif mode == 4
      y = y+1
    end
       map[y][x]=map[y][x]+1

    puts 3,mode
  end
  puts 4,mode
end
#----- ここまで -----
target.close