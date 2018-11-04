# -*- coding: utf-8 -*-
# Test用プログラム 周りを調べながら行動する
#
#

require_relative 'CHaserConnect2010.rb' # CHaserConnect.rbを読み込む Windows

# サーバに接続
target = CHaserConnect.new("テストⅢ") # この名前を4文字までで変更する

values = Array.new(10) # 書き換えない
mode = 1

loop do # 無限ループ
  #----- ここから -----
  values = target.getReady
  if values[0] == 0             # 先頭が0になったら終了
    break
  end
  if values[2] == 1             # 上に相手がいたら
    values = target.putUp
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[4] == 1          # 左に相手がいたら
    values = target.putLeft
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[6] == 1          # 右に相手がいたら
    values = target.putRight
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[8] == 1          # 下に相手がいたら
    values = target.putDown
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[1] == 1          # 左上に相手がいたら
    if mode == 1                # 下に進んでいるとき
      values = target.putUp     # 相手は右に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 2             # 右に進んでいるとき
      values = target.putLeft   # 相手は下に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 3             # 上に進んでいるとき
      values = target.putLeft   # 相手は右に進んでいる可能性もあるが下に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 4             # 左に進んでいるとき
      values = target.putUp     # 相手は下に進んでいる可能性もあるが右に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    end
  elsif values[3] == 1          # 右上に相手がいたら
    if mode == 1                # 下に進んでいるとき
      values = target.putUp     # 相手は左に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 2             # 右に進んでいるとき
      values = target.putUp     # 相手は下に進んでいる可能性もあるが左に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 3             # 上に進んでいるとき
      values = target.putRight  # 相手は左に進んでいる可能性もあるが下に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 4             # 左に進んでいるとき
      values = target.putRight  # 相手は下に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    end
  elsif values[9] == 1          # 右下に相手がいたら
    if mode == 1                # 下に進んでいるとき
      values = target.putRight  # 相手は左に進んでいる可能性もあるが上に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 2             # 右に進んでいるとき
      values = target.putDown   # 相手は上に進んでいる可能性もあるが左に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 3             # 上に進んでいるとき
      values = target.putDown   # 相手は左に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 4             # 左に進んでいるとき
      values = target.putRight  # 相手は上に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    end
  elsif values[7] == 1          # 左下に相手がいたら
    if mode == 1                # 下に進んでいるとき
      values = target.putLeft   # 相手は右に進んでいる可能性もあるが上に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 2             # 右に進んでいるとき
      values = target.putLeft   # 相手は上に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 3             # 上に進んでいるとき
      values = target.putDown   # 相手は右に進んでいる
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    elsif mode == 4             # 左に進んでいるとき
      values = target.putDown   # 相手は上に進んでいる可能性もあるが右に進んでいると仮定する
      if values[0] == 0         # 先頭が0になったら終了
        break
      end
    end
  elsif values[2] == 3          # 上がアイテムならば
    values = target.walkUp
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[4] == 3          # 左がアイテムならば
    values = target.walkLeft
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[6] == 3          # 右がアイテムならば
    values = target.walkRight
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  elsif values[8] == 3          # 下がアイテムならば
    values = target.walkDown
    if values[0] == 0           # 先頭が0になったら終了
      break
    end
  else
    walked = false
    loop do
      # modeの値で分岐する
      if mode == 1
        if values[8] != 2           # 下がブロックでないなら
          values = target.walkDown  # 下に進む
          if values[0] == 0         # 先頭が0になったら終了
            break
          end
          walked = true
        else                        # 下がブロックなら
          mode = 2
          if values[4] != 2         # 左がブロックでないなら
            if rand(2) == 0         # 半々の確率でmode変更
              mode = 4
            end
          end
        end
      elsif mode == 2
        if values[6] != 2           # 右がブロックでないなら
          values = target.walkRight # 右に進む
          if values[0] == 0         # 先頭が0になったら終了
            break
          end
          walked = true
        else                        # 右がブロックなら
          mode = 3
          if values[8] != 2         # 下がブロックでないなら
            if rand(2) == 0         # 半々の確率でmode変更
              mode = 1
            end
          end
        end
      elsif mode == 3
        if values[2] != 2           # 上がブロックでないなら
          values = target.walkUp    # 上に進む
          if values[0] == 0         # 先頭が0になったら終了
            break
          end
          walked = true
        else                        # 上がブロックなら
          mode = 4
          if values[6] != 2         # 右がブロックでないなら
            if rand(2) == 0         # 半々の確率でmode変更
              mode = 2
            end
          end
        end
      elsif mode == 4
        if values[4] != 2           # 左がブロックでないなら
          values = target.walkLeft  # 左に進む
          if values[0] == 0         # 先頭が0になったら終了
            break
          end
          walked = true
        else                        # 左がブロックなら
          mode = 1
          if values[2] != 2         # 上がブロックでないなら
            if rand(2) == 0         # 半々の確率でmode変更
              mode = 3
            end
          end
        end
      end
      if walked == true
        break
      end
    end
  end
  #----- ここまで -----
end

target.close # ソケットを閉じる
