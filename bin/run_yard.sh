source $HOME/.profile
export GEM_HOME=/usr/local/lib/ruby/gems/2.2.0/gems

start_hour=18 # 6p
end_hour=21   # end at 10:59p

current_hour=`date +"%H"`

kill_yardfx () {
  if [ `ps auxx | grep yard | grep -v grep | grep -v run_yard.sh | wc -l` -gt 0 ]; then
    echo "found running yardfx"
    echo " ...killing it!"
    ps auxx | grep yard | grep -v grep | grep -v run_yard.sh | awk '{ print $2 }' | xargs kill -9
  fi
}

if [ $current_hour -lt $start_hour ]; then
  echo "Too too early to start the yardfx"
  echo "Start hour: $start_hour, current hour: $current_hour"
  kill_yardfx
  exit 0
fi

if [ $current_hour -gt $end_hour ]; then
  echo "Too late to run yardfx"
  echo "End hour: $end_hour, current_hour: $current_hour"
  kill_yardfx
  exit 0
fi

if [ `ps auxx | grep meatpi | grep -v grep | wc -l` -gt 0 ]; then
  echo "already running a meatpi"
  exit 0
fi
cd /home/pi/meatpi/bin
/usr/local/bin/ruby ./yardfx.rb 2>&1 > /dev/null &
