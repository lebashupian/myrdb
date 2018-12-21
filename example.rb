#!/usr/bin/env ruby
require_relative "myrdb.other"
require"wxl_console"




表1=C_表.new :id,:name
表2=C_表.new :id,:name2

循环次数=1_0000


#
# 测试写入
#
a=(0...循环次数).to_a
t1=Time.new 
循环次数.times {|x|
	id = a.delete a.sample
	表1.插入 id,随机字符串(2)
	表2.插入 id,随机字符串(2)
}
t2=Time.new 
p t2-t1

#
# 表排序
#
表1.排序
表2.排序
t2=Time.new 
p t2-t1
puts "插入完成"



C_控制台.new.开启


exit
#
# 第一种查询方式
#

t1=Time.new
C_表.直积关联(表1,表2) {|x1,x2|	x1.id == x2.id}.遍历 {|x1,x2| puts "#{x1} #{x2}"}
t2=Time.new
puts "直积关联 : #{t2-t1}"


t1=Time.new
C_表.快速直积关联(表1,表2) {|x1,x2|	x1.id == x2.id}#.遍历 {|x1,x2| puts "#{x1} #{x2}"}
t2=Time.new
puts "快速直积关联 : #{t2-t1}"


#
# 第二种查询方式
#

t1=Time.new
C_表.二分查询关联(表1,表2).过滤 {|记录1,记录2|
	记录1.name.match? /w/ and 记录2.name2.match? /b/
}.遍历 {|记录1,记录2|
	#puts "#{记录1.id} #{记录1.name} #{记录2.id} #{记录2.name2}"
}
t2=Time.new
puts "二分查询关联 : #{t2-t1}"
















=begin 
C_表.笛卡尔关联(表1,表2).过滤{|x|
	x[0].id == x[1].id
}.遍历 {|记录|
	puts "#{记录[0].id} #{记录[1].id} #{记录[0].name} #{记录[1].name2}"
}
=end

exit

=begin 


puts "查询数据"
表1.全部.过滤{|记录| 
	记录.id >=50 and
	记录.age >=8800 and
	记录.name == "wxl"
}.遍历 {|记录|
	p 记录
}

puts "修改数据"
表2.全部.过滤{|记录| 
	记录.id >=50 and
	记录.age >=8800 and
	记录.name == "wxl"
}.遍历 {|记录|
	记录.name='wxl2'
}

puts "再次查询"
表2.全部.过滤{|记录| 
	记录.id >=50 and
	记录.age >=8800 and
	记录.name == "wxl2"
}.遍历 {|记录|
	p 记录
}		

=end











C_控制台.new.开启
