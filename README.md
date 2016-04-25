# GNUPlotTimingChart

GNUPlotでタイミングチャートを描画できるようにします。

csvデータを読み込み、GNUPlot用コマンド文字列を出力します。
元のcsvファイルは変更しません。

#使い方

ruby tchart.rb sample.csv > hoge.gp ; gnuplot hoge.gp
