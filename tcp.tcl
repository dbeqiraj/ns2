# **********
#			Dionis Beqiraj
#				
#							**********
# Begin a new simulation
  set ns [new Simulator]

#Define colors of packages
  $ns color 1 Blue
  $ns color 2 Red
  $ns color 3 Green
  $ns color 4 Orange


# -------------------------------
# File names where we are going to keep records
# -------------------------------
# In these file we keep record of the current simulation
  set recordTcp0 [open recordTcp0 w]
  set recordTcp1 [open recordTcp1 w]
  set recordTcp3 [open recordTcp3 w] 
  set recordTcp4 [open recordTcp4 w] 
  # In files below we keep record of averages for each congestion window 
  # We need a+ option because we don't want to overwrite.
  set avgTcp0 [open [lindex $argv 1] a+]
  set avgTcp1 [open [lindex $argv 2] a+]
  set avgTcp3 [open [lindex $argv 3] a+]
  set avgTcp4 [open [lindex $argv 4] a+]
  set avg0 0
  set avg1 0
  set avg3 0
  set avg4 0
  
# -------------------------------
# Generate random numbers
# -------------------------------
	proc funcRand {min max} {
		#[expr {$max - $min + 1}]
		set range [expr {$max - $min}] 
		set value [expr {$min + (rand() * $range)}]

		return $value
	}
# 
# -------------------------------
  proc finish {} {

     exit 0
  }

# Create the nodes
  set n0 [$ns node]
  set n1 [$ns node]
  set n2 [$ns node]
  set n3 [$ns node]
  set n4 [$ns node]
  set n5 [$ns node]
  set n6 [$ns node]
  set n7 [$ns node]
  set n8 [$ns node]
  set n9 [$ns node]
  set n10 [$ns node]

# ################################################
# Create the links:
  $ns duplex-link $n0 $n2 100Mb 424ns DropTail
  $ns duplex-link $n1 $n2 100Mb 424ns DropTail
  $ns duplex-link $n2 $n5 60Mb 1654ns DropTail
  
  $ns duplex-link $n3 $n5 100Mb 530ns DropTail
  $ns duplex-link $n4 $n5 100Mb 265ns DropTail
  $ns duplex-link $n6 $n5 100Mb 530ns DropTail
  $ns duplex-link $n7 $n5 100Mb 424ns DropTail

  $ns duplex-link $n5 $n8 60Mb 1654ns DropTail  
  
  $ns duplex-link $n9 $n8 100Mb 424ns DropTail
  $ns duplex-link $n10 $n8 100Mb 424ns DropTail

# ################################################
# Monitor the link between routers
  $ns duplex-link-op $n2 $n5 queuePos 0.1
  $ns duplex-link-op $n5 $n8 queuePos 0.1

# ################################################
# Position the created nodes
  $ns duplex-link-op  $n2 $n0 orient left-up
  $ns duplex-link-op  $n2 $n1 orient left-down
  $ns duplex-link-op  $n2 $n5 orient right
  
  $ns duplex-link-op  $n5 $n3 orient left-up
  $ns duplex-link-op  $n5 $n4 orient left-down
  $ns duplex-link-op  $n5 $n6 orient right-up
  $ns duplex-link-op  $n5 $n7 orient right-down
  
  $ns duplex-link-op  $n5 $n8 orient right

  $ns duplex-link-op  $n8 $n9 orient right-up
  $ns duplex-link-op  $n8 $n10 orient right-down


# ########################################################
# Define buffer size for outcome links
  $ns queue-limit $n2 $n5 190
  $ns queue-limit $n5 $n8 190

	# Set some error. Links always have some losts
	set loss_module [new ErrorModel]
	set this [funcRand 0.01 0.03]
	#puts "value:"
	$loss_module set rate_ $this
	$loss_module unit pkt
	$loss_module drop-target [new Agent/Null]
	set link1 [$ns link $n2 $n5]
	set link2 [$ns link $n5 $n8]
	$link1 errormodule $loss_module
	$link2 errormodule $loss_module
	
# Create source nodes
  set tcp0 [new Agent/TCP/Reno]
  set tcp1 [new Agent/TCP/Reno]
  set tcp3 [new Agent/TCP/Reno]
  set tcp4 [new Agent/TCP/Reno]

  $ns attach-agent $n0 $tcp0
  $ns attach-agent $n1 $tcp1
  $ns attach-agent $n3 $tcp3
  $ns attach-agent $n4 $tcp4

  
