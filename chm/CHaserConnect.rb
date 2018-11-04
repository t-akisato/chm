# -*-coding: utf-8 -*-

# CHaserクライアント通信プログラム
# これは書き換えない
#test

require 'socket'

class CHaserConnect
  def initialize(name)
    begin
      # 接続先IPアドレスをコンソールから入力
      puts("接続先IPアドレスを入力してください")
      host = gets.chomp
      if host == "l"
        host = "localhost"
      end

      # 接続先ポート番号をコンソールから入力
      puts("接続先ポート番号を入力してください")
      port = gets.chomp
      # 接続先ポート番号に応じて名前をエンコード
      if port == "40000" or port == "50000"
        @name = name.encode('CP932') # なでしこサーバー時（環境依存文字の対応のため、SHIFT_JISではなくCP932とする）
      else
        @name = name.encode("UTF-8") # それ以外のサーバー時（utf-8のままにする）
      end
      # TCPソケットを開く
      @socket = TCPSocket.open(host, port)
      # 名前を送信
      @socket.puts(@name)
    rescue
      puts "\"#{@name.encode("UTF-8")}\"はサーバに接続出来ませんでした"
      puts "サーバが起動しているかどうか or ポート番号、IPアドレスを確認してください"
    else
      puts "\"#{@name.encode("UTF-8")}\"はサーバに接続しました"
    end
  end

  # 準備信号
  def getReady()
    begin
      puts "\"#{@name.encode("UTF-8")}\"はgetReadyをサーバに送信"
      msg = @socket.gets
      @socket.puts("gr\r")
      msg = @socket.gets
      p msg
      results = parseInt(msg)
      return results
    rescue
      puts "\"#{@name.encode("UTF-8")}\"はgetReadyをサーバに送信できませんでした"
    end
  end

  # 右に進む
  def walkRight()
    puts "\"#{@name.encode("UTF-8")}\"はwalkRightをサーバに送信"
    @socket.puts("wr\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 左に進む
  def walkLeft()
    puts "\"#{@name.encode("UTF-8")}\"はwalkLeftをサーバに送信"
    @socket.puts("wl\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 上に進む
  def walkUp()
    puts "\"#{@name.encode("UTF-8")}\"はwalkUpをサーバに送信"
    @socket.puts("wu\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 下に進む
  def walkDown()
    puts "\"#{@name.encode("UTF-8")}\"はwalkDownをサーバに送信"
    @socket.puts("wd\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 右を見る
  def lookRight()
    puts "\"#{@name.encode("UTF-8")}\"はlookRightをサーバに送信"
    @socket.puts("lr\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 左を見る
  def lookLeft()
    puts "\"#{@name.encode("UTF-8")}\"はlookLeftをサーバに送信"
    @socket.puts("ll\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 上を見る
  def lookUp()
    puts "\"#{@name.encode("UTF-8")}\"はlookUpをサーバに送信"
    @socket.puts("lu\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 下を見る
  def lookDown()
    puts "\"#{@name.encode("UTF-8")}\"はlookDownをサーバに送信"
    @socket.puts("ld\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 右を見る(直線9マス)
  def searchRight()
    puts "\"#{@name.encode("UTF-8")}\"はsearchRightをサーバに送信"
    @socket.puts("sr\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 左を見る(直線9マス)
  def searchLeft()
    puts "\"#{@name.encode("UTF-8")}\"はsearchLeftをサーバに送信"
    @socket.puts("sl\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 上を見る(直線9マス)
  def searchUp()
    puts "\"#{@name.encode("UTF-8")}\"はsearchUpをサーバに送信"
    @socket.puts("su\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 下を見る(直線9マス)
  def searchDown()
    puts "\"#{@name.encode("UTF-8")}\"はsearchDownをサーバに送信"
    @socket.puts("sd\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 右にブロックを置く
  def putRight()
    puts "\"#{@name.encode("UTF-8")}\"はputRightをサーバに送信"
    @socket.puts("pr\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 左にブロックを置く
  def putLeft()
    puts "\"#{@name.encode("UTF-8")}\"はputLeftをサーバに送信"
    @socket.puts("pl\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 上にブロックを置く
  def putUp()
    puts "\"#{@name.encode("UTF-8")}\"はputUpをサーバに送信"
    @socket.puts("pu\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 下にブロックを置く
  def putDown()
    puts "\"#{@name.encode("UTF-8")}\"はputDownをサーバに送信"
    @socket.puts("pd\r")
    msg = @socket.gets
    results = parseInt(msg)
    @socket.puts("\#\r")
    return results
  end

  # 文字列を整数配列に変換
  def parseInt(str)
    results = [9,9,9,9,9,9,9,9,9,9]

    for i in 0..9
      results[i] = str[i].to_i
      print results[i]
    end

    print "\r"
    return results
  end

  # ソケットを閉じる
  def close
    @socket.close
  end
end

# テスト用
# "CHaserConnect.rb"自体を実行するとサーバに接続
if __FILE__ == $0
  target = CHaserConnect.new("test")

  values = Array.new(10)

  # getReadyとsearchUPを繰り返すのみ
  loop do
    values = target.getReady
    if values[0] == 0
      break
    end

    values = target.searchUp
    if values[0] == 0
      break
    end
  end

  target.close
end
