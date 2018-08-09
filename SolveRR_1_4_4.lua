--一、源码声明
	--本脚本算法由 i_82 （Wu Zheng）/ tempest （Pu Chenyu） 编写，仅供爱好者交流与学习使用，严禁用于商业用途。本脚本适用于 iPhone & iPad 的 iOS 5.0 以上环境。

--二、脚本使用说明（要求越狱）
	--1、添加 Cydia 源：http://cydia.touchelf.com，安装触摸精灵后注销。
	--2、将本脚本放置到 /var/touchelf/scripts 目录下，打开触摸精灵并选择本脚本。
	--3、进入天天爱消除，单击开始游戏，然后按音量键启动，运行过程中可以随时按音量键结束运行。

--三、脚本配置说明
	--1、通用游戏配置
		--（1）安静模式：QUIET
		--（2）配置运行延迟：MSEC、BSEC
		--（3）配置方块背景灰度范围：BGMIN、BGMAX
		--（4）配置方块色值范围：M
		--（5）配置区域横纵方格数量：DW、DH
		--（6）配置区域有效范围：CHKINT
	--2、设备自动配置
		--（1）配置坐标系；ROTATE
		--（2）配置区域顶点坐标；X、Y
		--（3）配置方块中心坐标：WI、HE
		--（4）配置方块背景判断坐标：BGX、BGY
		--（5）配置方块尺寸：SW、SH

----------------------------------------------
--以下内容不了解请勿修改，否则脚本很可能无法正常运行。
----------------------------------------------

--初始化子程序
function loadset()
	SCRW, SCRH = getScreenSize();
	SCREEN_RESOLUTION = ""..SCRW.."x"..SCRH.."";
	SCREEN_COLOR_BITS = 32;
	redR, redG, redB = 255, 85, 111
	yelR, yelG, yelB = 255, 235, 88
	grnR, grnG, grnB = 202, 255, 105
	bluR, bluG, bluB = 98, 202, 241
	pupR, pupG, pupB = 165, 131, 209
	brnR, brnG, brnB = 241, 163, 94
	whtR, whtG, whtB = 255, 255, 255
	pnkR, pnkG, pnkB = 255, 200, 239
	ylxR, ylxG, ylxB = 252, 246, 125	
	endR, endG, endB = 147, 108, 189
	m, n, p, q, timeout, WAIT = 0, 0, 0, 0, 0, 500
	if SCRW == 640 and SCRH == 960 then
		ROTATE, X, Y, DW, DH, SW, SH = 0, 5, 208, 7, 7, 90, 90
	elseif SCRW == 640 and SCRH == 1136 then
		ROTATE, X, Y, DW, DH, SW, SH = 0, 5, 296, 7, 7, 90, 90
	elseif SCRW == 768 and SCRH == 1024 then
		ROTATE, X, Y, DW, DH, SW, SH = 0, 69, 240, 7, 7, 90, 90
	elseif SCRW == 1536 and SCRH == 2048 then
		ROTATE, X, Y, DW, DH, SW, SH = 0, 138, 480, 7, 7, 180, 180
	elseif SCRW == 750 and SCRH == 1334 then
		ROTATE, X, Y, DW, DH, SW, SH = 0, 6, 347, 7, 7, 105.5, 105.5
	elseif SCRW == 1080 and SCRH == 1920 then
		ROTATE, X, Y, DW, DH, SW, SH = 0, 138, 480, 7, 7, 180, 180
	else
		return false
	end
	init("0",ROTATE);
	return true
end