# Create destination nodes

  set sink6 [new Agent/TCPSink]
  set sink7 [new Agent/TCPSink]
  set sink9 [new Agent/TCPSink]
  set sink10 [new Agent/TCPSink]
  
  $ns attach-agent $n6 $sink6
  $ns attach-agent $n7 $sink7
  $ns attach-agent $n9 $sink9
  $ns attach-agent $n10 $sink10

  
# source - destination links
  $ns connect $tcp0 $sink6
  $ns connect $tcp1 $sink7
  $ns connect $tcp3 $sink9
  $ns connect $tcp4 $sink10
  
  

# Define window size and package size (in number of packages)
  # 32 packages, 1500B each
  
  $tcp0 set window_ 32
  $tcp0 set   maxcwnd_ 32
  #$tcp0 set   interval_ 0.2
  $tcp0 set packetSize_ 1500
  $tcp0 set segsize_ 1440
  $tcp0 set fid_ 1
  
  $tcp1 set window_ 32
  $tcp1 set   maxcwnd_ 32
  #$tcp1 set   interval_ 0.2
  $tcp1 set packetSize_ 1500
  $tcp1 set segsize_ 1440
  $tcp1 set fid_ 2
  
  $tcp3 set window_ 32
  $tcp3 set   maxcwnd_ 32
  #$tcp3 set   interval_ 0.2
  $tcp3 set packetSize_ 1500
  $tcp3 set segsize_ 1440
  $tcp3 set fid_ 3
  
  $tcp4 set window_ 32
  $tcp4 set   maxcwnd_ 32
  #$tcp4 set   interval_ 0.2
  $tcp4 set packetSize_ 1500
  $tcp4 set segsize_ 1440
  $tcp4 set fid_ 4


# ########################################################
# FTP protocol in tcp links
  set ftp0 [new Application/FTP]
  set ftp1 [new Application/FTP]
  set ftp3 [new Application/FTP]
  set ftp4 [new Application/FTP]

  
  $ftp0 attach-agent $tcp0
  $ftp0 set type_ FTP
  $ftp1 attach-agent $tcp1
  $ftp1 set type_ FTP
  $ftp3 attach-agent $tcp3
  $ftp3 set type_ FTP
  $ftp4 attach-agent $tcp4
  $ftp4 set type_ FTP


# Starting time for each node

  $ns at [funcRand 0 4] "$ftp0 start"
  $ns at [funcRand 0 4] "$ftp1 start"
  $ns at [funcRand 0 4] "$ftp3 start"
  $ns at [funcRand 0 4] "$ftp4 start"

  
# Stop time

  $ns at [funcRand 340 350] "$ftp0 stop"
  $ns at [funcRand 340 350] "$ftp1 stop"
  $ns at [funcRand 340 350] "$ftp3 stop"
  $ns at [funcRand 340 350] "$ftp4 stop"

# -----------------------------------------------------------------
# Write records in files
# -----------------------------------------------------------------
  proc records {tcpSource file avgTcp avg count} {
     global ns
     
     set time 0.1
     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]
     set wnd [$tcpSource set window_]
     puts $file "$now $cwnd"
	 set avg [expr {$avg + $cwnd}]
     if { $count == 3498 } {
		set avg [expr {$avg /3498}]
		# In avgTcp files keep the averages
		puts $avgTcp "$avg"			 
	 }	 
	 incr count
     $ns at [expr $now+$time] "records $tcpSource $file $avgTcp $avg $count" 
  }

# -----------------------------------------------------------
# Keep records for TCP0, TCP1 dhe TCP2
# -----------------------------------------------------------
	set count 0
  $ns at 0.1 "records $tcp0 $recordTcp0 $avgTcp0 $avg0 $count"

  $ns at 0.1 "records $tcp1 $recordTcp1 $avgTcp1 $avg1 $count"
  
  $ns at 0.1 "records $tcp3 $recordTcp3 $avgTcp3 $avg3 $count"
  
  $ns at 0.1 "records $tcp4 $recordTcp4 $avgTcp4 $avg4 $count"

# Time to finish the simulation
  $ns at 350.0 "finish"

# ####################################################################
# Run !!!!
  $ns run