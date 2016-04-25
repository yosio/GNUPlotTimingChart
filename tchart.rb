require 'csv'

puts "reset"
puts "set nokey"
puts 'set grid lc rgb "#999999" lt 0.5'
puts 'set border lc rgb "#bbbbbb"'
puts 'set datafile separator ","'
puts "set ytics 1" # y���̖ڐ��蕝��1�ɂ���
puts 'set format y "" ' # y���̖ڐ���̐���������
puts 'set ylabel "" offset screen -0.05, 0'
$graph_option = 'w l lc rgb "#55dd55"'
$label_option = 'tc rgb "#bbbbbb"'
plot_str = "plot "
bus_str  = ""

f = File.read(ARGV[0]).split("\n")
# �R�}���h�F��
title_line_ary = Array.new
type_line_ary  = Array.new
arrow_line_ary = Array.new
f.each{|line|
    if(line[0]!="#")then;next;end
    #line_ary = line.chomp.split(",")
    line_ary = line.chomp.parse_csv
    line_ary.map!{|e| if(e==nil)then;"";else;e;end}
    case line_ary[0]
    when "#type"
        type_line_ary  = line_ary
    when "#title"
        title_line_ary = line_ary
    when "#arrow"
        arrow_line_ary = line_ary
    else
    end
}


title_line_ary.each_with_index{|str,i|
    if(i==0)then;next;end
    puts "set label #{$label_option} at screen 0.01, first #{(i-1)*2+0.5} \"#{str}\""
}

# ���`��
# �����F[rise|decay] num [option]
puts "# #{arrow_line_ary.to_s}"
arrow_line_ary.each_with_index{|str,i|
    if(i==0)then;next;end
    order_ary = str.split(" ", 3).compact.reject(&:empty?) # �X�y�[�X��3�ɕ����āA�󕶎����폜
    if(order_ary[0] != "rise")then;next;end
    prev_num = nil
    f.each{|line|
        line_ary = line.chomp.split(",")
        if(line[0]=="#")then;next;end
        if(prev_num == nil)
            prev_num = line_ary[i].to_i
        end
        if(prev_num == 0 && line_ary[i].to_i == 1)
            puts "set arrow from #{line_ary[0]}, #{(i-1)*2+1} to #{line_ary[0]}, #{(order_ary[1].to_i - 1)*2} #{if(order_ary.size >= 3)then;order_ary[2];end}"
        end
        prev_num = line_ary[i].to_i
    }
}

type_line_ary.each_with_index{|str,i|
    if(i==0)then;next;end
    case str
    when "bus"
        plot_str += "\"-\" using 1:(-$2+1+#{i-1}*2) #{$graph_option},"
        plot_str += "\"-\" using 1:($2+#{i-1}*2) #{$graph_option},"

        # "-" �̒��g�𐶐�����(�Ō�ɏo�͂���)
        bus_str_i = "0, 0\n"
        last_num = 0
        last_str =nil
        prev_line_ary = nil
        f.each{|line|
            if(line[0]=="#")then;next;end
            line_ary = line.chomp.split(",")
            if last_str == nil
                last_str = line_ary[i]
                prev_line_ary = line_ary

                #���l�o��(�ŏ��̈��)
                puts "set label #{$label_option} at first #{line_ary[0].to_f}, #{(i-1)*2+0.5} \"#{line_ary[i]}\""
            end
            if(line_ary[i] != last_str)
                bus_str_i += prev_line_ary[0] + ", " + last_num.to_s + "\n"
                last_num ^= 1;#���]
                bus_str_i += line_ary[0] + ", " + last_num.to_s + "\n"
                last_str = line_ary[i]

                # �����o��
                puts "set label #{$label_option} at first #{line_ary[0].to_f}, #{(i-1)*2+0.5} \"#{line_ary[i]}\""
            end
            prev_line_ary = line_ary
        }
        bus_str_i += prev_line_ary[0] + ", " + last_num.to_s + "\n" #�Ō�̃f�[�^�͕K���o��
        bus_str_i += "e\n"
        bus_str += bus_str_i
        bus_str += bus_str_i #�㉺��񕪏o��

    when "cnt"
        i_ary = Array.new
        f.each{|line|
            if(line[0]=="#")then;next;end
            i_ary.push line.split(",")[i].to_i
        }
        plot_str += "\"#{ARGV[0]}\" using 1:(($#{i+1}/#{i_ary.max})+#{i-1}*2) #{$graph_option},"
    else 
        plot_str += "\"#{ARGV[0]}\" using 1:($#{i+1}+#{i-1}*2) #{$graph_option},"
    end

}
#puts 'set obj rect behind from screen 0,0 to screen 1,1 fillcolor rgb "black"'
puts plot_str.chop
puts bus_str
puts "pause -1"