--主循环程序
function rrprocess()
	for v=1,1000,1 do
		mSleep(WAIT);
		keepScreen(true);
		mt = {}
		--读取屏幕,鉴别颜色
		for i = 1,DW,1 do
			mt[i] = {}
			for j = 1,DH,1 do
				mt[i][j] = {}
				for k = 1,3,1 do
					mt[i][j][k] = i * 100 + j * 10 + k
				end
				mt[i][j][1] = math.floor(X + SW / 2 * (2 * i - 1))
				mt[i][j][2] = math.floor(Y + SH / 2 * (2 * j - 1))
				gcR,gcG,gcB = getColorRGB(mt[i][j][1],mt[i][j][2]);
				if ((gcR - redR)^2+(gcG - redG)^2+(gcB - redB)^2) < 75 then mt[i][j][3] = 1
				elseif ((gcR - yelR)^2+(gcG - yelG)^2+(gcB - yelB)^2) < 75 then mt[i][j][3] = 2
				elseif ((gcR - grnR)^2+(gcG - grnG)^2+(gcB - grnB)^2) < 75 then mt[i][j][3] = 3
				elseif ((gcR - bluR)^2+(gcG - bluG)^2+(gcB - bluB)^2) < 75 then mt[i][j][3] = 4
				elseif ((gcR - pupR)^2+(gcG - pupG)^2+(gcB - pupB)^2) < 75 then mt[i][j][3] = 5
				elseif ((gcR - brnR)^2+(gcG - brnG)^2+(gcB - brnB)^2) < 75 then mt[i][j][3] = 6
				elseif ((gcR - whtR)^2+(gcG - whtG)^2+(gcB - whtB)^2) < 75 then mt[i][j][3] = 7
				elseif ((gcR - ylxR)^2+(gcG - ylxG)^2+(gcB - ylxB)^2) < 75 then mt[i][j][3] = 2			
				end
			end
		end
		--脚本结束条件
		gcR,gcG,gcB = getColorRGB(SCRW - 2,SCRH - 2); 
		if ((gcR - endR)^2+(gcG - endG)^2+(gcB - endB)^2) < 225 then
		lua_exit();
		end
		keepScreen(false);
		--普通消除
		for t2 = 1,DH,1 do
			for t1 = 1,DW,1 do
				--生成当前位置3×3坐标系
				s = {}	
				for l = 1,9,1 do
					s[l] = 0 
				end
				s[5] = mt[t1][t2][3]
				if t1 == 1 and t2 == 1 then
					s[6] = mt[t1 + 1][t2][3]
					s[8] = mt[t1][t2 + 1][3]
					s[9] = mt[t1 + 1][t2 + 1][3]
				elseif t1 == 1 and t2 == DH then
					s[2] = mt[t1][t2 - 1][3]
					s[3] = mt[t1 + 1][t2 - 1][3]
					s[6] = mt[t1 + 1][t2][3]
				elseif t1 == DW and t2 == 1 then
					s[4] = mt[t1 - 1][t2][3]
					s[7] = mt[t1 - 1][t2 +1][3]
					s[8] = mt[t1][t2 + 1][3]
				elseif t1 == DW and t2 == DH then
					s[1] = mt[t1 - 1][t2 - 1][3]
					s[2] = mt[t1][t2 - 1][3]
					s[4] = mt[t1 - 1][t2][3]
				elseif t1 == 1 and t2 ~= 1 and t2 ~= DH then
					s[2] = mt[t1][t2 - 1][3]
					s[3] = mt[t1 + 1][t2 - 1][3]
					s[6] = mt[t1 + 1][t2][3]
					s[8] = mt[t1][t2 + 1][3]
					s[9] = mt[t1 + 1][t2 + 1][3]
				elseif t1 == DW and t2 ~= 1 and t2 ~= DH then
					s[1] = mt[t1 - 1][t2 - 1][3]
					s[2] = mt[t1][t2 - 1][3]
					s[4] = mt[t1 - 1][t2][3]
					s[7] = mt[t1 - 1][t2 +1][3]
					s[8] = mt[t1][t2 + 1][3]
				elseif t2 == 1 and t1 ~= 1 and t1 ~= DW then
					s[4] = mt[t1 - 1][t2][3]
					s[6] = mt[t1 + 1][t2][3]
					s[7] = mt[t1 - 1][t2 +1][3]
					s[8] = mt[t1][t2 + 1][3]
					s[9] = mt[t1 + 1][t2 + 1][3]
				elseif t2 == DH and t1 ~= 1 and t1 ~= DW then
					s[1] = mt[t1 - 1][t2 - 1][3]
					s[2] = mt[t1][t2 - 1][3]
					s[3] = mt[t1 + 1][t2 - 1][3]
					s[4] = mt[t1 - 1][t2][3]
					s[6] = mt[t1 + 1][t2][3]
				else
					s[1] = mt[t1 - 1][t2 - 1][3]
					s[2] = mt[t1][t2 - 1][3]
					s[3] = mt[t1 + 1][t2 - 1][3]
					s[4] = mt[t1 - 1][t2][3]
					s[6] = mt[t1 + 1][t2][3]
					s[7] = mt[t1 - 1][t2 +1][3]
					s[8] = mt[t1][t2 + 1][3]
					s[9] = mt[t1 + 1][t2 + 1][3]
				end
				--寻找消除参数
				if t1 > 3 then
					if s[4] == s[5] and mt[t1 - 3][t2][3] == s[5] then
						m = t1 - 3
						n = t2
						p = t1 - 2
						q = t2
					end
				end
				if t1 < DW - 2 then
					if s[6] == s[5] and mt[t1 + 3][t2][3] == s[5] then
						m = t1 + 3
						n = t2
						p = t1 + 2
						q = t2
					end
				end
				if t2 > 3 then
					if s[2] == s[5] and mt[t1][t2 - 3][3] == s[5] then
						m = t1
						n = t2 - 3
						p = t1
						q = t2 - 2
					end
				end
				if t2 < DH - 2 then
					if s[8] == s[5] and mt[t1][t2 + 3][3] == s[5] then
						m = t1
						n = t2 + 3
						p = t1
						q = t2 + 2
					end
				end				
				
				if s[2] == s[5] and s[7] == s[5] then
					m = t1 - 1
					n = t2 + 1
					p = t1
					q = t2 + 1
				end
				if s[2] == s[5] and s[9] == s[5] then
					m = t1 + 1
					n = t2 + 1
					p = t1
					q = t2 + 1
				end					
				if s[4] == s[5] and s[3] == s[5] then
					m = t1 + 1
					n = t2 - 1
					p = t1 + 1
					q = t2
				end					
				if s[4] == s[5] and s[9] == s[5] then
					m = t1 + 1
					n = t2 + 1
					p = t1 + 1
					q = t2				
				end
				if s[6] == s[5] and s[1] == s[5] then
					m = t1 - 1
					n = t2 - 1
					p = t1 - 1
					q = t2
				end					
				if s[6] == s[5] and s[7] == s[5] then
					m = t1 - 1
					n = t2 + 1
					p = t1 - 1
					q = t2
				end
				if s[8] == s[5] and s[1] == s[5] then
					m = t1 - 1
					n = t2 - 1
					p = t1
					q = t2 - 1
				end					
				if s[8] == s[5] and s[3] == s[5] then
					m = t1 + 1
					n = t2 - 1
					p = t1
					q = t2 - 1
				end
				
				if s[1] == s[5] and s[3] == s[5] then
					m = t1
					n = t2
					p = t1
					q = t2 - 1
				end
				if s[1] == s[5] and s[7] == s[5] then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
				if s[3] == s[5] and s[9] == s[5] then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
				if s[7] == s[5] and s[9] == s[5] then
					m = t1
					n = t2
					p = t1
					q = t2 + 1					
				end				
			end
		end
		--射线
		for t2 = 3,DH - 1,1 do
			for t1 = 1,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 1][t2 - 2][3] == r and mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 1][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
			end
		end
		for t2 = 2,DH - 2,1 do
			for t1 = 1,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 2][3] == r then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
			end
		end		
		for t2 = 3,DH - 1,1 do
			for t1 = 2,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 - 2][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 - 1][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
			end
		end		
		for t2 = 2,DH - 2,1 do
			for t1 = 2,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 - 1][3] == r and mt[t1 - 1][t2 + 1][3] == r and mt[t1 - 1][t2 + 2][3] == r then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
			end
		end		
		for t2 = 1,DH - 1,1 do
			for t1 = 2,DW - 2,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 1][3] == r and mt[t1 + 2][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1 
					q = t2 + 1
				end
			end
		end		
		for t2 = 1,DH - 1,1 do
			for t1 = 3,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 2][t2 + 1][3] == r and mt[t1 - 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 + 1
				end
			end
		end		
		for t2 = 2,DH,1 do
			for t1 = 2,DW - 2,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 - 1][3] == r and mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 2][t2 - 1][3] == r then
					m = t1
					n = t2
					p = t1 
					q = t2 - 1
				end
			end
		end		
		for t2 = 2,DH,1 do
			for t1 = 3,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 2][t2 - 1][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 + 1][t2 - 1][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 - 1
				end
			end
		end				
		--炸弹
		for t2 = 4,DH,1 do
			for t1 = 2,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1][t2 - 3][3] == r and mt[t1][t2 - 2][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 + 1][t2 - 1][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 - 1
				end
			end
		end
		for t2 = 2,DH - 1,1 do
			for t1 = 1,DW - 3,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 3][t2][3] == r and mt[t1 + 2][t2][3] == r and mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 1][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
			end
		end
		for t2 = 1,DH - 3,1 do
			for t1 = 2,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1][t2 + 3][3] == r and mt[t1][t2 + 2][3] == r and mt[t1 - 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 + 1
				end
			end
		end
		for t2 = 2,DH - 1,1 do
			for t1 = 4,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 3][t2][3] == r and mt[t1 - 2][t2][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 - 1][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
			end
		end
		--
		for t2 = 3,DH,1 do
			for t1 = 1,DW - 3,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 2][t2][3] == r and mt[t1 + 3][t2][3] == r and mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 1][t2 - 2][3] == r then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
			end
		end		
		for t2 = 4,DH,1 do
			for t1 = 1,DW - 2,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 2][t2 - 1][3] == r and mt[t1][t2 - 2][3] == r and mt[t1][t2 - 3][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 - 1
				end
			end
		end	
		for t2 = 1,DH - 2,1 do
			for t1 = 1,DW - 3,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 2][t2][3] == r and mt[t1 + 3][t2][3] == r and mt[t1 + 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 2][3] == r then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
			end
		end		
		for t2 = 1,DH - 3,1 do
			for t1 = 1,DW - 2,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 1][t2 + 1][3] == r and mt[t1 + 2][t2 + 1][3] == r and mt[t1][t2 + 2][3] == r and mt[t1][t2 + 3][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 + 1
				end
			end
		end
		for t2 = 1,DH - 2,1 do
			for t1 = 4,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 2][t2][3] == r and mt[t1 - 3][t2][3] == r and mt[t1 - 1][t2 + 1][3] == r and mt[t1 - 1][t2 + 2][3] == r then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
			end
		end		
		for t2 = 1,DH - 3,1 do
			for t1 = 3,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 + 1][3] == r and mt[t1 - 2][t2 + 1][3] == r and mt[t1][t2 + 2][3] == r and mt[t1][t2 + 3][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 + 1
				end
			end
		end	
		for t2 = 3,DH,1 do
			for t1 = 4,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 2][t2][3] == r and mt[t1 - 3][t2][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 - 1][t2 - 2][3] == r then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
			end
		end		
		for t2 = 4,DH,1 do
			for t1 = 3,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 - 1][3] == r and mt[t1 - 2][t2 - 1][3] == r and mt[t1][t2 - 2][3] == r and mt[t1][t2 - 3][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 - 1
				end
			end
		end	
		--幽灵
		for t2 = 3,DH - 2,1 do
			for t1 = 2,DW,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 1][t2 - 2][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 - 1][t2 + 1][3] == r and mt[t1 - 1][t2 + 2][3] == r then
					m = t1
					n = t2
					p = t1 - 1
					q = t2
				end
			end
		end
		for t2 = 3,DH - 2,1 do
			for t1 = 1,DW - 1,1 do
				r = mt[t1][t2][3]
				if mt[t1 + 1][t2 - 2][3] == r and mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 2][3] == r then
					m = t1
					n = t2
					p = t1 + 1
					q = t2
				end
			end
		end
		for t2 = 2,DH,1 do
			for t1 = 3,DW - 2,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 2][t2 - 1][3] == r and mt[t1 - 1][t2 - 1][3] == r and mt[t1 + 1][t2 - 1][3] == r and mt[t1 + 2][t2 - 1][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 - 1
				end
			end
		end
		for t2 = 1,DH - 1,1 do
			for t1 = 3,DW - 2,1 do
				r = mt[t1][t2][3]
				if mt[t1 - 2][t2 + 1][3] == r and mt[t1 - 1][t2 + 1][3] == r and mt[t1 + 1][t2 + 1][3] == r and mt[t1 + 2][t2 + 1][3] == r then
					m = t1
					n = t2
					p = t1
					q = t2 + 1
				end
			end
		end
		--执行消除动作
		if m >= 1 and n >=1 and p >= 1 and q >=1 and m <= DW and n <= DH and p <= DW and q <= DH then
			x1, y1 = math.random(mt[m][n][1] - 25, mt[m][n][1] + 25), math.random(mt[m][n][2] - 25, mt[m][n][2] + 25);
			x2, y2 = math.random(mt[p][q][1] - 25, mt[p][q][1] + 25), math.random(mt[p][q][2] - 25, mt[p][q][2] + 25);
			touchDown(1,x1,y1);
			mSleep(math.random(10,50));
			touchMove(1,math.ceil((x2+x1)/2),math.ceil((y2+y1)/2));
			mSleep(math.random(10,50));
			touchUp(1,x2,y2);
		else
			if timeout >= 3 then
				dialog("未检测到游戏界面，请进入游戏后再运行脚本。",5);
				break
			else
				timeout = timeout + 1;
				m, n, p, q = 0, 0, 0, 0;
				mSleep(1000);
			end
		end
	end
end

--启动脚本
	ret = loadset();
	if ret == true then
		--dialog("天天爱消除刷分脚本 1.4.4 For TouchSprite\n原作者：i_82（QQ：357722984）\n修改：tempest（QQ：27437091）\n仅供爱好者交流与学习使用，严禁用于商业用途。\nP.S. 把他人劳动成果拿去卖的，小心吃饭噎死喝水呛死！\n威锋网测试组出品",0);
		mSleep(3000);
		rrprocess();
	end
