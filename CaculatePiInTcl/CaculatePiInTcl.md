读了阮一峰的[蒙特卡罗方法入门](http://www.ruanyifeng.com/blog/2015/07/monte-carlo-method.html)，用概率统计的方式求解棘手的数学问题还挺有意思的,尤其是利用正方形和它的内切圆之间的面积关系来建模求解圆周率的方法精巧又简单，比投针实验好理解也好实现多了。建模可不是Matlab或者MAST/VHDL语言的专利，既然tcl/tk语言也有内置的随机数产成函数*rand()*,那么我用tcl/tk建模计算圆周率也应该不在话下。
####建模思想

正方形的内切圆与该正方形的面积之比是π/4。

![figure](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015072611.jpg)

![formula](http://www.ruanyifeng.com/blogimg/asset/2015/bg2015072603.jpg)

图片和公式引用自 阮一峰的[蒙特卡罗方法入门]( http://www.ruanyifeng.com/blog/2015/07/monte-carlo-method.html)


在这个正方形内部，随机产生足够多的点，计算它们与中心点的距离，判断是否落在圆的内部。如果这些点均匀分布，那么圆内的点应该占到所有点的 π/4，因此将这个比值乘以4，就是π的值。
####脚本实现
tcl/tk内置math函数库的rand()方法可以随机生成0～1的浮点数，假设圆的半径为整数r,可以用以下方式产生(0,r)区间的随机整数:
```tcl
set value [int [expr rand() * $r]]
```
为了计算简便，可以把模型进一步简化，只计算第一象限内的点落入圆内的比例。为了观察tcl/tk的*rand()*函数是否真的随机，我又多加了几行tk代码，把所有的点都显示出来。下面的代码中正方形的边长为300,随机产生300*300个点，理想情况下如果随机点100%均匀分布，那么每个点应该恰好对应一个像素,画布会一片漆黑。
**tcl/tk代码：**
```tcl
proc CaculatePi {runs range canvas} {
    set r $range
    set hits 0
    set run 0
    while {$run < $runs} {
        set rPower2 [expr pow($r,2)]
        set ptX [expr int(rand() * $range)]
        set ptY [expr int(rand() * $range)]
        # display point on canvas
        $canvas create line [expr $ptX + 5] [expr $ptY + 5] [expr $ptX + 5] [expr $ptY + 5]
        set ptPower2 [expr pow($ptX,2) + pow($ptY,2)]
        if {[expr $rPower2 - $ptPower2] >= 0} {
            incr hits
        }
        incr run
    }


    set pi [expr $hits * 4 / double($runs)]
    return $pi
}


set range 300
catch {destroy .c}
# leave 10 pts margin for rectangle
set canvas [canvas .c -width [expr $range + 10] -height [expr $range + 10]]
pack $canvas -fill both
$canvas create oval 5 5 [expr $range + 5] [expr $range + 5] -outline blue -width 2
$canvas create rect 5 5 [expr $range + 5] [expr $range + 5] -outline blue -width 2


set pi [CaculatePi [expr $range * $range] $range $canvas]
puts "Pi:$pi"
```
**计算结果和显示**
Pi:3.1512888888889

 90000个随机点，但是结果居然比祖冲之老先生手工割圆的精度还低很多很多。再看看Canvas上的点图虽然不是一片漆黑，但是点的分布也还比较一致均匀，试着再增加些随机点？ 把点数增加到100万，画布变得一片漆黑了，Pi结果为3.145944，精度还是很有限。
难道tcl/tk的rand()函数产生的伪随机数还是不够随机？
**[拿来主义](http://www.tcl.tk/cgi-bin/tct/tip/310.html)，换用一个号称更好的伪随机数产生方法试试**
```tcl
namespace eval ::PRNG {
 #  Implementation of a PRNG according to George Marsaglia
     variable mod [expr {wide(256)*wide(256)*wide(256)*wide(256)-5}]
     variable fac [expr {wide(256)*wide(32)}]
     variable x1 [expr {wide($mod*rand())}]
     variable x2 [expr {wide($mod*rand())}]
     variable x3 [expr {wide($mod*rand())}]


     puts $mod
 }


 proc ::PRNG::marsaglia {} {
     variable mod
     variable fac
     variable x1
     variable x2
     variable x3


     set xn [expr {($fac*($x3+$x2+$x1))%$mod}]
     set x1 $x2
     set x2 $x3
     set x3 $xn
     return [expr {$xn/double($mod)}]
 }
```
把proc * CaculatePi* 中的 * rand()*函数替换为*[ ::PRNG::marsaglia ]*, 再跑100万点试试，Pi结果为 3.155572，计算结果还不如tcl/tk内建的*rand()*函数，why?



