#!/usr/bin/env ruby

require "wxl_console"

class Array
	alias :过滤 :select
	alias :遍历 :each
end

def 随机字符串(长度=3)
	arr=("a".."z").to_a
	char=''
	长度.times {
		char += arr[Random.new.rand(26)]
	}
	char
end

class C_表
	attr_accessor :表数据
	attr_accessor :表类型
	def initialize(*字段)
		@表类型=Struct.new *字段
		@表数据=[]
	end
	def 字段
		@表类型.members
	end
	def 插入(*数据)
		#
		# 下面的*数据很关键，用这个方式成功的传递了参数
		#
		@表数据 << @表类型.new(*数据)
		#@表数据.sort! {|a,b| a.id <=> b.id }
	end

	def 排序
		@表数据.sort! {|a,b| a.id <=> b.id }
	end

	def 全部
		@表数据
	end

	def 数据转化为哈希
		转化后的数组=[]
		self.全部.each {|x| 
			转化后的数组 << x.to_h
		}
		@表数据=转化后的数组
	end

	def C_表.转化为struct(marshal_obj)
		begin
			表数据=marshal_obj
			哈希行=表数据.sample
			表=C_表.new *哈希行.keys

			#表类型=Struct.new *哈希行.keys


			表数据.each {|哈希行|
				表.表数据 << 表.表类型.new(*哈希行.values)
			}
			表			
		rescue Exception => e
			p e.message	
			false
		end

	end

	def 保存到硬盘(dbfile='db.dump')
		begin
			数据转化为哈希
			f=File.new("#{dbfile}",'w')
			Marshal.dump(数据转化为哈希,f)
			f.close
			true			
		rescue Exception => e
			p e.message
			false
		end
	end

	def C_表.加载到内存(dbfile='db.dump')
		self.转化为struct Marshal.load File.open "#{dbfile}",'r'
	end

	def C_表.测试

		表=C_表.new :id,:name,:age,:addr
		puts "创建表结构 #{表.字段}"
		
		puts "大批量插入数据"
		10_0000.times {|x|
			表.插入 x,随机字符串,x**2,"bj"
		}

		puts "保存到硬盘"

		表.保存到硬盘
		 
		puts "读取硬盘数据"

		表2=C_表.加载到内存

		puts "查询数据"
		表2.全部.过滤{|记录| 
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
	end

	#
	# 可用于一对多和多对多的查找
	#
	def self.直积关联(表a,表b)
		二维数组 = []
		表a.全部.遍历 {|记录1|
			表b.全部.遍历 {|记录2|
				if yield 记录1,记录2
					二维数组 << [记录1,记录2]
				end
			}
		}
		二维数组		
	end

	#
	# 仅当一对一查找使用
	#
	def self.快速直积关联(表a,表b)
		i=0
		tmp=[]
		表a.全部.遍历 {|x1|
			表b.全部.遍历 {|x2|
				if yield x1,x2
					tmp << [x1,x2]
					break
				end
				 	
			}		
		}
		tmp
	end

	#
	# 仅当一对一查找使用
	#
	def self.二分查询关联(表a,表b)

		关联后的数组=[]
		表a.全部.遍历 {|x1|
			位置 = 递归查找id 0,表b.全部.size-1,表b.全部,x1.id
			关联后的数组 << [x1,表b.全部[位置]]
		}
		关联后的数组
	end
	def self.递归查找id(数组上位置,数组下位置,表数组,查询的id)

		#
		# 这里是一个特殊的处理,当上下限挨着的时候,必须按if中的代码处理
		#
		if 数组下位置 - 数组上位置 == 1
			return 数组上位置 if 表数组[数组上位置].id==查询的id
			return 数组下位置 if 表数组[数组下位置].id==查询的id
		end

		#
		# 使用指数函数的增长来判断.每次取中间来判断,每次去掉一半的数据.速度非常快
		#
		数组中位置 =  ( 数组下位置 + 数组上位置)/2
		取中的id=表数组[数组中位置].id

		if  取中的id > 查询的id
			#puts "a"
			递归查找id 数组上位置,数组中位置,表数组,查询的id
		elsif 取中的id < 查询的id
			#puts "b"
			递归查找id 数组中位置,数组下位置,表数组,查询的id
		else
			#puts "c"
			return 数组中位置
		end
	end
end