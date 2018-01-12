namespace eval ::PRNG {
 #  Implementation of a PRNG according to George Marsaglia
 #  originate from http://www.tcl.tk/cgi-bin/tct/tip/310.html
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

proc CaculatePi {runs range canvas} {
    set r $range
    set hits 0
    set run 0
    while {$run < $runs} {
        set rPower2 [expr pow($r,2)]
        set ptX [expr int(rand() * $range)]
        #set ptX [expr int([::PRNG::marsaglia] * $range)]
        set ptY [expr int(rand() * $range)]
        #set ptY [expr int([::PRNG::marsaglia] * $range)]
        # display point on canvas. The way to draw a point differs from Wish to Aim. 
        # No need to set 1 pixel offset in Aim but it is required in Wish
        $canvas create line [expr $ptX + 5] [expr $ptY + 5] [expr $ptX + 5] [expr $ptY + 5 + 1]
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
